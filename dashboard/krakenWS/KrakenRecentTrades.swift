//
//  KrakenRecentTrades.swift
//  dashboard
//
//  Created by km on 22/12/2023.
//

import Combine
import CryptoSwift
import Foundation
import Starscream

struct RecentTrade: Identifiable, Equatable {
    var id: UUID = UUID()
    var price: Double
    var sellLimit: Double
    var buyLimit: Double
    var sellMarket: Double
    var buyMarket: Double
    var lastSellTimestamp: Double
    var lastBuyTimestamp: Double
}

struct TradeRecordUpdateResponse: Decodable {
    var price: Double
    var volume: Double
    var timestamp: Double
    var side: String
    var orderType: String
    var misc: String
    var count: Double? = 0
    
    
    init(price: String, volume: String, timestamp: Double, side: String, orderType: String, misc: String, count: Double) {
        self.price = Double(price)!
        self.volume = Double(volume)!
        self.timestamp = timestamp
        self.side = side
        self.orderType = orderType
        self.misc = misc
        self.count = count
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        price = Double(try container.decode(String.self))!
        volume = Double(try container.decode(String.self))!
        timestamp = Double(try container.decode(String.self))!
        side = try container.decode(String.self)
        orderType = try container.decode(String.self)
        misc = try container.decode(String.self)
        do {
            count = try container.decode(Double.self)
        } catch {
            print("No count to decode")
        }
    }
}

struct TradeUpdateResponse: Decodable {
    var trades: [TradeRecordUpdateResponse]
    var channelID: Double = 0
    var pair: String
    var channelName: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        channelID = try container.decode(Double.self)
        trades = try container.decode([TradeRecordUpdateResponse].self)
        channelName = try container.decode(String.self)
        pair = try container.decode(String.self)
    }
}

class RecentTradesData: ObservableObject, Identifiable, Equatable {
    static func == (lhs: RecentTradesData, rhs: RecentTradesData) -> Bool {
        lhs.id == rhs.id
    }

    var id: UUID = .init()
    var trades: [Double: RecentTrade] = [:]

    var maxSellMarketVolume: Double {
        if let v = trades.values.max(by: { $0.sellMarket < $1.sellMarket }) {
            return v.sellMarket
        }

        return 0
    }

    var maxBuyMarketVolume: Double {
        if let v = trades.values.max(by: { $0.buyMarket < $1.buyMarket }) {
            return v.buyMarket
        }
        return 0
    }

    var maxSellLimitVolume: Double {
        if let v = trades.values.max(by: { $0.sellLimit < $1.sellLimit }) {
            return v.sellLimit
        }
        return 0
    }

    var maxBuyLimitVolume: Double {
        if let v = trades.values.max(by: { $0.buyLimit < $1.buyLimit }) {
            return v.buyLimit
        }

        return 0
    }
}

class KrakenRecentTrades: WebSocketDelegate, ObservableObject {
    var socket: WebSocket!
    @Published var isConnected = false
    @Published var isSubscribed = false
    let didChange = PassthroughSubject<Void, Never>()
    @Published var data: RecentTradesData! = nil
    var channelID: Double = 0
    var pair: String = ""
    @Published var wsStatus: WSStatus = .init()
    private var cancellable: AnyCancellable?

    @Published var trades: RecentTradesData! {
        didSet {
            didChange.send()
        }
    }

    init(_ p: String) {
        pair = p

        cancellable = AnyCancellable($data
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.trades, on: self))

        var request = URLRequest(url: URL(string: "wss://ws.kraken.com/")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()

        self.data = RecentTradesData()
        
        Task {
            await fetchRecentTrades()
        }
    }

    func subscribe() {
        let msg = "{\"event\":\"subscribe\",\"pair\":[\"\(pair)\"], \"subscription\":{ \"name\":\"trade\"}}"
        socket.write(string: msg)
    }

    func fetchRecentTrades() async {
        LogManager.shared.action("Refetch open orders...")
//        let tim = Int(Calendar.current.startOfDay(for: Date()).timeIntervalSince1970 * 1000)
        let yesterday = Int(Calendar.current.date(byAdding: .day, value: -1, to: Date())!.timeIntervalSince1970)
        let result: KrakenNetwork.KrakenResult = await Kraken.shared.trades(pair: pair, since: yesterday)
        switch result {
        case .success(let trades):
            DispatchQueue.main.async {
                if let trades_list = trades[self.pair] as? [AnyObject] {
                    for trade in trades_list {
                        let recentTrade = TradeRecordUpdateResponse(price: trade[0] as! String, volume: trade[1] as! String, timestamp: trade[2] as! Double, side: trade[3] as! String, orderType: trade[4] as! String, misc: trade[5] as! String, count: trade[6] as! Double)
                        
                        self.update(trade: recentTrade)
                        

                    }
                }
            }
        case .failure(let error):
            LogManager.shared.error(error.localizedDescription)
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

                if result.status == "online" && !isSubscribed {
                    subscribe()
                }

                wsStatus = result

            } else if !isSubscribed {
                let result = try decoder.decode(ChannelSubscriptionStatus.self, from: Data(message.utf8))
                if result.status == "subscribed" && result.channelName == "trade" && result.pair == pair {
                    isSubscribed = true
                    channelID = result.channelID!
                }
               

            } else if isSubscribed {
                let trades_update = try decoder.decode(TradeUpdateResponse.self, from: Data(message.utf8))

                DispatchQueue.main.async {
                    if self.data != nil {
                        for trade in trades_update.trades {
                            self.update(trade: trade)
                        }
                    }
                }
            }
        } catch {
            print("error is \(error.localizedDescription)")
        }
    }

    func update(trade: TradeRecordUpdateResponse) {
        let sellLimit = trade.side == "s" && trade.orderType == "l" ? trade.volume : 0
        let buyLimit = trade.side == "b" && trade.orderType == "l" ? trade.volume : 0
        let sellMarket = trade.side == "s" && trade.orderType == "m" ? trade.volume : 0
        let buyMarket = trade.side == "b" && trade.orderType == "m" ? trade.volume : 0

        if let exTrade = data.trades[trade.price] {
            let newTrade = RecentTrade(price: trade.price, sellLimit: exTrade.sellLimit + sellLimit, buyLimit: exTrade.buyLimit + buyLimit, sellMarket: exTrade.sellMarket + sellMarket, buyMarket: exTrade.buyMarket + buyMarket, lastSellTimestamp: trade.side == "sell" ? trade.timestamp : exTrade.lastSellTimestamp, lastBuyTimestamp: trade.side == "buy" ? trade.timestamp : exTrade.lastBuyTimestamp)
            data.trades[trade.price] = newTrade
        } else {
            let newTrade = RecentTrade(price: trade.price, sellLimit: sellLimit, buyLimit: buyLimit, sellMarket: sellMarket, buyMarket: buyMarket, lastSellTimestamp: trade.side == "sell" ? trade.timestamp : 0, lastBuyTimestamp: trade.side == "buy" ? trade.timestamp : 0)
            data.trades[trade.price] = newTrade
        }
    }

    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            isSubscribed = false
            channelID = 0
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            parseTextMessage(message: string)
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping:
            break
        case .pong:
            break
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        case .peerClosed:
            break
        }
    }

    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
        }
    }

    deinit {
        if socket != nil {
            socket.disconnect()
        }
    }
}
