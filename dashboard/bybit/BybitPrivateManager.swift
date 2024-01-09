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

struct BybitWalletData: Decodable, Equatable, Identifiable {
    var id = UUID()

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

class BybitPrivateManager: BybitSocketDelegate, ObservableObject {
    var bybitSocket: BybitSocketTemplate
    var isSubscribed: Bool = false
    let didChangePositions = PassthroughSubject<Void, Never>()
    private var cancellablePositions: AnyCancellable?

    let didChangeOrders = PassthroughSubject<Void, Never>()
    private var cancellableOrders: AnyCancellable?

    let didChangeWallet = PassthroughSubject<Void, Never>()
    private var cancellableWallet: AnyCancellable?

    @Published var accountBalance: Double = 0
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
    }

    func subscribe(socket: Starscream.WebSocket) {
        let msg = "{\"op\": \"subscribe\", \"args\": [ \"position\", \"order\", \"wallet\" ]}"

        socket.write(string: msg)

        isSubscribed = true
    }

//    func fetchPositions() async {
//        LogManager.shared.action("Refetch positions...")
//        let queryString = "category=linear"
//        let url = "https://api.bybit.com/v5/position/list?\(queryString)"
//        guard let url = URL(string: url) else { fatalError("Missing URL") }
//        let timestamp = String(format: "%.0f", Date().timeIntervalSince1970 * 1000)
//        let recv_window = 5000
//        let str = "\(timestamp)\(KeychainHandler.BybitApiKey)\(recv_window)\(queryString)"
//        let signature = generateSignature(api_secret: KeychainHandler.BybitApiSecret, url: str)
//        var urlRequest = URLRequest(url: url)
//        urlRequest.httpMethod = "GET"
//        urlRequest.setValue(signature, forHTTPHeaderField: "X-BAPI-SIGN")
//        urlRequest.setValue(KeychainHandler.BybitApiKey, forHTTPHeaderField: "X-BAPI-API-KEY")
//
//        urlRequest.setValue(timestamp, forHTTPHeaderField: "X-BAPI-TIMESTAMP")
//        urlRequest.setValue("\(recv_window)", forHTTPHeaderField: "X-BAPI-RECV-WINDOW")
//
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
//            if let error = error {
//                print("Request error: ", error)
//                return
//            }
//
//            guard let response = response as? HTTPURLResponse else { return }
//
//            if response.statusCode == 200 {
//                guard let data = data else { return }
//                DispatchQueue.main.async {
//                    do {
//                        print(data)
    ////                        let v = try JSONDecoder().decode(BybitOrderBookRecord.self, from: data)
    ////                        self.data = BybitOrderBook(v.result)
//                    } catch {
//                        print("Error decoding: ", error)
//                    }
//                }
//            }
//        }
//    }

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
