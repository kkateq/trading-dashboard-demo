//
//  BybitSocketTemplate.swift
//  dashboard
//
//  Created by km on 04/01/2024.
//

import Foundation
import Starscream
import Combine

public protocol BybitSocketDelegate: AnyObject {
    func subscribe(socket: WebSocket)
    func parseMessage(message:String)
}


class BybitSocketTemplate: WebSocketDelegate, ObservableObject {
    @Published var isConnected = false
    public weak var delegate: BybitSocketDelegate?
    
    var socket: WebSocket!
    
    init() {
        var request = URLRequest(url: URL(string: "wss://stream.bybit.com/v5/public/spot")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            DispatchQueue.main.async {
                self.isConnected = true
                self.delegate?.subscribe(socket: self.socket)
               
            }
            LogManager.shared.info("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            DispatchQueue.main.async {
                self.isConnected = false
            }

            LogManager.shared.info("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            DispatchQueue.main.async {
                self.delegate?.parseMessage(message: string)
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
