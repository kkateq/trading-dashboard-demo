//
//  Binancebook.swift
//  dashboard
//
//  Created by km on 02/01/2024.
//

import Charts
import Combine
import Foundation
import Starscream

struct OBRecord: Decodable {
    var price: String
    var volume: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        price = try container.decode(String.self)
        volume = try container.decode(String.self)
    }
}

struct BinanceOrderBookRecord: Decodable {
    var lastUpdateId: Int64
    var bids: [OBRecord]
    var asks: [OBRecord]
}

class BinanceBookRecord: Identifiable, ObservableObject {
    var id = UUID()
    var price: String
    var volume: String
    var pr: Double
    var vol: Double
    var type: BookRecordType

    init(price: String, volume: String, type: BookRecordType) {
        self.price = price
        self.pr = Double(price)!
        self.vol = Double(volume)!
        self.volume = volume
        self.type = type
    }
}

struct BinanceOrderBookUpdate: Decodable {
    var eventType: String
    var bids: [OBRecord]
    var asks: [OBRecord]
    var UID: Int
    var uID: Int
    var symbol: String
    var eventTime: Int

    enum CodingKeys: String, CodingKey {
        case bids = "b"
        case asks = "a"
        case eventType = "e"
        case symbol = "s"
        case eventTime = "E"
        case uID = "u"
        case UID = "U"
    }
}

struct BinanceStats {
    var pair: String
    var totalBidVol: Double = 0
    var totalAskVol: Double = 0
    var totalBidVol5: Double = 0
    var totalAskVol5: Double = 0
    var totalBidVol10: Double = 0
    var totalAskVol10: Double = 0
    var totalBidVolRaw: Double = 0
    var totalAskVolRaw: Double = 0
    var totalBidVol5Raw: Double = 0
    var totalAskVol5Raw: Double = 0
    var totalBidVol10Raw: Double = 0
    var totalAskVol10Raw: Double = 0
    
    var bestBid: Double = 0
    var bestAsk: Double = 0
    var bestBidVolume: Double = 0
    var bestAskVolume: Double = 0
    var maxVolume: Double = 0
    var time: Date
    var ask_bins: NumberBins<Double>
    var bid_bins: NumberBins<Double>
    var ask_groups: [Int: [Array<Double>.Element]]
    var bid_groups: [Int: [Array<Double>.Element]]

    var askVolumeCutOff: Double = 0
    var bidVolumeCutOff: Double = 0
    
    var all: [Double: BinanceBookRecord]
    var bid_keys = [Double]()
    var ask_keys = [Double]()

    init(pair: String, all: [Double: BinanceBookRecord], bid_keys: [Double], ask_keys: [Double]) {
        time = Date()
        self.pair = pair
        self.all = all
        self.bid_keys = bid_keys
        self.ask_keys = ask_keys
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
        
        totalAskVol = getAskVolume()
        totalBidVol = getBidVolume()
        totalAskVol5 = getAskVolume(levels: 5)
        totalBidVol5 = getBidVolume(levels: 5)
        totalAskVol10 = getAskVolume(levels: 10)
        totalBidVol10 = getBidVolume(levels: 10)
        
        totalAskVolRaw = getAskVolume(raw: true)
        totalBidVolRaw = getBidVolume(raw: true)
        totalAskVol5Raw = getAskVolume(levels: 5, raw: true)
        totalBidVol5Raw = getBidVolume(levels: 5, raw: true)
        totalAskVol10Raw = getAskVolume(levels: 10, raw: true)
        totalBidVol10Raw = getBidVolume(levels: 10, raw: true)
        
        bestBid = bid_keys.count > 0 ? all[bid_keys[0]]!.pr : 0.0
        bestAsk = ask_keys.count > 0 ? all[ask_keys[0]]!.pr : 0.0
        bestBidVolume = bid_keys.count > 0 ? all[bid_keys[0]]!.vol : 0.0
        bestAskVolume = ask_keys.count > 0 ? all[ask_keys[0]]!.vol : 0.0
        
        maxVolume = all.values.max(by: { $0.vol < $1.vol })!.vol
    }
    
    func filterAskVolume(_ vol: Double) -> Double {
        return vol >= self.askVolumeCutOff ? 0 : vol
    }

    func filterBidVolume(_ vol: Double) -> Double {
        return vol >= self.bidVolumeCutOff ? 0 : vol
    }
    
    func getBidVolume(levels: Int = 0, raw: Bool = false) -> Double {
        if raw {
            if levels == 0 {
                return bid_keys.reduce(0) { $0 + all[$1]!.vol }
            }
            return bid_keys.prefix(levels).reduce(0) { $0 + all[$1]!.vol }
        } else {
            if levels == 0 {
                return bid_keys.reduce(0) { $0 + filterBidVolume(all[$1]!.vol) }
            }
            return bid_keys.prefix(levels).reduce(0) { $0 + filterBidVolume(all[$1]!.vol) }
        }
    }

    private func getAskVolume(levels: Int = 0, raw: Bool = false) -> Double {
        if raw {
            if levels == 0 {
                return ask_keys.reduce(0) { $0 + all[$1]!.vol }
            }
            return ask_keys.prefix(levels).reduce(0) { $0 + all[$1]!.vol }
        } else {
            if levels == 0 {
                return ask_keys.reduce(0) { $0 + filterAskVolume(all[$1]!.vol) }
            }
            return ask_keys.prefix(levels).reduce(0) { $0 + filterAskVolume(all[$1]!.vol) }
        }
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
    
    var totalAskRawVolumePerc: Double {
        return round((totalAskVolRaw / (totalAskVolRaw + totalBidVolRaw)) * 100)
    }

    var totalBidRawVolumePerc: Double {
        return round((totalBidVolRaw / (totalAskVolRaw + totalBidVolRaw)) * 100)
    }
}

class BinanceOrderBook: ObservableObject, Equatable {
    var id = UUID()
    static func == (lhs: BinanceOrderBook, rhs: BinanceOrderBook) -> Bool {
        return lhs.id == rhs.id
    }

    var lastUpdateId: Int64!
    @Published var prevUpdateID: Int!
    var depth: Int
    var pair: String
    @Published var all: [Double: BinanceBookRecord]
    @Published var bid_keys = [Double]()
    @Published var ask_keys = [Double]()
    @Published var stats: BinanceStats!
    @Published var statsHistory: [BinanceStats] = []
    
    init(_ response: BinanceOrderBookRecord, _ pair: String, _ depth: Int) {
        self.depth = depth
        self.pair = pair

        all = [:]

        initBook(response)
    }
    
    var allList: [BinanceBookRecord] {
        var list: [BinanceBookRecord] = []
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

    func initBook(_ update: BinanceOrderBookRecord) {
        if lastUpdateId == nil {
            lastUpdateId = update.lastUpdateId
            for ask in update.asks {
                let key = Double(ask.price)!
                all[key] = BinanceBookRecord(price: ask.price, volume: ask.volume, type: BookRecordType.ask)
            }
            for bid in update.bids {
                let key = Double(bid.price)!
                all[key] = BinanceBookRecord(price: bid.price, volume: bid.volume, type: BookRecordType.bid)
            }

            let ask_keys_all = all.filter { $0.value.type == BookRecordType.ask }.keys.sorted(by: { $0 < $1 })
            let bid_keys_all = all.filter { $0.value.type == BookRecordType.bid }.keys.sorted(by: { $0 > $1 })
            ask_keys = ask_keys_all
            bid_keys = bid_keys_all
            
            generateStats()
        }
    }

    func update(_ update: BinanceOrderBookUpdate) {
        if (prevUpdateID == nil && lastUpdateId + 1 >= update.UID && update.uID >= lastUpdateId + 1) || (prevUpdateID != nil && update.UID == prevUpdateID + 1) {
            for ask in update.asks {
                let key = Double(ask.price)!
                all[key] = BinanceBookRecord(price: ask.price, volume: ask.volume, type: BookRecordType.ask)
            }
            for bid in update.bids {
                let key = Double(bid.price)!
                all[key] = BinanceBookRecord(price: bid.price, volume: bid.volume, type: BookRecordType.bid)
            }

            let ask_keys_all = all.filter { $0.value.type == BookRecordType.ask }.keys.sorted(by: { $0 < $1 })
            let bid_keys_all = all.filter { $0.value.type == BookRecordType.bid }.keys.sorted(by: { $0 > $1 })
            ask_keys = ask_keys_all
            bid_keys = bid_keys_all
            prevUpdateID = update.uID
            
            generateStats()
        }
        
    }
    
    func generateStats() {
        let newStats = BinanceStats(pair: pair, all: all, bid_keys: bid_keys, ask_keys: ask_keys)
      
        stats = newStats
        statsHistory.append(newStats)
        if statsHistory.count > 1500 {
            statsHistory = statsHistory.suffix(750)
        }
    }
}

// How to manage a local order book correctly
// Open a stream to wss://stream.binance.com:9443/ws/bnbbtc@depth.
// Buffer the events you receive from the stream.
// Get a depth snapshot from https://api.binance.com/api/v3/depth?symbol=BNBBTC&limit=1000 .
// Drop any event where u is <= lastUpdateId in the snapshot.
// The first processed event should have U <= lastUpdateId+1 AND u >= lastUpdateId+1.
// While listening to the stream, each new event's U should be equal to the previous event's u+1.
// The data in each event is the absolute quantity for a price level.
// If the quantity is 0, remove the price level.
// Receiving an event that removes a price level that is not in your local order book can happen and is normal.
// Note: Due to depth snapshots having a limit on the number of price levels, a price level outside of the initial snapshot that doesn't have a quantity change won't have an update in the Diff. Depth Stream. Consequently, those price levels will not be visible in the local order book even when applying all updates from the Diff. Depth Stream correctly and cause the local order book to have some slight differences with the real order book. However, for most use cases the depth limit of 5000 is enough to understand the market and trade effectively.

class Binancebook: WebSocketDelegate, ObservableObject {
    var pair: String
    var depth: Int = 10
    var socket: WebSocket!
    @Published var data: BinanceOrderBook!
    var lastUpdateId: Int = -1
    let didChange = PassthroughSubject<Void, Never>()
    private var cancellable: AnyCancellable?

    @Published var isConnected = false
    @Published var isSubscribed = false

    @Published var book: BinanceOrderBook! {
        didSet {
            didChange.send()
        }
    }

    init(_ p: String, _ d: Int = 10) {
        pair = p.replacingOccurrences(of: "/", with: "")
        depth = d
        print(pair)

        cancellable = AnyCancellable($data
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.book, on: self))

        connectToWS()
    }

    func connectToWS() {
        var request = URLRequest(url: URL(string: "wss://stream.binance.com:9443/ws")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }

    func subscribe() {
        if isConnected && !isSubscribed {
            let msg = "{\"id\":\"1\", \"method\": \"SUBSCRIBE\", \"params\": [ \"\(pair.lowercased())@depth@100ms\" ]}"
            socket.write(string: msg)
        }
    }

    func parseTextMessage(message: String) {
        do {
            if message == "{\"event\":\"heartbeat\"}" {
                return
            } else if isConnected && !isSubscribed {
                if message == "{\"result\":null,\"id\":\"1\"}" {
                    isSubscribed = true

                    Task {
                        await downloadInitialBookSnapshot()
                    }
                }
            } else {
                
                let update = try JSONDecoder().decode(BinanceOrderBookUpdate.self, from: Data(message.utf8))
                if self.data != nil {
                    DispatchQueue.main.async {
                        self.data.update(update)
                    }
                }
            }

        } catch {
            LogManager.shared.error("error is \(error.localizedDescription)")
        }
    }

    func downloadInitialBookSnapshot() async {
        let url = "https://api.binance.com/api/v3/depth?symbol=\(pair)&limit=1000"
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
                        let v = try JSONDecoder().decode(BinanceOrderBookRecord.self, from: data)
                        self.data = BinanceOrderBook(v, self.pair, self.depth)
                    } catch {
                        print("Error decoding: ", error)
                    }
                }
            }
        }

        dataTask.resume()
    }

    func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            DispatchQueue.main.async {
                self.isConnected = true
                self.subscribe()
            }
            LogManager.shared.info("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            DispatchQueue.main.async {
                self.isConnected = false
            }

            LogManager.shared.info("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
//                print("Received text: \(string)")

            parseTextMessage(message: string)
        case .binary(let data):
            LogManager.shared.info("Received data: \(data.count)")
        case .ping:
            break
        case .pong:
            break
        case .viabilityChanged:
            break
        case .reconnectSuggested:
            break
        case .cancelled:
            LogManager.shared.info("Cancelled connection")
        case .error(let error):

            handleError(error)
        case .peerClosed:
            break
        }
    }

    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            LogManager.shared.error("websocket encountered an error: \(e.message)")
        } else if let e = error {
            LogManager.shared.error("websocket encountered an error: \(e.localizedDescription)")
        } else {
            LogManager.shared.error("websocket encountered an error")
        }
    }
}
