//
//  BybitInstrumentStats.swift
//  dashboard
//
//  Created by km on 15/01/2024.
//

import Combine
import Foundation
import Starscream

struct BybitTickerData: Decodable {
    var symbol: String
    var tickDirection: String!
    var price24hPcnt: String!
    var lastPrice: String!
    var prevPrice24h: String!
    var highPrice24h: String!
    var lowPrice24h: String!
    var prevPrice1h: String!
    var markPrice: String!
    var indexPrice: String!
    var openInterest: String!
    var openInterestValue: String!
    var turnover24h: String!
    var volume24h: String!
    var nextFundingTime: String!
    var fundingRate: String!
    var bid1Price: String!
    var bid1Size: String!
    var ask1Price: String!
    var ask1Size: String!
}

struct BybitTickerDataResponse: Decodable {
    var topic: String
    var type: String
    var data: BybitTickerData
    var cs: Int!
    var ts: Int!
}

class BybitInstrumentStats: BybitSocketDelegate, ObservableObject {
    var pair: String
    var bybitSocket: BybitSocketTemplate
    var isSubscribed: Bool = false
    
    let didChangeOpenInterest = PassthroughSubject<Void, Never>()
    private var cancellableOpenInterest: AnyCancellable?
    @Published var lastNode:BybitTickerDataResponse!
    @Published var data: [BybitTickerDataResponse] = []
    @Published var history: [BybitTickerDataResponse] {
        didSet {
            didChangeOpenInterest.send()
        }
    }
    
    init(pair: String) {
        self.pair = pair
        self.history = []
        
        self.bybitSocket = BybitSocketTemplate()
        bybitSocket.delegate = self
        
        self.cancellableOpenInterest = AnyCancellable($data
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .assign(to: \.history, on: self))
    }
    
    func subscribe(socket: Starscream.WebSocket) {
        let msg = "{\"op\": \"subscribe\", \"args\": [ \"tickers.\(pair)\" ]}"

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
                if message.contains("tickers.\(pair)") {
                    print(message)
                    let update = try JSONDecoder().decode(BybitTickerDataResponse.self, from: Data(message.utf8))
                    

                    DispatchQueue.main.async {
                        self.data = self.data + [update]
                        
                    }
                }
            }

        } catch {
            LogManager.shared.error("error is \(error.localizedDescription)")
        }
    }
}
