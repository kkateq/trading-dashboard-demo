//
//  Bybitbook.swift
//  dashboard
//
//  Created by km on 04/01/2024.
//

import Combine
import Foundation
import Starscream

struct BybitSubscriptionStatus: Decodable {
    var success: Bool
    var ret_msg: String
    var conn_id: String
    var req_id: String
    var op: String
}

struct BybitBookNode: Decodable {
    var price: String
    var volume: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        price = try container.decode(String.self)
        volume = try container.decode(String.self)
    }
}

struct BybitUpdateData: Decodable {
    var pair: String
    var bids: [BybitBookNode]
    var asks: [BybitBookNode]
    var updateId: Int
    var crossSequence: Int

    enum CodingKeys: String, CodingKey {
        case pair = "s"
        case bids = "b"
        case asks = "a"
        case updateId = "u"
        case crossSequence = "seq"
    }
}

struct BybitOrderBookUpdateResponse: Decodable {
    static let topicName = "orderbook"
    var topic: String
    var ts: Int
    var type: String
    var data: BybitUpdateData
    var cts: Int
}

struct BybitOrderBookResult: Decodable {
    var pair: String
    var bids: [BybitBookNode]
    var asks: [BybitBookNode]
    var updateId: Int
    var time: Int

    enum CodingKeys: String, CodingKey {
        case pair = "s"
        case bids = "b"
        case asks = "a"
        case updateId = "u"
        case time = "ts"
    }
}

struct BybitOrderBookRecord: Decodable {
    var retCode: Int
    var retMsg: String
    var result: BybitOrderBookResult
    var time: Int
}

enum BybitBookRecordType: String {
    case ask, bid
}

class BybitBookRecord: Identifiable, ObservableObject {
    var id = UUID()
    var price: String
    var volume: String
    var pr: Double
    var vol: Double
    var type: BybitBookRecordType

    init(price: String, volume: String, type: BybitBookRecordType) {
        self.price = price
        pr = Double(price)!
        vol = Double(volume)!
        self.volume = volume
        self.type = type
    }
}

class BybitOrderBook: ObservableObject, Equatable {
    var pair: String
    var lastUpdateId: Int
    let depth: Int = 25

    var id = UUID()
    static func == (lhs: BybitOrderBook, rhs: BybitOrderBook) -> Bool {
        return lhs.id == rhs.id
    }

    @Published var all: [Double: BybitBookRecord]
    @Published var bid_keys = [Double]()
    @Published var ask_keys = [Double]()

    @Published var stats: BybitStats!

    init(_ initialResponse: BybitOrderBookResult) {
        lastUpdateId = initialResponse.updateId
        pair = initialResponse.pair
        all = [:]

        for ask in initialResponse.asks {
            let key = Double(ask.price)!
            all[key] = BybitBookRecord(price: ask.price, volume: ask.volume, type: BybitBookRecordType.ask)
        }
        for bid in initialResponse.bids {
            let key = Double(bid.price)!
            all[key] = BybitBookRecord(price: bid.price, volume: bid.volume, type: BybitBookRecordType.bid)
        }

        let ask_keys_all = all.filter { $0.value.type == BybitBookRecordType.ask }.keys.sorted(by: { $0 < $1 })
        let bid_keys_all = all.filter { $0.value.type == BybitBookRecordType.bid }.keys.sorted(by: { $0 > $1 })
        ask_keys = ask_keys_all.count <= depth ? ask_keys_all : ask_keys_all.dropLast(ask_keys_all.count - depth)
        bid_keys = bid_keys_all.count <= depth ? bid_keys_all : bid_keys_all.dropLast(bid_keys_all.count - depth)

        generateStats()
    }

    func update(_ updateResponse: BybitOrderBookUpdateResponse) {
        if updateResponse.data.pair == pair {
            for ask in updateResponse.data.asks {
                let key = Double(ask.price)!
                all[key] = BybitBookRecord(price: ask.price, volume: ask.volume, type: BybitBookRecordType.ask)
            }
            for bid in updateResponse.data.bids {
                let key = Double(bid.price)!
                all[key] = BybitBookRecord(price: bid.price, volume: bid.volume, type: BybitBookRecordType.bid)
            }

            let ask_keys_all = all.filter { $0.value.type == BybitBookRecordType.ask }.keys.sorted(by: { $0 < $1 })
            let bid_keys_all = all.filter { $0.value.type == BybitBookRecordType.bid }.keys.sorted(by: { $0 > $1 })
            ask_keys = ask_keys_all.count <= depth ? ask_keys_all : ask_keys_all.dropLast(ask_keys_all.count - depth)
            bid_keys = bid_keys_all.count <= depth ? bid_keys_all : bid_keys_all.dropLast(bid_keys_all.count - depth)
            lastUpdateId = updateResponse.data.updateId

            generateStats()
        }
    }

    func generateStats() {
        stats = BybitStats(pair: pair, all: all, bid_keys: bid_keys, ask_keys: ask_keys)
    }

    var allList: [BybitBookRecord] {
        var list: [BybitBookRecord] = []
        for ask_key in ask_keys.reversed() {
            if let ask = all[ask_key] {
                list.append(ask)
            }
        }

        for bid_key in bid_keys {
            if let bid = all[bid_key] {
                list.append(bid)
            }
        }

        return list
    }
}

class Bybitbook: BybitSocketDelegate, ObservableObject {
    var pair: String
    var bybitSocket: BybitSocketTemplate
    var isSubscribed: Bool = false
    let req_id = "10001"
    @Published var data: BybitOrderBook!
    let didChange = PassthroughSubject<Void, Never>()
    private var cancellable: AnyCancellable?

    @Published var book: BybitOrderBook! {
        didSet {
            didChange.send()
        }
    }

    init(_ p: String) {
        pair = p

        bybitSocket = BybitSocketTemplate()
        bybitSocket.delegate = self
        
        Task {
            await downloadInitialBookSnapshot()
        }
        
        cancellable = AnyCancellable($data
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.book, on: self))
    }

    func subscribe(socket: WebSocket) {
        let msg = "{\"req_id\":\"\(req_id)\", \"op\": \"subscribe\", \"args\": [ \"orderbook.50.\(pair)\" ]}"

        socket.write(string: msg)
    }

    func downloadInitialBookSnapshot() async {
        let url = "https://api.bybit.com/v5/market/orderbook?category=spot&symbol=\(pair)&limit200"
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
                        let v = try JSONDecoder().decode(BybitOrderBookRecord.self, from: data)
                        self.data = BybitOrderBook(v.result)
                    } catch {
                        print("Error decoding: ", error)
                    }
                }
            }
        }

        dataTask.resume()
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
                if message.contains(BybitOrderBookUpdateResponse.topicName) {
                    let update = try JSONDecoder().decode(BybitOrderBookUpdateResponse.self, from: Data(message.utf8))

                    DispatchQueue.main.async {
                        if self.data != nil {
                            self.data.update(update)
                        }
                    }
                }
            }

        } catch {
            LogManager.shared.error("error is \(error.localizedDescription)")
        }
    }
}
