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

struct BybitResult<Item: Decodable>: Decodable {
    var list: [Item]!
    var category: String!
}

struct BybitListRestBase<Item: Decodable>: Decodable {
    var retCode: Int
    var retMsg: String
    var result: BybitResult<Item>!
    var time: Int
}

struct BybitRestBase<Item: Decodable>: Decodable {
    var retCode: Int
    var retMsg: String
    var result: Item!
    var time: Int
}

struct BybitPositionData: Decodable, Equatable {
    var positionIdx: Int
    var size: String
    var side: String
    var symbol: String
    var entryPrice: String!
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
    var data: [BybitPositionData]
}

struct BybitOrderData: Decodable, Equatable {
    var symbol: String
    var orderId: String
    var side: String
    var orderType: String
    var price: String
    var qty: String
    var positionIdx: Int
    var orderLinkId: String
    var stopLoss: String
    var takeProfit: String
    var reduceOnly: Bool
}

struct BybitOrderResponse: Decodable {
    static let name = "order"
    var id: String
    var topic: String
    var creationTime: Int
    var data: [BybitOrderData]
}

struct Coin: Decodable {
    var coin: String
    var availableToBorrow: String
    var walletBalance: String
}

struct BybitWalletData: Decodable {
    var totalWalletBalance: String
    var totalMarginBalance: String
    var totalInitialMargin: String
    var totalMaintenanceMargin: String
    var coin: [Coin]
    var totalAvailableBalance: String
    var totalPerpUPL: String
    var accountType: String
}

struct BybitWalletResponse: Decodable {
    static let name = "wallet"
    var id: String
    var topic: String
    var creationTime: Int
    var data: [BybitWalletData]
}

struct BybitMutateOrderData: Decodable {
    var orderId: String
    var orderLinkId: String
}

class BybitPrivateManager: BybitSocketDelegate, ObservableObject {
    var pair: String
    var bybitSocket: BybitSocketTemplate
    var isSubscribed: Bool = false
    let didChangePositions = PassthroughSubject<Void, Never>()
    private var cancellablePositions: AnyCancellable?

    let didChangeOrders = PassthroughSubject<Void, Never>()
    private var cancellableOrders: AnyCancellable?

    let didChangeWallet = PassthroughSubject<Void, Never>()
    private var cancellableWallet: AnyCancellable?

    @Published var dataPositions: [BybitPositionData] = []
    @Published var positions: [BybitPositionData] {
        didSet {
            didChangePositions.send()
        }
    }

    @Published var dataOrders: [BybitOrderData] = []
    @Published var orders: [BybitOrderData] {
        didSet {
            didChangeOrders.send()
        }
    }

    @Published var dataWallet: [BybitWalletData] = []
    @Published var wallet: [BybitWalletData] {
        didSet {
            didChangeOrders.send()
        }
    }

    var isConnected: Bool {
        return bybitSocket.isConnected
    }

    var totalAvailableWalletBalance: Double {
        return getWalletBalance()
    }

    var totalAvailableUSDT: Double {
        if dataWallet.count > 0 {
            if let item = dataWallet.first(where: { $0.accountType == "UNIFIED" }) {
                let coins = item.coin
                if let usdt = coins.first(where: {$0.coin == "USDT"}), usdt.walletBalance != "" {
                    return Double(usdt.walletBalance)!
                }
            }
        }
        return -1
    }

    func getWalletBalance(walletName: String = "UNIFIED") -> Double {
        if dataWallet.count > 0 {
            if let item = dataWallet.first(where: { $0.accountType == walletName }) {
                return item.totalWalletBalance != "" ? Double(item.totalWalletBalance)! : 0
            }
        }

        return -1
    }

    init(_ pair: String) {
        self.pair = pair
        self.wallet = []
        self.positions = []
        self.orders = []
        self.bybitSocket = BybitSocketTemplate(true)
        bybitSocket.delegate = self

        self.cancellablePositions = AnyCancellable($dataPositions
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.positions, on: self))

        self.cancellableOrders = AnyCancellable($dataOrders
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.orders, on: self))

        self.cancellableWallet = AnyCancellable($dataWallet
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
//            .removeDuplicates()
            .assign(to: \.wallet, on: self))

        Task {
            await fetchPositions()
            await fetchOrders()
            await fetchBalance()
        }
    }

    func subscribe(socket: Starscream.WebSocket) {
        let msg = "{\"op\": \"subscribe\", \"args\": [ \"position\", \"order\", \"wallet\" ]}"

        socket.write(string: msg)

        isSubscribed = true
    }

    func fetchPositions() async {
        await BybitRestApi.fetchPositions(cb: {
            do {
                let res = try JSONDecoder().decode(BybitListRestBase<BybitPositionData>.self, from: $0)

                if res.retCode == 0 {
                    DispatchQueue.main.async {
                        self.dataPositions = res.result.list
                    }
                } else {
                    LogManager.shared.error("retCode \(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
                print(String(decoding: $0, as: UTF8.self))
            }
        }, symbol: pair)
    }

    func cancelAllOrders() async {
        await BybitRestApi.cancelAllOrders(cb: {
            do {
                let res = try JSONDecoder().decode(BybitListRestBase<BybitMutateOrderData>.self, from: $0)

                if res.retCode == 0 {
                    for o in res.result.list {
                        LogManager.shared.info("Cancelled order \(o.orderId)")
                        Task {
                            await self.fetchOrders()
                        }
                    }
                } else {
                    LogManager.shared.error("retCode \(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
            }
        }, symbol: pair)
    }

    func cancelOrder(id: String, symbol: String) async {
        await BybitRestApi.cancelOrder(cb: {
            do {
                let res = try JSONDecoder().decode(BybitRestBase<BybitMutateOrderData>.self, from: $0)

                if res.retCode == 0 {
                    LogManager.shared.info("Cancelled order \(res.result.orderId)")
                    Task {
                        await self.fetchOrders()
                    }

                } else {
                    LogManager.shared.error("retCode \(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
            }
        }, orderId: id, symbol: symbol)
        await fetchOrders()
    }

    func closeAllPositionsByMarket() async {
        LogManager.shared.action("Close ALL market")
        for position in positions {
            await closeByMarket(id: position.positionIdx)
        }
    }
    
    func closeAllPositionsByLimit(best_bid: Double, best_ask:Double) async {
        LogManager.shared.action("Close ALL limit, bid: \(best_bid), ask: \(best_ask)")
        for position in positions {
            await closeByLimit(id: position.positionIdx, best_bid: best_bid, best_ask: best_ask)
        }
    }
    
    func closeByMarket(id: Int) async {
        LogManager.shared.action("Close market")
        if let position = positions.first(where: {$0.positionIdx == id}) {
            if let size = Double(position.size), size > 0 {
                let side = position.side == "Sell" ? "Buy" : "Sell"
                let params = ["category": "linear", "symbol": position.symbol, "side": side, "orderType": "Market", "qty": "\(position.size)", "reduceOnly": true] as [String: Any]
                
                await createOrder(params: params)
            }
        }
    }
    
    func closeByLimit(id: Int, best_bid: Double, best_ask:Double) async {
        LogManager.shared.action("Close limit bid: \(best_bid), ask: \(best_ask)")
        if let position = positions.first(where: {$0.positionIdx == id}) {
            if let size = Double(position.size), size > 0 {
                let side = position.side == "Sell" ? "Buy" : "Sell"
                let price = side == "Sell" ? best_ask : best_bid
                let params = ["category":  "linear", "symbol": position.symbol, "price": formatPrice(price: price, pair: position.symbol), "side": side, "orderType": "Limit", "qty": "\(position.size)", "reduceOnly": true] as [String: Any]
                
                await createOrder(params: params)
            }
        }
    }

    func fetchOrders() async {
        await BybitRestApi.fetchOrders(cb: {
            do {
                let res = try JSONDecoder().decode(BybitListRestBase<BybitOrderData>.self, from: $0)

                if res.retCode == 0 {
                    DispatchQueue.main.async {
                        self.dataOrders = res.result.list
                    }
                } else {
                    LogManager.shared.error("retCode \(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
                print(String(decoding: $0, as: UTF8.self))
            }
        }, symbol: pair)
    }

    func fetchBalance() async {
        await BybitRestApi.fetchTradingBalance(cb: {
            do {
                let res = try JSONDecoder().decode(BybitListRestBase<BybitWalletData>.self, from: $0)

                if res.retCode == 0 {
                    DispatchQueue.main.async {
                        self.dataWallet = res.result.list
                    }
                } else {
                    LogManager.shared.error("retCode \(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
                print(String(decoding: $0, as: UTF8.self))
            }
        })
    }

    func createOrder(params: [String: Any]) async {
        await BybitRestApi.createOrder(cb: {
            do {
                let res = try JSONDecoder().decode(BybitRestBase<BybitMutateOrderData>.self, from: $0)

                if res.retCode == 0 {
                    LogManager.shared.info("Created order \(res.result.orderId)")
                    Task {
                        await self.fetchOrders()
                    }

                } else {
                    LogManager.shared.error(" retCode\(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
            }
        }, params: params)
        await fetchPositions()
    }

    func buyLimit(symbol: String, vol: Double, price: Double, scaleInOut: Bool, stopLoss: Double! = nil) async {
        LogManager.shared.action("Buy limit \(symbol) @ \(price)")
        let params = ["category": "linear", "symbol": symbol, "side": "Buy", "orderType": "Limit", "qty": "\(vol)", "price": formatPrice(price: price, pair: symbol), "reduceOnly": scaleInOut] as [String: Any]

        await createOrder(params: params)
    }

    func sellLimit(symbol: String, vol: Double, price: Double, scaleInOut: Bool, stopLoss: Double! = nil) async {
        LogManager.shared.action("Sell limit \(symbol) @ \(price)")
        let params = ["category": "linear", "symbol": symbol, "side": "Sell", "orderType": "Limit", "qty": "\(vol)", "price": formatPrice(price: price, pair: symbol), "reduceOnly": scaleInOut] as [String: Any]

        await createOrder(params: params)
    }

    func buyMarket(symbol: String, vol: Double, scaleInOut: Bool, stopLoss: Double! = nil) async {
        LogManager.shared.action("Buy market \(symbol)")
        let params = ["category": "linear", "symbol": symbol, "side": "Buy", "orderType": "Market", "qty": "\(vol)", "reduceOnly": scaleInOut] as [String: Any]

        await createOrder(params: params)
    }

    func sellMarket(symbol: String, vol: Double, scaleInOut: Bool, stopLoss: Double! = nil) async {
        LogManager.shared.action("Sell market \(symbol)")
        let params = ["category": "linear", "symbol": symbol, "side": "Sell", "orderType": "Market", "qty": "\(vol)", "reduceOnly": scaleInOut] as [String: Any]

        await createOrder(params: params)
    }

    func parseMessage(message: String) {
        do {
            if !isSubscribed {
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
                } else if message.contains("\"topic\": \"\(BybitWalletResponse.name)\"") {
                    let update = try JSONDecoder().decode(BybitWalletResponse.self, from: Data(message.utf8))

                    DispatchQueue.main.async {
                        self.dataWallet = update.data
                    }
                }
            }

        } catch {
            LogManager.shared.error("error is \(error.localizedDescription)")
        }
    }
}
