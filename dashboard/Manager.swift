//
//  OrderManager.swift
//  dashboard
//
//  Created by km on 15/12/2023.
//

import Combine
import CryptoSwift
import Foundation
import Starscream

struct TokenResponse: Decodable {
    var token: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        token = try container.decode(String.self)
    }
}

extension String {
    func utf8DecodedString() -> String {
        let data = self.data(using: .utf8)
        let message = String(data: data!, encoding: .nonLossyASCII) ?? ""
        return message
    }

    func utf8EncodedString() -> String {
        let messageData = data(using: .nonLossyASCII)
        let text = String(data: messageData!, encoding: .utf8) ?? ""
        return text
    }
}

struct OrderResponse: Identifiable, Equatable {
    var id: UUID = .init()
    var txid: String
    var order: String
    var type: String!
}

struct AddOrderEvent: Decodable {
    var txid: String!
    var status: String
    var event: String
    var descr: String!
    var errorMessage: String!
}

struct PositionResponse: Identifiable, Equatable {
    var id: UUID = .init()
    var refid: String
    var pair: String
    var type: String
    var vol: Double
    var cost: Double
    var net: String
    var ordertype: String
    var fee: Double
    var value: Double
    var time: Double
}

class Manager: ObservableObject, WebSocketDelegate {
    let didOrdersChange = PassthroughSubject<Void, Never>()
    let didPositionsChange = PassthroughSubject<Void, Never>()

    private var socket: WebSocket!

    @Published var isConnected = false
    @Published var isOwnTradesSubscribed = false
    @Published var isOpenOrdersSubscribed = false
    @Published var wsStatus: WSStatus = .init()

    private var apiKey: String = "YAdPx+LZ+YPxoABmeEdTI+LOe6JlcA9E8w0TI6eW8OiOwQpOQBH0rsnS"
    private var apiSecret: String = "GNsZ3sUrNz+/ZoeLpbAvQzN1f/kRgkftCR/9+kIXXMrLl/KLRQnM1Ml1nWtRJep/06WjOmcz7sk5ezaxr/nUyQ=="
    private var socket_token: String = ""
    private var kraken: Kraken
    @Published var ordersData: [OrderResponse] = []
    @Published var positionsData: [PositionResponse] = []

    private var ordersCancellable: AnyCancellable?
    private var positionsCancellable: AnyCancellable?
    private var connectedCancellable: AnyCancellable?
    private var auth_token: String = ""

    @Published var orders: [OrderResponse] {
        didSet {
            didOrdersChange.send()
        }
    }

    @Published var positions: [PositionResponse] {
        didSet {
            didPositionsChange.send()
        }
    }


    init() {
        let credentials = Kraken.Credentials(apiKey: apiKey, privateKey: apiSecret)

        kraken = Kraken(credentials: credentials)

        orders = []
        positions = []


        ordersCancellable = AnyCancellable($ordersData
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.orders, on: self))

        positionsCancellable = AnyCancellable($positionsData
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.positions, on: self))

        Task {
            await get_auth_token()
        }
    }

    func subscribeOwnTrades() {
        if isConnected && !isOwnTradesSubscribed && auth_token != "" {
            let msg = "{\"event\":\"subscribe\", \"subscription\":{ \"name\":\"ownTrades\", \"token\": \"\(auth_token)\"}}"
            socket.write(string: msg)
        }
    }

    func subscribeOpenOrders() {
        if isConnected && !isOpenOrdersSubscribed && auth_token != "" {
            let msg = "{\"event\":\"subscribe\", \"subscription\":{ \"name\":\"openOrders\", \"token\": \"\(auth_token)\"}}"
            socket.write(string: msg)
        }
    }

    func parseTextMessage(message: String) {
        do {
            if message == "{\"event\":\"heartbeat\"}" {
                return
            }
            let decoder = JSONDecoder()
            if wsStatus.status == "disconnected" {
                let result = try decoder.decode(WSStatus.self, from: Data(message.utf8))

                if result.status == "online" {
                    if !isOwnTradesSubscribed {
                        subscribeOwnTrades()
                    }
                    if !isOpenOrdersSubscribed {
                        subscribeOpenOrders()
                    }
                }

                wsStatus = result

            } else if !isOpenOrdersSubscribed || !isOwnTradesSubscribed {
                let result = try decoder.decode(ChannelSubscriptionStatus.self, from: Data(message.utf8))

                if result.status == "subscribed" {
                    if result.channelName == "ownTrades" {
                        isOwnTradesSubscribed = true
                    } else if result.channelName == "openOrders" {
                        isOpenOrdersSubscribed = true
                    }
                }
            } else {
                if message.contains("openOrders") {
                    Task {
//                        await refetchOpenOrders()
                    }
                } else if message.contains("ownTrades") {
                    Task {
//                        await refetchOpenPositions()
                    }
                } else if message.contains("addOrderStatus") {
                    let result = try decoder.decode(AddOrderEvent.self, from: Data(message.utf8))
                    if result.status == "error" {
                        LogManager.shared.error(result.errorMessage)
                    } else {
                        ordersData.append(OrderResponse(txid: result.txid == nil ? "testorder" : result.txid, order: result.descr))
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
            }
           
            LogManager.shared.info("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            DispatchQueue.main.async {
                self.isConnected = false
                self.isOwnTradesSubscribed = false
                self.isOpenOrdersSubscribed = false
            }
            LogManager.shared.info("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
//                print("Received text: \(string)")

            parseTextMessage(message: string)
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
            DispatchQueue.main.async {
                self.isConnected = false
            }
        case .error(let error):
            DispatchQueue.main.async {
                self.isConnected = false
            }
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

    func get_auth_token() async {
        if auth_token == "" {
            let result = await kraken.getToken()
            switch result {
            case .success(let message):
                if let token = message["token"] as? String {
                    auth_token = token
                    var request = URLRequest(url: URL(string: "wss://ws-auth.kraken.com")!)
                    request.timeoutInterval = 5
                    socket = WebSocket(request: request)
                    socket.delegate = self
                    socket.connect()
                }
            case .failure(let error):
                LogManager.shared.error(error.localizedDescription)
            }
        }
    }

    func add_order_payload(pair: String, vol: Double, price: Double, type: String, scaleInOut: Bool, ordertype: String = "limit", validate: Bool = false) -> String {
        let reduce_only = positions.count > 0 ? scaleInOut : false
        let msg = "{\"event\":\"addOrder\", \"token\": \"\(auth_token)\", \"ordertype\": \"\(ordertype)\", \"pair\": \"\(pair)\", \"price\": \"\(price)\", \"type\": \"\(type)\", \"volume\": \"\(vol)\", \"reduce_only\": \(reduce_only), \"validate\": \"\(validate)\"}"

        return msg
    }

    func buyMarket(pair: String, vol: Double, scaleInOut: Bool, validate: Bool) async {
        if isConnected && socket != nil {
            let msg = add_order_payload(pair: pair, vol: vol, price: 0, type: "buy", scaleInOut: scaleInOut, ordertype: "market", validate: validate)
            socket.write(string: msg)
            LogManager.shared.action(msg)
        }
    }

    func sellMarket(pair: String, vol: Double, scaleInOut: Bool, validate: Bool) async {
        if isConnected && socket != nil {
            let msg = add_order_payload(pair: pair, vol: vol, price: 0, type: "sell", scaleInOut: scaleInOut, ordertype: "market", validate: validate)
            socket.write(string: msg)
            LogManager.shared.action(msg)
        }
    }

    func buyBid(pair: String, vol: Double, best_bid: Double, scaleInOut: Bool, validate: Bool) async {
        if isConnected && socket != nil {
            let msg = add_order_payload(pair: pair, vol: vol, price: best_bid, type: "buy", scaleInOut: scaleInOut, validate: validate)
            socket.write(string: msg)
            LogManager.shared.action(msg)
        }
    }

    func sellAsk(pair: String, vol: Double, best_ask: Double, scaleInOut: Bool, validate: Bool) async {
        if isConnected && socket != nil {
            let msg = add_order_payload(pair: pair, vol: vol, price: best_ask, type: "sell", scaleInOut: scaleInOut, validate: validate)
            socket.write(string: msg)
            LogManager.shared.action(msg)
        }
    }

    func buyLimit(pair: String, vol: Double, price: Double, scaleInOut: Bool, validate: Bool) async {
        if isConnected && socket != nil {
            let msg = add_order_payload(pair: pair, vol: vol, price: price, type: "buy", scaleInOut: scaleInOut, validate: validate)
            socket.write(string: msg)
            LogManager.shared.action(msg)
        }
    }

    func sellLimit(pair: String, vol: Double, price: Double, scaleInOut: Bool, validate: Bool) async {
        if isConnected && socket != nil {
            let msg = add_order_payload(pair: pair, vol: vol, price: price, type: "sell", scaleInOut: scaleInOut, validate: validate)
            socket.write(string: msg)
            LogManager.shared.action(msg)
        }
    }

    func cancelAllOrders() async {
        let result = await kraken.cancelAllOrders()
        switch result {
        case .success(let message):
            if let _ = message["count"] {
                await refetchOpenOrders()
            }
        case .failure(let error):
            LogManager.shared.error(error.localizedDescription)
        }
    }

    func cancelOrder(txid: String) async {
        let result = await kraken.cancelOrder(txid: txid)
        switch result {
        case .success(let message):
            if let _ = message["count"] {
                await refetchOpenOrders()
            }
        case .failure(let error):
            LogManager.shared.error(error.localizedDescription)
        }
    }

    func closePositionMarket(refid: String) async {
        LogManager.shared.error("Closing position \(refid)")
    }

    func flattenPosition(refid: String) async {
        LogManager.shared.error("Flattening position \(refid)")
    }

    func flattenAllPositions() async {
        for position in positions {
            await flattenPosition(refid: position.refid)
        }
    }

    func closeAllPositions() async {
        for position in positions {
            await closePositionMarket(refid: position.refid)
        }
    }

    func refetchOpenPositions() async {
        let result = await kraken.openPositions(docalcs: true)
        switch result {
        case .success(let positions):

            DispatchQueue.main.async {
                var new_positions: [PositionResponse] = []
                if let openOrders = positions["result"] {
                    let dict = openOrders as? [String: AnyObject]
                    for (key, value) in dict! {
                        if let pair = value["pair"] as? String,
                           let t = value["type"] as? String,
                           let vol = value["vol"] as? Double,
                           let cost = value["cost"] as? Double,
                           let net = value["net"] as? String,
                           let ordertype = value["ordertype"] as? String,
                           let fee = value["fee"] as? Double,
                           let v = value["value"] as? Double,
                           let tm = value["time"] as? Double
                        {
                            let pos = PositionResponse(refid: key, pair: pair, type: t, vol: vol, cost: cost, net: net, ordertype: ordertype, fee: fee, value: v, time: tm)
                            new_positions.append(pos)
                        }
                    }
                }
                self.positionsData = new_positions
            }

        case .failure(let error):
            LogManager.shared.error(error.localizedDescription)
        }
    }

    func refetchOpenOrders() async {
        let result: KrakenNetwork.KrakenResult = await kraken.openOrders()
        switch result {
        case .success(let orders):
            DispatchQueue.main.async {
                var new_orders: [OrderResponse] = []
                if let openOrders = orders["open"] {
                    let dict = openOrders as? [String: AnyObject]
                    for (key, value) in dict! {
                        if let descr = value["descr"] {
                            if let ordertype = value["type"] {
                                if let descrDict = descr as? [String: AnyObject] {
                                    if let order = descrDict["order"] {
                                        new_orders.append(OrderResponse(txid: key, order: "\(order)", type: "\(ordertype ?? "")"))
                                    }
                                }
                            }
                        }
                    }

                    self.ordersData = new_orders
                }
            }

        case .failure(let error):
            LogManager.shared.error(error.localizedDescription)
        }
    }

    deinit {
        if socket != nil {
            socket.disconnect()
        }
    }
}
