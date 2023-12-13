//
//  KrakenWS.swift
//  trading_dashboard
//
//  Created by km on 13/12/2023.
//

import Combine
import Foundation
import OrderedCollections
import Starscream

struct WSStatus: Decodable {
    var event: String = ""
    var connectionID: Decimal = 0
    var status: String = "disconnected"
    var version: String = ""
}

struct Subscription: Decodable {
    var depth: Decimal
    var name: String
}

struct ChannelSubscriptionStatus: Decodable {
    var channelID: Decimal
    var channelName: String
    var event: String
    var pair: String
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
    var channelID: Decimal = 0
    var pair: String
    var channelName: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        channelID = try container.decode(Decimal.self)
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
    var channelID: Decimal = 0
    var pair: String
    var channelName: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        channelID = try container.decode(Decimal.self)
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

    @Published var volume: String
    @Published var price: String
    @Published var timestamp: Decimal
    var type: BookRecordType

    init(_ price: String, _ volume: String, _ timestamp: Decimal, _ type: BookRecordType) {
        self.volume = volume
        self.price = price
        self.timestamp = timestamp
        self.type = type
        id = UUID()
    }
}

class OrderBookData: ObservableObject, Equatable {
    @Published var all: OrderedDictionary<Decimal, OrderBookRecord>
    var channelID: Decimal
    var isValid: Bool

    static func == (lhs: OrderBookData, rhs: OrderBookData) -> Bool {
        return lhs.channelID == rhs.channelID
    }

    init(_ response: BookInitialResponse) {
        channelID = response.channelID
        isValid = true
        all = OrderedDictionary()
        
        for ask in response.bookRecord.asks {
            let key = Decimal(string: ask.price)
            all[key!] = OrderBookRecord(ask.price, ask.volume, Decimal(string: ask.timestamp)!, BookRecordType.ask)
        }
        for bid in response.bookRecord.bids {
            let key = Decimal(string: bid.price)
            all[key!] = OrderBookRecord(bid.price, bid.volume, Decimal(string: bid.timestamp)!, BookRecordType.bid)
        }
  
    }

    func verifyChecksum(_ checksum: String) {
        isValid = true
    }

    func update_side(_ records: [PriceRecordResponse], _ type: BookRecordType) {
        for record in records {
            let volume = Decimal(string: record.volume)
            let timestamp = Decimal(string: record.timestamp)
            let key = Decimal(string: record.price)
            if volume == 0 {
                all.removeValue(forKey: key!)
            } else {
                if let prev_record = all[key!] {
                    if prev_record.timestamp < timestamp! {
                        all.updateValue(forKey: key!, default: prev_record) { value in
                            value.volume = record.volume
                            value.timestamp = timestamp!
                            value.type=type
                        }
                    }
                } else {
                    all[key!] = OrderBookRecord(record.price, record.volume, Decimal(string: record.timestamp)!, type)
                }
            }
        }
        all.sort( by: { $0.key > $1.key})
        
        
    }

    func update(_ updateResponse: BookUpdateResponse) {
        if updateResponse.bookRecord.asks != nil {
            update_side(updateResponse.bookRecord.asks, BookRecordType.ask)
        }
        if updateResponse.bookRecord.bids != nil {
            update_side(updateResponse.bookRecord.bids, BookRecordType.bid)
        }

        verifyChecksum(updateResponse.bookRecord.checksum)
    }
}

class KrakenWS: WebSocketDelegate, ObservableObject {
    var socket: WebSocket!
    @Published var isConnected = false
    @Published var isSubscribed = false
    @Published var isBookInitialized = false
    var channelID: Decimal = 0
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
                    channelID = result.channelID
                }
            } else if isSubscribed && !isBookInitialized {
                let result = try decoder.decode(BookInitialResponse.self, from: Data(message.utf8))

                DispatchQueue.main.async {
                    self.data = OrderBookData(result)
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
                print("Received text: \(string)")
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
}
