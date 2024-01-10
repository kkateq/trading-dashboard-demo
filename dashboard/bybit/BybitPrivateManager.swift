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


struct BybitMarketTime: Decodable {
    var retCode: Int
    var retMsg: String
    var time: Int
}

struct BybitPositionDataResponse: Decodable, Equatable {
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
    var price: String
    var qty: String
    var positionIdx: String
    var otderLinkId: String
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

struct BybitWalletData: Decodable, Equatable {
    var totalWalletBalance: String
    var totalMarginBalance: String
    var totalAvailableBalance: String
}

struct BybitWalletResponse: Decodable {
    static let name = "wallet"
    var id: String
    var topic: String
    var creationTime: Int
    var data: [BybitWalletData]
}


struct BybitPositionsRestResult: Decodable {
    var list: [BybitPositionDataResponse]!
    var category: String!
}

struct BybitPositionsRestResponse: Decodable {
    var retCode: Int
    var retMsg: String
    var result: BybitPositionsRestResult!
    var time: Int
}

struct BybitOrdersRestResult: Decodable {
    var list: [BybitOrderData]!
    var category: String!
}

struct BybitOrdersRestResponse: Decodable {
    var retCode: Int
    var retMsg: String
    var result: BybitOrdersRestResult!
    var time: Int
}

struct BybitWalletRestResult: Decodable {
    var list: [BybitWalletData]!
}

struct BybitWalletRestResponse: Decodable {
    var retCode: Int
    var retMsg: String
    var result: BybitWalletRestResult!
    var time: Int
}

class BybitPrivateManager: BybitSocketDelegate, ObservableObject {
    var bybitSocket: BybitSocketTemplate
    var isSubscribed: Bool = false
    let didChangePositions = PassthroughSubject<Void, Never>()
    private var cancellablePositions: AnyCancellable?

    let didChangeOrders = PassthroughSubject<Void, Never>()
    private var cancellableOrders: AnyCancellable?

    let didChangeWallet = PassthroughSubject<Void, Never>()
    private var cancellableWallet: AnyCancellable?

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

    @Published var dataWallet: [BybitWalletData]!
    @Published var wallet: [BybitWalletData]! {
        didSet {
            didChangeOrders.send()
        }
    }

    var isConnected: Bool {
        return bybitSocket.isConnected
    }
    
    var totalAvailableBalance: Double {
        if let w = self.dataWallet {
            if w.count > 0 {
                let item = w[0]
                return Double(item.totalAvailableBalance)!
            }
        }
        
        return -1
    }
    

    init() {
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
            .removeDuplicates()
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
                let res = try JSONDecoder().decode(BybitPositionsRestResponse.self, from: $0)
                
                if res.retCode == 0 {
                    
                    DispatchQueue.main.async {
                        self.dataPositions = res.result.list
                    }
                } else {
                    LogManager.shared.error("error is \(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
            }
        })
    }
    
    func fetchOrders() async {
        await BybitRestApi.fetchOrders(cb: {
            do {
                let res = try JSONDecoder().decode(BybitOrdersRestResponse.self, from: $0)
                
                if res.retCode == 0 {
                    
                    DispatchQueue.main.async {
                        self.dataOrders = res.result.list
                    }
                } else {
                    LogManager.shared.error("error is \(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
            }
        })
    }
    
    func fetchBalance() async {
        await BybitRestApi.fetchTradingBalance(cb: {
            do {
                let res = try JSONDecoder().decode(BybitWalletRestResponse.self, from: $0)
                
                if res.retCode == 0 {
                    
                    DispatchQueue.main.async {
                        self.dataWallet = res.result.list
                    }
                } else {
                    LogManager.shared.error("error is \(res.retMsg)")
                }
            } catch {
                LogManager.shared.error("error is \(error.localizedDescription)")
            }
        })
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
