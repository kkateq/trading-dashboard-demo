//
//  BybitLastTrade.swift
//  dashboard
//
//  Created by km on 05/01/2024.
//

import Combine
import Foundation
import Starscream

struct BybitRecentTradeRecordResponse: Decodable {
    var timestamp: Int
    var pair: String
    var side: String
    var volume: String
    var price: String
    var priceDirection: String!
    var tradeId: String
    var isBlockTrade: Bool

    enum CodingKeys: String, CodingKey {
        case timestamp = "T"
        case pair = "s"
        case side = "S"
        case volume = "v"
        case price = "p"
        case priceDirection = "L"
        case tradeId = "i"
        case isBlockTrade = "BT"
    }
}

struct BybitRecentTradeUpdateResponse: Decodable {
    static let name = "publicTrade"
    var topic: String
    var type: String
    var ts: Int
    var data: [BybitRecentTradeRecordResponse]
}

struct BybitTradeHistoryRecord: Decodable {
    var execId: String
    var symbol: String
    var price: String
    var size: String
    var side: String
    var time: String
    var isBlockTrade: Bool
}

struct BybitTradesHistoryResult: Decodable {
    var category: String
    var list: [BybitTradeHistoryRecord]
}

struct BybitTradesHistoryResponse: Decodable {
    var retCode: Int
    var retMsg: String
    var result: BybitTradesHistoryResult
    var time: Int
}

enum BybitTradeSide: String {
    case buy, sell
}

struct BybitRecentTradeRecord: Identifiable {
    var id: String
    var pair: String
    var price: Double
    var volume: Double
    var priceStr: String
    var side: BybitTradeSide
    var time: Int
    var isBlockTrade: Bool
    var direction: String!

    init(trade: BybitTradeHistoryRecord) {
        self.id = trade.execId
        self.pair = trade.symbol
        self.priceStr = trade.price
        self.price = Double(trade.price)!
        self.volume = Double(trade.size)!
        self.side = trade.side == "Buy" ? .buy : .sell
        self.time = Int(trade.time)!
        self.isBlockTrade = trade.isBlockTrade
    }

    init(update: BybitRecentTradeRecordResponse) {
        self.id = update.tradeId
        self.pair = update.pair
        self.priceStr = update.price
        self.price = Double(update.price)!
        self.volume = Double(update.volume)!
        self.side = update.side == "Buy" ? .buy : .sell
        self.time = update.timestamp
        self.isBlockTrade = update.isBlockTrade
        self.direction = update.priceDirection
    }
}

class BybitRecentTradeData: ObservableObject, Equatable {
    var id = UUID()

    @Published var buys: [BybitRecentTradeRecord] = []
    @Published var sells: [BybitRecentTradeRecord] = []
    @Published var lastTrade: BybitRecentTradeRecord!
    @Published var priceDictSells: [String: Double] = [:]
    @Published var priceDictBuys: [String: Double] = [:]
    @Published var priceDictSellsTemp: [String: Double] = [:]
    @Published var priceDictBuysTemp: [String: Double] = [:]
    @Published var anchor: Date = Date()
    @Published var lastTradesBatch: [String: (Double, BybitTradeSide, Int)] = [:]
    var lastMessageTs: Int64

    static func == (lhs: BybitRecentTradeData, rhs: BybitRecentTradeData) -> Bool {
        return lhs.id == rhs.id
    }

    func clean() {
        priceDictSellsTemp = [:]
        priceDictBuysTemp = [:]
    }

    init(_ initialData: BybitTradesHistoryResult!) {
        self.lastMessageTs = Date().currentTimeMillis()
        if let data = initialData {
            for item in data.list {
                let record = BybitRecentTradeRecord(trade: item)

                if record.side == .sell {
                    sells.append(record)
                    let ecx = priceDictSells[record.priceStr] ?? 0
                    priceDictSells[record.priceStr] = record.volume + ecx

                    let temp = priceDictSellsTemp[record.priceStr] ?? 0
                    priceDictSellsTemp[record.priceStr] = record.volume + temp
                } else {
                    buys.append(record)
                    let ecx = priceDictBuys[record.priceStr] ?? 0
                    priceDictBuys[record.priceStr] = record.volume + ecx

                    let temp = priceDictBuysTemp[record.priceStr] ?? 0
                    priceDictBuysTemp[record.priceStr] = record.volume + temp
                }
                self.lastTrade = record
            }

            sells.sort(by: { $0.time > $1.time })
            buys.sort(by: { $0.time > $1.time })

            if sells.count > 50 {
                self.sells = sells.dropLast(sells.count - 45)
            }

            if buys.count > 50 {
                self.buys = buys.dropLast(buys.count - 45)
            }
        }
    }

    func update(_ update: BybitRecentTradeUpdateResponse) {
        let ts = Date().currentTimeMillis()
        if ts - lastMessageTs > 100000 {
            lastTradesBatch = [:]
            lastMessageTs = ts
        }

        for upd in update.data {
            let record = BybitRecentTradeRecord(update: upd)

            lastTrade = record
            lastTradesBatch[record.priceStr] = (volume: record.volume, side: record.side, ts: record.time)

            if record.side == .sell {
                sells.append(record)
                let ecx = priceDictSells[record.priceStr] ?? 0
                priceDictSells[record.priceStr] = record.volume + ecx

                let temp = priceDictSellsTemp[record.priceStr] ?? 0
                priceDictSellsTemp[record.priceStr] = record.volume + temp
            } else {
                buys.append(record)
                let ecx = priceDictBuys[record.priceStr] ?? 0
                priceDictBuys[record.priceStr] = record.volume + ecx

                let temp = priceDictBuysTemp[record.priceStr] ?? 0
                priceDictBuysTemp[record.priceStr] = record.volume + temp
            }

            sells.sort(by: { $0.time > $1.time })
            buys.sort(by: { $0.time > $1.time })

            if sells.count > 50 {
                sells = sells.dropLast(sells.count - 45)
            }

            if buys.count > 50 {
                buys = buys.dropLast(buys.count - 45)
            }
        }
    }
}

class BybitLastTrade: BybitSocketDelegate, ObservableObject {
    var pair: String
    var bybitSocket: BybitSocketTemplate
    var isSubscribed: Bool = false
    let req_id = "10004"

    @Published var data: BybitRecentTradeData!
    let didChange = PassthroughSubject<Void, Never>()
    private var cancellable: AnyCancellable?

    @Published var recentTrades: BybitRecentTradeData! {
        didSet {
            didChange.send()
        }
    }

    init(_ p: String) {
        self.pair = p

        self.bybitSocket = BybitSocketTemplate()
        bybitSocket.delegate = self

        self.cancellable = AnyCancellable($data
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.recentTrades, on: self))

        Task {
            await downloadRecentTradesSnapshot()
        }
    }

    func subscribe(socket: Starscream.WebSocket) {
        let msg = "{\"req_id\":\"\(req_id)\", \"op\": \"subscribe\", \"args\": [ \"publicTrade.\(pair)\" ]}"

        socket.write(string: msg)
    }

    func parseMessage(message: String) {
        do {
            if message == "{\"event\":\"heartbeat\"}" {
                return
            } else if !isSubscribed {
                let subscriptionStatus = try JSONDecoder().decode(BybitSubscriptionStatus.self, from: Data(message.utf8))
                if subscriptionStatus.success && subscriptionStatus.req_id == req_id {
                    isSubscribed = true
                }
            } else if isSubscribed {
                if message.contains("\(BybitRecentTradeUpdateResponse.name).\(pair)") {
                    let update = try JSONDecoder().decode(BybitRecentTradeUpdateResponse.self, from: Data(message.utf8))

//
                    if data != nil {
                        self.data.update(update)
                        DispatchQueue.main.async {
                     
                      
                            self.data.anchor = Date()
                        }
                    }
                }
            }

        } catch {
            LogManager.shared.error("error is \(error.localizedDescription)")
        }
    }

    func downloadRecentTradesSnapshot() async {
        let url = "https://api.bybit.com/v5/market/recent-trade?category=linear&symbol=\(pair)&limit=500"
        guard let url = URL(string: url) else { fatalError("Missing URL") }

        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }

            if response.statusCode == 200 {
                guard let data = data else { return }
                DispatchQueue.main.async {
                    do {
                        let v = try JSONDecoder().decode(BybitTradesHistoryResponse.self, from: data)
                        self.data = BybitRecentTradeData(v.result)
                    } catch {
                        print("Error decoding: ", error)
                    }
                }
            }
        }

        dataTask.resume()
    }
}
