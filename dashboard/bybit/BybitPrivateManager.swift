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

class BybitPrivateManager: BybitSocketDelegate, ObservableObject {
    var bybitSocket: BybitSocketTemplate
    var isSubscribed: Bool = false
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
    }

    func subscribe(socket: Starscream.WebSocket) {
        let msg = "{\"op\": \"subscribe\", \"args\": [ \"position\" ]}"

        socket.write(string: msg)
        let msg2 = "{\"op\": \"subscribe\", \"args\": [ \"order\" ]}"

        socket.write(string: msg2)
        isSubscribed = true
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
}
