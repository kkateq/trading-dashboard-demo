//
//  BybitPrivateManager.swift
//  dashboard
//
//  Created by km on 08/01/2024.
//

import Combine
import CryptoSwift
import Foundation
import Starscream

struct BybitPositionDataResponse: Decodable, Identifiable, Equatable {
    var id = UUID()
    var positionIdx: Int
    var size: String
    var side: String
    var symbol: String
    var entryPrice: String
    var leverage: String
    var positionValue: String
    var positionBalance: String
    var markPrice: String
    var positionIM: String
    var positionMM: String
    var takeProfit: String
    var stopLoss: String
    var trailingStop: String
    var unrealisedPnl: String
    var cumRealisedPnl: String
    var createdTime: String
    var updatedTime: String
    var isReduceOnly: Bool
}

struct BybitPositionResponse: Decodable {
    static let name = "position"
    var id: String
    var topic: String
    var creationTime: Int
    var data: [BybitPositionDataResponse]
}

struct BybitOrderData: Decodable, Equatable, Identifiable {
    var id = UUID()
    
    var symbol: String
    var orderId: String
    var side: String
    var orderType: String
}

struct BybitOrderResponse: Decodable {
    static let name = "order"
    var id: String
    var topic: String
    var creationTime: Int
    var data: [BybitOrderData]
}

class BybitPrivateManager: WebSocketDelegate, ObservableObject {
    var isSubscribed: Bool = false
    var isConnected: Bool = false

    private var api_key = "Ht5vwI67zqtShgGd0i"
    private var api_secret = "SATUwBQDTjhscfFStGa12YsY9TXfqwl49r7Y"
    var socket: WebSocket!

    let didChangePositions = PassthroughSubject<Void, Never>()
    private var cancellablePositions: AnyCancellable?

    let didChangeOrders = PassthroughSubject<Void, Never>()
    private var cancellableOrders: AnyCancellable?

    @Published var dataPositions: [BybitPositionDataResponse]!
    @Published var positions: [BybitPositionDataResponse]! {
        didSet {
            didChangePositions.send()
        }
    }

    @Published var dataOrders: [BybitOrderData]!
    @Published var orders: [BybitOrderData]! {
        didSet {
            didChangeOrders.send()
        }
    }

    init() {
 
        self.cancellablePositions = AnyCancellable($dataPositions
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.positions, on: self))

        self.cancellableOrders = AnyCancellable($dataOrders
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.orders, on: self))
        
        if let obj = URL(string: "wss://stream.bybit.com/v5/private") {
            var request = URLRequest(url: obj)
            request.timeoutInterval = 15
            self.socket = WebSocket(request: request)
            socket.delegate = self

            socket.connect()
        }
    }

    func subscribe(socket: Starscream.WebSocket) {
        let msg = "{\"op\": \"subscribe\", \"args\": [ \"position\" ]}"

        socket.write(string: msg)
        let msg2 = "{\"op\": \"subscribe\", \"args\": [ \"order\" ]}"

        socket.write(string: msg2)
    }

    func authenticate() {
        let expires = Int(Date().addingTimeInterval(10).timeIntervalSince1970 * 1000)
        let signature = sign(key: api_secret, expires: expires)

        let msg = "{\"op\": \"auth\", \"args\": [\"\(api_key)\", \(expires), \"\(signature)\" ]}"
        socket.write(string: msg)
    }

    func sign(key: String, expires: Int) -> String {
        let inputData = Data("GET/realtime\(expires)".utf8)
        let hash = try? HMAC(key: key, variant: .sha2(.sha256)).authenticate(Array(inputData))
        return hash?.toHexString() ?? ""
    }

    func parseMessage(message: String) {
        do {
            if message == "{\"event\":\"heartbeat\"}" {
                return
            } else if !isSubscribed {
                let subscriptionStatus = try JSONDecoder().decode(BybitSubscriptionStatus.self, from: Data(message.utf8))
                if subscriptionStatus.success {
                    isSubscribed = true
                }
            } else if isSubscribed {
                if message.contains("\"topic\": \"\(BybitPositionResponse.name)\"") {
                    let update = try JSONDecoder().decode(BybitPositionResponse.self, from: Data(message.utf8))

                    DispatchQueue.main.async {
                        self.dataPositions = update.data
                    }
                } else if message.contains("\"topic\": \"\(BybitOrderResponse.name)\"") {
                    let update = try JSONDecoder().decode(BybitOrderResponse.self, from: Data(message.utf8))

                    DispatchQueue.main.async {
                        self.dataOrders = update.data
                    }
                }
            }

        } catch {
            LogManager.shared.error("error is \(error.localizedDescription)")
        }
    }

    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            DispatchQueue.main.async {
                self.isConnected = true

                self.authenticate()
                self.subscribe(socket: self.socket)
            }
            LogManager.shared.info("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            DispatchQueue.main.async {
                self.isConnected = false
            }

            LogManager.shared.info("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):

            DispatchQueue.main.async {
                self.parseMessage(message: string)
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
