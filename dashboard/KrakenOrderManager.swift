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

var PAIRS_ISO_NAMES = [
    "MATICUSD": "MATIC/USD"
]

struct PositionResponse: Identifiable, Equatable {
    var id: UUID = .init()
    var refid: String
    var pair: String
    var type: String
    var vol: String
    var cost: String
    var net: String
    var ordertype: String
    var fee: String
    var value: String
    var time: Double

    var pairISO: String {
        return pair.contains("/") ? pair : PAIRS_ISO_NAMES[pair]!
    }
}

class KrakenOrderManager: ObservableObject, WebSocketDelegate {
    let didOrdersChange = PassthroughSubject<Void, Never>()
    let didPositionsChange = PassthroughSubject<Void, Never>()

    private var socket: WebSocket!

    @Published var isConnected = false
    @Published var isOwnTradesSubscribed = false
    @Published var isOpenOrdersSubscribed = false
    @Published var wsStatus: WSStatus = .init()

    private var apiKey: String = KeychainHandler.KrakenApiKey
    private var apiSecret: String = KeychainHandler.KrakenApiSecret
    
    private var socket_token: String = ""
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
            await refetchOpenPositions()
            await refetchOpenOrders()
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
                        await refetchOpenOrders()
                    }
                } else if message.contains("ownTrades") {
                    Task {
                        await refetchOpenPositions()
                    }
                } else if message.contains("addOrderStatus") {
                    let result = try decoder.decode(AddOrderEvent.self, from: Data(message.utf8))
                    if result.status == "error" {
                        LogManager.shared.error(result.errorMessage)
                    } else {
//                        ordersData.append(OrderResponse(txid: result.txid == nil ? "testorder" : result.txid, order: result.descr))
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
            let result = await Kraken.shared.getToken()
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

    func add_order_payload(pair: String, vol: Double, price: Double, type: String, scaleInOut: Bool, ordertype: String = "limit", validate: Bool = false, leverage: Int = 1) -> String {
        let reduce_only = positions.count > 0 ? scaleInOut : false
        let pairName = pair.contains("/") ? pair : PAIRS_ISO_NAMES[pair]
        let msg = "{\"event\":\"addOrder\", \"token\": \"\(auth_token)\", \"ordertype\": \"\(ordertype)\", \"pair\": \"\(pairName!)\", \"price\": \"\(price)\", \"type\": \"\(type)\", \"volume\": \"\(vol)\", \"reduce_only\": \(reduce_only), \"validate\": \"\(validate)\", \"leverage\": \"\(leverage)\"}"

        return msg
    }

    func buyMarket(pair: String, vol: Double, scaleInOut: Bool, validate: Bool, leverage: Int) async {
        if isConnected && socket != nil {
            let msg = add_order_payload(pair: pair, vol: vol, price: 0, type: "buy", scaleInOut: scaleInOut, ordertype: "market", validate: validate, leverage: leverage)
            socket.write(string: msg)
            LogManager.shared.action(msg)
        }
    }

    func sellMarket(pair: String, vol: Double, scaleInOut: Bool, validate: Bool, leverage: Int) async {
        if isConnected && socket != nil {
            let msg = add_order_payload(pair: pair, vol: vol, price: 0, type: "sell", scaleInOut: scaleInOut, ordertype: "market", validate: validate, leverage: leverage)
            socket.write(string: msg)
            LogManager.shared.action(msg)
        }
    }

    func buyBid(pair: String, vol: Double, best_bid: Double, scaleInOut: Bool, validate: Bool, leverage: Int) async {
        if isConnected && socket != nil {
            let msg = add_order_payload(pair: pair, vol: vol, price: best_bid, type: "buy", scaleInOut: scaleInOut, validate: validate, leverage: leverage)
            socket.write(string: msg)
            LogManager.shared.action(msg)
        }
    }

    func sellAsk(pair: String, vol: Double, best_ask: Double, scaleInOut: Bool, validate: Bool, leverage: Int) async {
        if isConnected && socket != nil {
            let msg = add_order_payload(pair: pair, vol: vol, price: best_ask, type: "sell", scaleInOut: scaleInOut, validate: validate, leverage: leverage)
            socket.write(string: msg)
            LogManager.shared.action(msg)
        }
    }

    func buyLimit(pair: String, vol: Double, price: Double, scaleInOut: Bool, validate: Bool, leverage: Int) async {
        if isConnected && socket != nil {
            let msg = add_order_payload(pair: pair, vol: vol, price: price, type: "buy", scaleInOut: scaleInOut, validate: validate, leverage: leverage)
            socket.write(string: msg)
            LogManager.shared.action(msg)
        }
    }

    func sellLimit(pair: String, vol: Double, price: Double, scaleInOut: Bool, validate: Bool, leverage: Int) async {
        if isConnected && socket != nil {
            let msg = add_order_payload(pair: pair, vol: vol, price: price, type: "sell", scaleInOut: scaleInOut, validate: validate, leverage: leverage)
            socket.write(string: msg)
            LogManager.shared.action(msg)
        }
    }

    internal func cancelAllOrdersREST() async {
        LogManager.shared.action("Cancelling all orders via REST")
        let result = await Kraken.shared.cancelAllOrders()
        switch result {
        case .success(let message):
            if let _ = message["count"] {
                await refetchOpenOrders()
            }
        case .failure(let error):
            LogManager.shared.error(error.localizedDescription)
        }
    }

    internal func cancelAllOrdersWS() async {
        LogManager.shared.action("Cancelling all orders via websocket...")
        let msg = "{ \"event\": \"cancelAll\", \"token\": \"\(auth_token)\"}"
        socket.write(string: msg)
        LogManager.shared.action(msg)
    }

    func cancelAllOrders(useREST: Bool) async {
        if useREST {
            await cancelAllOrdersREST()
        } else if isConnected {
            await cancelAllOrdersWS()
        }
    }

    internal func cancelOrderREST(txid: String) async {
        let result = await Kraken.shared.cancelOrder(txid: txid)
        switch result {
        case .success(let message):
            if let _ = message["count"] {
                await refetchOpenOrders()
            }
        case .failure(let error):
            LogManager.shared.error(error.localizedDescription)
        }
    }

    internal func cancelOrderWS(txid: String) async {
        LogManager.shared.action("Cancelling orders via websocket...")
        let msg = "{ \"event\": \"cancelOrder\", \"token\": \"\(auth_token)\", \"txid\": \([txid])}"
        socket.write(string: msg)
        LogManager.shared.action(msg)
    }

    func cancelOrder(txid: String, useREST: Bool) async {
        if useREST {
            await cancelOrderREST(txid: txid)
        } else if isConnected {
            await cancelOrderWS(txid: txid)
        }
    }

    func closePositionMarketWS(refid: String, validate: Bool, leverage: Int) async {
        LogManager.shared.action("Closing position using websocket \(refid)")

        if let position = positions.first(where: { $0.refid == refid }) {
            if position.type == "sell" {
                await buyMarket(pair: position.pairISO, vol: Double(position.vol)!, scaleInOut: true, validate: validate, leverage: leverage)
            } else {
                await sellMarket(pair: position.pairISO, vol: Double(position.vol)!, scaleInOut: true, validate: validate, leverage: leverage)
            }
        }
    }

    func closePositionMarketREST(refid: String, validate: Bool, leverage: Int) async {
        LogManager.shared.action("Closing position using REST \(refid)")

        if let position = positions.first(where: { $0.refid == refid }) {
            let result = await Kraken.shared.addOrder(orderType: .market, direction: position.type == "sell" ? .buy : .sell, pair: position.pairISO, volume: position.vol, leverage: "\(leverage)", validate: validate, reduce_only: true)
            switch result {
            case .success(let message):
                if let _ = message["result"] {
                    await refetchOpenPositions()
                }
            case .failure(let error):
                LogManager.shared.error(error.localizedDescription)
            }
        }
    }

    func closePositionMarket(refid: String, useREST: Bool, validate: Bool, leverage: Int) async {
        if useREST {
            await closePositionMarketREST(refid: refid, validate: validate, leverage: leverage)
        } else {
            await closePositionMarketWS(refid: refid, validate: validate, leverage: leverage)
        }
    }

    func flattenPositionREST(refid: String, best_bid: Double, best_ask: Double, validate: Bool, leverage: Int) async {
        LogManager.shared.action("Flattening position using REST \(refid)")

        if let position = positions.first(where: { $0.refid == refid }) {
            let price = position.type == "sell" ? best_bid : best_ask
            let result = await Kraken.shared.addOrder(orderType: .limit, direction: position.type == "sell" ? .buy : .sell, pair: position.pairISO, volume: position.vol, price: "\(price)",  leverage: "\(leverage)", validate: validate, reduce_only: true)
            switch result {
            case .success(let message):
                if let _ = message["result"] {
                    await refetchOpenPositions()
                }
            case .failure(let error):
                LogManager.shared.error(error.localizedDescription)
            }
        }
    }

    func flattenPositionWS(refid: String, best_bid: Double, best_ask: Double, validate: Bool, leverage: Int) async {
        LogManager.shared.action("Flattening position using websocket \(refid)")

        if let position = positions.first(where: { $0.refid == refid }) {
            if position.type == "sell" {
                await buyBid(pair: position.pairISO, vol: Double(position.vol)!, best_bid: best_bid, scaleInOut: true, validate: validate, leverage: leverage)
            } else {
                await sellAsk(pair: position.pairISO, vol: Double(position.vol)!, best_ask: best_ask, scaleInOut: true, validate: validate, leverage: leverage)
            }
        }
    }

    func flattenPosition(refid: String, best_bid: Double, best_ask: Double, useREST: Bool, validate: Bool, leverage: Int) async {
        if useREST {
            await flattenPositionREST(refid: refid, best_bid: best_bid, best_ask: best_ask, validate: validate, leverage: leverage)
        } else {
            await flattenPositionWS(refid: refid, best_bid: best_bid, best_ask: best_ask, validate: validate, leverage: leverage)
        }
    }

    func flattenAllPositions(best_bid: Double, best_ask: Double, useREST: Bool, validate: Bool, leverage: Int) async {
        for position in positions {
            await flattenPosition(refid: position.refid, best_bid: best_bid, best_ask: best_ask, useREST: useREST, validate: validate, leverage: leverage)
        }
    }

    func closeAllPositions(useREST: Bool, validate: Bool, leverage: Int) async {
        for position in positions {
            await closePositionMarket(refid: position.refid, useREST: useREST, validate: validate, leverage: leverage)
        }
    }

    func refetchOpenPositions() async {
        LogManager.shared.action("Refetch positions...")
        let result = await Kraken.shared.openPositions(docalcs: true)
        switch result {
        case .success(let positions):

            DispatchQueue.main.async {
                var new_positions: [PositionResponse] = []

                let dict = positions as [String: AnyObject]
                for (key, value) in dict {
                    if let pair = value["pair"] as? String,
                       let t = value["type"] as? String,
                       let vol = value["vol"] as? String,
                       let cost = value["cost"] as? String,
                       let net = value["net"] as? String,
                       let ordertype = value["ordertype"] as? String,
                       let fee = value["fee"] as? String,
                       let v = value["value"] as? String,
                       let tm = value["time"] as? Double
                    {
                        let pos = PositionResponse(refid: key, pair: pair, type: t, vol: vol, cost: cost, net: net, ordertype: ordertype, fee: fee, value: v, time: tm)
                        new_positions.append(pos)
                    }
                }

                self.positionsData = new_positions
            }

        case .failure(let error):
        
            LogManager.shared.info(error.localizedDescription)
            
        }
    }

    func refetchOpenOrders() async {
        LogManager.shared.action("Refetch open orders...")
        let result: KrakenNetwork.KrakenResult = await Kraken.shared.openOrders()
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

    func getBalance() async -> Double {
        let result = await Kraken.shared.accountBalance()
        switch result {
        case .success(let message):
            if let result = message["result"] {
                let dict = result as? [String: String]
                var total = 0.0
                for (_, value) in dict! {
                    total += Double(value)!
                }

                return total
            }
        case .failure(let error):
            LogManager.shared.error(error.localizedDescription)
        }
        return 0
    }
}
