//
//  BybitPrivateManager.swift
//  dashboard
//
//  Created by km on 08/01/2024.
//

import Combine
import Foundation
import Starscream

struct BybitPositionDataResponse: Decodable, Identifiable {
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

class BybitPrivateManager: BybitSocketDelegate, ObservableObject {
    var isSubscribed: Bool = false
    var bybitSocket: BybitSocketTemplate
    let didChange = PassthroughSubject<Void, Never>()
    private var cancellable: AnyCancellable?
    private var api_key = "MAjZf1ldeS8nZfuBkP"
    private var api_secret = "bFkOYqEdMycTW79Z7Ozgh7reGXdTz51x5Zv7"

    @Published var data: [BybitPositionDataResponse] = []
    @Published var positions: [BybitPositionDataResponse]! {
        didSet {
            didChange.send()
        }
    }

    init() {
        self.bybitSocket = BybitSocketTemplate()
        bybitSocket.delegate = self

        self.cancellable = AnyCancellable($data
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .assign(to: \.positions, on: self))
    }

    func subscribe(socket: Starscream.WebSocket) {
        let msg = "{\"op\": \"subscribe\", \"args\": [ \"position\" ]}"

        socket.write(string: msg)
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
                        self.data = update.data
                    }
                }
            }

        } catch {
            LogManager.shared.error("error is \(error.localizedDescription)")
        }
    }
}
