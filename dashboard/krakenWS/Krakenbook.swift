//
//  KrakenWS.swift
//  trading_dashboard
//
//  Created by km on 13/12/2023.
//

import Charts
import Combine
import CryptoSwift
import Foundation
import Starscream

struct WSStatus: Decodable {
    var event: String = ""
    var connectionID: Double = 0
    var status: String = "disconnected"
    var version: String = ""
}

struct Subscription: Decodable {
    var depth: Double?
    var name: String
}

struct ChannelSubscriptionStatus: Decodable {
    var channelID: Double?
    var channelName: String
    var event: String
    var pair: String?
    var status: String
    var subscription: Subscription
}

struct PriceRecordResponse: Decodable {
    var volume: String
    var price: String
    var timestamp: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        price = try container.decode(String.self)
        volume = try container.decode(String.self)
        timestamp = try container.decode(String.self)
    }
}

struct BookRecordResponse: Decodable {
    var bids: [PriceRecordResponse]
    var asks: [PriceRecordResponse]

    enum CodingKeys: String, CodingKey {
        case bids = "bs"
        case asks = "as"
    }
}

struct BookInitialResponse: Decodable {
    var bookRecord: BookRecordResponse! = nil
    var channelID: Double = 0
    var pair: String
    var channelName: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        channelID = try container.decode(Double.self)
        bookRecord = try container.decode(BookRecordResponse.self)
        channelName = try container.decode(String.self)
        pair = try container.decode(String.self)
    }
}

struct BookUpdateRecordResponse: Decodable {
    var bids: [PriceRecordResponse]!
    var asks: [PriceRecordResponse]!
    var checksum: String

    enum CodingKeys: String, CodingKey {
        case bids = "b"
        case asks = "a"
        case checksum = "c"
    }
}

struct BookUpdateResponse: Decodable {
    var bookRecord: BookUpdateRecordResponse! = nil
    var channelID: Double = 0
    var pair: String
    var channelName: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        channelID = try container.decode(Double.self)
        bookRecord = try container.decode(BookUpdateRecordResponse.self)
        channelName = try container.decode(String.self)
        pair = try container.decode(String.self)
    }
}

enum BookRecordType: String {
    case ask, bid
}

class OrderBookRecord: Identifiable, ObservableObject {
    var id: UUID

    var volume: String
    var vol: Double
    var price: String
    var pr: Double
    var timestamp: Double
    var type: BookRecordType

    init(_ price: String, _ volume: String, _ timestamp: Double, _ type: BookRecordType) {
        self.volume = volume
        self.price = price
        self.timestamp = timestamp
        self.type = type
        vol = Double(volume)!
        pr = Double(price)!
        id = UUID()
    }
}

struct VolumeDistributionElement {
    var index: Int
    var range: ChartBinRange<Double>
    var frequency: Int
}

struct Stats {
    var pair: String
    var totalBidVol: Double
    var totalAskVol: Double

    var bestBid: Double
    var bestAsk: Double
    var bestBidVolume: Double
    var bestAskVolume: Double
    var maxVolume: Double
    var time: Date
    var ask_bins: NumberBins<Double>
    var bid_bins: NumberBins<Double>
    var ask_groups: [Int: [Array<Double>.Element]]
    var bid_groups: [Int: [Array<Double>.Element]]

    var askVolumeCutOff: Double = 0
    var bidVolumeCutOff: Double = 0

    init(pair: String, all: [Double: OrderBookRecord], bid_keys: [Double], ask_keys: [Double]) {
        time = Date()
        self.pair = pair
        let ask_volumes = ask_keys.map { all[$0]!.vol }

        ask_bins = NumberBins(
            data: ask_volumes,
            desiredCount: 3
        )
        ask_groups = Dictionary(
            grouping: ask_volumes,
            by: ask_bins.index
        )

        let bid_volumes = bid_keys.map { all[$0]!.vol }

        bid_bins = NumberBins(
            data: bid_volumes,
            desiredCount: 3
        )

        bid_groups = Dictionary(
            grouping: bid_volumes,
            by: bid_bins.index
        )
        
        if let avVol = Constants.pairSettings[pair] {
            if ask_groups.values.count > 0 {
                askVolumeCutOff = ask_groups.suffix(1)[0].value[0]

                if askVolumeCutOff < avVol.averageVolume {
                    askVolumeCutOff = Constants.pairSettings[pair]!.averageVolume
                }
            }

            if bid_groups.values.count > 0 {
                bidVolumeCutOff = bid_groups.suffix(1)[0].value[0]

                if bidVolumeCutOff < avVol.averageVolume {
                    bidVolumeCutOff = Constants.pairSettings[pair]!.averageVolume
                }
            }
        }

        totalAskVol = ask_keys.reduce(0) { $0 + all[$1]!.vol }
        totalBidVol = bid_keys.reduce(0) { $0 + all[$1]!.vol }
        bestBid = bid_keys.count > 0 ? all[bid_keys[0]]!.pr : 0.0
        bestAsk = ask_keys.count > 0 ? all[ask_keys[0]]!.pr : 0.0
        bestBidVolume = bid_keys.count > 0 ? all[bid_keys[0]]!.vol : 0.0
        bestAskVolume = ask_keys.count > 0 ? all[ask_keys[0]]!.vol : 0.0

        maxVolume = all.values.max(by: { $0.vol < $1.vol })!.vol
    }

    var pegValue: Double {
        return (bestBid + bestAsk) / 2
    }

    var totalAskVolumePerc: Double {
        return round((totalAskVol / (totalAskVol + totalBidVol)) * 100)
    }

    var totalBidVolumePerc: Double {
        return round((totalBidVol / (totalAskVol + totalBidVol)) * 100)
    }
}

class OrderBookData: ObservableObject, Equatable {
    var channelID: Double
    var depth: Int
    var pair: String

    @Published var all: [Double: OrderBookRecord]
    @Published var bid_keys = [Double]()
    @Published var ask_keys = [Double]()
    @Published var isValid: Bool
    @Published var recentPeg: Double!
    @Published var statsHistory: [Stats] = []
    @Published var stats: Stats!

    var allList: [OrderBookRecord] {
        var list: [OrderBookRecord] = []
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

    func getBidVolume(levels: Int) -> Double {
        if levels == 0 {
            return 0
        }
        return bid_keys.prefix(levels).reduce(0) { $0 + all[$1]!.vol }
    }

    func getAskVolume(levels: Int) -> Double {
        return ask_keys.prefix(levels).reduce(0) { $0 + all[$1]!.vol }
    }

    func generateStats() {
        let newStats = Stats(pair: pair, all: all, bid_keys: bid_keys, ask_keys: ask_keys)
        if let recentStats = stats {
            recentPeg = recentStats.pegValue
        }
        stats = newStats
        statsHistory.append(newStats)
        if statsHistory.count > 1500 {
            statsHistory = statsHistory.suffix(750)
        }
    }

    static func == (lhs: OrderBookData, rhs: OrderBookData) -> Bool {
        return lhs.channelID == rhs.channelID
    }

    init(response: BookInitialResponse, depth: Int, pair: String) {
        channelID = 0
        isValid = true
        self.depth = depth
        self.pair = pair
        all = [:]

        channelID = response.channelID

        for ask in response.bookRecord.asks {
            let key = Double(ask.price)!
            all[key] = OrderBookRecord(ask.price, ask.volume, Double(ask.timestamp)!, BookRecordType.ask)
        }
        for bid in response.bookRecord.bids {
            let key = Double(bid.price)!
            all[key] = OrderBookRecord(bid.price, bid.volume, Double(bid.timestamp)!, BookRecordType.bid)
        }
        generateStats()
    }

    func parseValue(p: String) -> String {
        return "\(Decimal(string: p.replacingOccurrences(of: ".", with: ""))!)"
    }

    func verifyChecksum(_ checksum: String) -> Bool {
        let ask_top_10_keys = ask_keys[...9]
        let bid_top_10_keys = bid_keys[...9]
        var str = ""
        for ask_key in ask_top_10_keys {
            if let ask_entry = all[ask_key] {
                let apr = parseValue(p: ask_entry.price)
                let apv = parseValue(p: ask_entry.volume)
                str += apr + apv
            }
        }
        for bid_key in bid_top_10_keys {
            if let bid_entry = all[bid_key] {
                let bpr = parseValue(p: bid_entry.price)
                let bpv = parseValue(p: bid_entry.volume)
                str += bpr + bpv
            }
        }

        let checksum_str = String(format: "%02X", UInt64(checksum)!).lowercased()
        let hash = str.crc32()

        let res = hash == checksum_str

        return res
    }

    func update_side(_ records: [PriceRecordResponse], _ type: BookRecordType) {
        for record in records {
            let volume = Double(record.volume)
            let timestamp = Double(record.timestamp)!
            let key = Double(record.price)!

            if volume == 0 {
                all.removeValue(forKey: key)
            } else {
                if let prev_record = all[key] {
                    if prev_record.timestamp < timestamp {
                        all[key] = OrderBookRecord(record.price, record.volume, timestamp, type)
                    }
                } else {
                    all[key] = OrderBookRecord(record.price, record.volume, timestamp, type)
                }
            }
        }

        let ask_keys_all = all.filter { $0.value.type == BookRecordType.ask }.keys.sorted(by: { $0 < $1 })
        let bid_keys_all = all.filter { $0.value.type == BookRecordType.bid }.keys.sorted(by: { $0 > $1 })
        ask_keys = ask_keys_all.count <= depth ? ask_keys_all : ask_keys_all.dropLast(ask_keys_all.count - depth)
        bid_keys = bid_keys_all.count <= depth ? bid_keys_all : bid_keys_all.dropLast(bid_keys_all.count - depth)
    }

    func update(_ updateResponse: BookUpdateResponse) {
        if updateResponse.bookRecord.asks != nil {
            update_side(updateResponse.bookRecord.asks, BookRecordType.ask)
        }
        if updateResponse.bookRecord.bids != nil {
            update_side(updateResponse.bookRecord.bids, BookRecordType.bid)
        }

        isValid = verifyChecksum(updateResponse.bookRecord.checksum)

        generateStats()
    }
}

class Krakenbook: WebSocketDelegate, ObservableObject {
    var socket: WebSocket!
    @Published var isConnected = false
    @Published var isSubscribed = false
    @Published var isBookInitialized = false
    var channelID: Double = 0
    var pair: String = ""
    var depth: Int = 10
    @Published var data: OrderBookData! = nil
    @Published var wsStatus: WSStatus = .init()
    let didChange = PassthroughSubject<Void, Never>()

    private var cancellable: AnyCancellable?

    @Published var book: OrderBookData! {
        didSet {
            didChange.send()
        }
    }

    init(_ p: String, _ d: Int = 10) {
        pair = p
        depth = d

        cancellable = AnyCancellable($data
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.book, on: self))

        var request = URLRequest(url: URL(string: "wss://ws.kraken.com/")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }

    func subscribe() {
        let msg = "{\"event\":\"subscribe\",\"pair\":[\"\(pair)\"], \"subscription\":{ \"name\":\"book\", \"depth\": \(depth)}}"
        socket.write(string: msg)
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
                if result.status == "subscribed" && result.channelName == "book-\(depth)" && result.pair == pair {
                    isSubscribed = true
                    channelID = result.channelID!
                }
            } else if isSubscribed && !isBookInitialized {
                let result = try decoder.decode(BookInitialResponse.self, from: Data(message.utf8))

                DispatchQueue.main.async {
                    self.data = OrderBookData(response: result, depth: self.depth, pair: self.pair)
                }
                isBookInitialized = true
            } else if isSubscribed && isBookInitialized {
                let book_update = try decoder.decode(BookUpdateResponse.self, from: Data(message.utf8))

                DispatchQueue.main.async {
                    self.data.update(book_update)
                }
            }
        } catch {
            print("error is \(error.localizedDescription)")
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
//                print("Received text: \(string)")
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
