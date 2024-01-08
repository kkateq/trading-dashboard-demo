//
//  BybitSocketTemplate.swift
//  dashboard
//
//  Created by km on 04/01/2024.
//

import Combine
import CryptoSwift
import Foundation
import Starscream

public protocol BybitSocketDelegate: AnyObject {
    func subscribe(socket: WebSocket)
    func parseMessage(message: String)
}

struct BybitAuthMessage: Decodable {
    var success: Bool
    var ret_msg: String
    var op: String
    var conn_id: String
}

class BybitSocketTemplate: WebSocketDelegate, ObservableObject {
    @Published var isConnected = false
    @Published var isAuthenticated = false
    @Published var isBeingAuthenticated = false
    private var isPrivate: Bool
    public weak var delegate: BybitSocketDelegate?
    private var api_key = "MAjZf1ldeS8nZfuBkP"
    private var api_secret = "bFkOYqEdMycTW79Z7Ozgh7reGXdTz51x5Zv7"

    var socket: WebSocket!

    init(_ isPrivate: Bool = false) {
        self.isPrivate = isPrivate
        var request = URLRequest(url: URL(string: "wss://stream.bybit.com/v5/public/spot")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }

    func authenticate() {
        let expires = String(format: "%.0f", Date().addingTimeInterval(1000).timeIntervalSince1970 * 1000)
        let signature = sign(key: api_key, expires: expires)
        let auth_msg = "{\"op\": \"auth\", \"args\": [ \"api_key\": \"\(api_key)\", \"expires\": \(expires), \"signature\": \"\(signature)\" ]}"
        socket.write(string: auth_msg)
    }

    internal func sign(key: String, expires: String) -> String {
        let inputData = Data("GET/realtime\(expires)".utf8)
        let hash = try? HMAC(key: key, variant: .sha2(.sha256)).authenticate(Array(inputData))
        return hash?.toHexString() ?? ""
    }

    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            DispatchQueue.main.async {
                self.isConnected = true
                if !self.isPrivate {
                    self.delegate?.subscribe(socket: self.socket)
                } else {
                    self.isBeingAuthenticated = true
                    self.authenticate()
                }
            }
            LogManager.shared.info("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            DispatchQueue.main.async {
                self.isConnected = false
            }

            LogManager.shared.info("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            if isPrivate, isConnected, isBeingAuthenticated {
                do {
                    let authStatus = try JSONDecoder().decode(BybitAuthMessage.self, from: Data(string.utf8))
                    if authStatus.success {
                        DispatchQueue.main.async {
                            self.isAuthenticated = true
                        }
                    }
                } catch {
                    LogManager.shared.error("error is \(error.localizedDescription)")
                }
            } else {
                DispatchQueue.main.async {
                    self.delegate?.parseMessage(message: string)
                }
            }
        case .binary(let data):
            LogManager.shared.info("Received data: \(data.count)")
        case .ping:
            break
        case .pong:
            break
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            LogManager.shared.info("Cancelled connection")
        case .error(let error):

            handleError(error)
        case .peerClosed:
            break
        }
    }

    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            LogManager.shared.error("websocket encountered an error: \(e.message)")
        } else if let e = error {
            LogManager.shared.error("websocket encountered an error: \(e.localizedDescription)")
        } else {
            LogManager.shared.error("websocket encountered an error")
        }
    }
}
