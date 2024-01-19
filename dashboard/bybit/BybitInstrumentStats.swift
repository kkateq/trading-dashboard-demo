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

struct PriceFilter: Decodable {
    var minPrice: String
    var maxPrice: String
    var tickSize: String
}

struct BybitInstrumentInfo: Decodable {
    var symbol: String
    var priceScale: String
    var priceFilter: PriceFilter
}

class BybitInstrumentStats: BybitSocketDelegate, ObservableObject {
    var pair: String
    var bybitSocket: BybitSocketTemplate
    var isSubscribed: Bool = false
    
    let didChangeStats = PassthroughSubject<Void, Never>()
    let didChangeInfo = PassthroughSubject<Void, Never>()
    private var cancellableStats: AnyCancellable?
    private var cancellableInfo: AnyCancellable?
    @Published var instrumentInfo: BybitInstrumentInfo!

    @Published var info: BybitInstrumentInfo! {
        didSet {
            didChangeInfo.send()
        }
    }
    
    @Published var data: BybitTickerData!
    @Published var stats: BybitTickerData! {
        didSet {
            didChangeStats.send()
        }
    }
    
    init(_ pair: String) {
        self.pair = pair
        
        self.bybitSocket = BybitSocketTemplate()
        bybitSocket.delegate = self
        
        self.cancellableStats = AnyCancellable($data
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .assign(to: \.stats, on: self))
        
        self.cancellableInfo = AnyCancellable($instrumentInfo
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .assign(to: \.info, on: self))
        
        
        Task {
            await downloadInstrumentInfo()
        }
    }
    
    func subscribe(socket: Starscream.WebSocket) {
        let msg = "{\"op\": \"subscribe\", \"args\": [ \"tickers.\(pair)\" ]}"

        socket.write(string: msg)
    }
    
    func merge(_ obj1: BybitTickerData!, _ obj2: BybitTickerData! ) -> BybitTickerData {
        if obj1 == nil {
            return obj2
        }
        var new = obj1
        if let newTickDirection = obj2.tickDirection {
            new?.tickDirection = newTickDirection
        }
        
        if let price24hPcnt = obj2.price24hPcnt {
            new?.price24hPcnt = price24hPcnt
        }
        
        if let lastPrice = obj2.lastPrice {
            new?.lastPrice = lastPrice
        }
        
        if let prevPrice24h = obj2.prevPrice24h {
            new?.prevPrice24h = prevPrice24h
        }
        
        if let lowPrice24h = obj2.lowPrice24h {
            new?.lowPrice24h = lowPrice24h
        }
        
        if let prevPrice1h = obj2.prevPrice1h {
            new?.prevPrice1h = prevPrice1h
        }

        if let markPrice = obj2.markPrice {
            new?.markPrice = markPrice
        }
        if let indexPrice = obj2.indexPrice {
            new?.indexPrice = indexPrice
        }
        if let openInterest = obj2.openInterest {
            new?.openInterest = openInterest
        }
        if let openInterestValue = obj2.openInterestValue {
            new?.openInterestValue = openInterestValue
        }
        if let turnover24h = obj2.turnover24h {
            new?.turnover24h = turnover24h
        }
        if let volume24h = obj2.volume24h {
            new?.volume24h = volume24h
        }
        if let nextFundingTime = obj2.nextFundingTime {
            new?.nextFundingTime = nextFundingTime
        }
        if let fundingRate = obj2.fundingRate {
            new?.fundingRate = fundingRate
        }
        if let bid1Price = obj2.bid1Price {
            new?.bid1Price = bid1Price
        }
        if let bid1Size = obj2.bid1Size {
            new?.bid1Size = bid1Size
        }
        if let ask1Price = obj2.ask1Price {
            new?.ask1Price = ask1Price
        }
        if let ask1Size = obj2.ask1Size {
            new?.ask1Size = ask1Size
        }
        return new!
    }
    
    func downloadInstrumentInfo() async {
        await BybitRestApi.instrumentInfo(cb: {
            do {
                let res = try JSONDecoder().decode(BybitListRestBase<BybitInstrumentInfo>.self, from: $0)

                if res.retCode == 0 && res.result.list.count > 0 {
                    DispatchQueue.main.async {
                        self.instrumentInfo = res.result.list[0]
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
                
                    let update = try JSONDecoder().decode(BybitTickerDataResponse.self, from: Data(message.utf8))
                    
                    let updateObj = merge(self.stats, update.data)
                    
                    DispatchQueue.main.async {
                        self.data = updateObj
                    }
                }
            }

        } catch {
            LogManager.shared.error("error is \(error.localizedDescription)")
        }
    }
}
