//
//  Binancebook.swift
//  dashboard
//
//  Created by km on 02/01/2024.
//

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

class BinanceBookRecord {
    var price: String
    var volume: String
    var type: BookRecordType

    init(price: String, volume: String, type: BookRecordType) {
        self.price = price
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

class BinanceOrderBook: ObservableObject, Equatable {
    var id = UUID()
    static func == (lhs: BinanceOrderBook, rhs: BinanceOrderBook) -> Bool {
        return lhs.id == rhs.id
    }

    var lastUpdateId: Int64!
    var prevUpdateID: Int!
    var depth: Int
    var pair: String
    @Published var all: [Double: BinanceBookRecord]
    @Published var bid_keys = [Double]()
    @Published var ask_keys = [Double]()

    init(_ response: BinanceOrderBookRecord, _ pair: String, _ depth: Int) {
        self.depth = depth
        self.pair = pair

        all = [:]

        initBook(response)
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
        }
    }

    func update(_ update: BinanceOrderBookUpdate) {
        if (prevUpdateID == nil && lastUpdateId + 1 >= update.UID && update.uID >= lastUpdateId + 1) || (prevUpdateID != nil && update.uID == prevUpdateID + 1) {
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
                    data.update(update)
                }
            }

        } catch {
            LogManager.shared.error("error is \(error.localizedDescription)")
        }
    }

    func updateOrderBook(_ update: BinanceOrderBookRecord) {}

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
