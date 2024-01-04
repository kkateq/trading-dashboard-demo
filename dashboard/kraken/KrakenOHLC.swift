//
//  KrakenOHLC.swift
//  dashboard
//
//  Created by km on 20/12/2023.
//

import Combine
import Foundation
import Starscream

struct OHLCNode: Equatable, Decodable, Identifiable {
    var id: Double
    var time: Double
    var etime: Double?
    var open: Double
    var high: Double
    var low: Double
    var close: Double
    var vwap: Double
    var volume: Double
    var count: Int

    init(list: [String]) {
        time = Double(list[0])!
        open = Double(list[1])!
        high = Double(list[2])!
        close = Double(list[4])!
        low = Double(list[3])!
        vwap = Double(list[5])!
        volume = Double(list[6])!
        count = Int(list[7])!
        id = round(time)
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        time = try container.decode(Double.self)
        etime = try container.decode(Double.self)
        open = try container.decode(Double.self)
        high = try container.decode(Double.self)
        close = try container.decode(Double.self)
        low = try container.decode(Double.self)
        vwap = try container.decode(Double.self)
        volume = try container.decode(Double.self)
        count = try container.decode(Int.self)
        id = round(time)
    }
}

struct OHLCUpdateResponse: Decodable {
    var nodes: [OHLCNode]
    var pair: String
    var channelID: String
    var channelName: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        channelID = try container.decode(String.self)
        nodes = try container.decode([OHLCNode].self)
        channelName = try container.decode(String.self)
        pair = try container.decode(String.self)
    }
}

struct OHLCInitialResponse: Decodable {
    var records: [String: OHLCNode]
}

class KrakenOHLC: WebSocketDelegate, ObservableObject {
    @Published var data: [Double: OHLCNode] = [:]
    @Published var nodeList = [OHLCNode]()
    var socket: WebSocket!
    @Published var isConnected = false
    @Published var isSubscribed = false
    var pair: String = ""
    var interval: Kraken.OHLCInterval = .i5min
    @Published var wsStatus: KrakenWSStatus = .init()
    let didDataChange = PassthroughSubject<Void, Never>()
    let didListChange = PassthroughSubject<Void, Never>()
    var channelID: String = ""
    private var dataCancellable: AnyCancellable?
    private var nodesCancellable: AnyCancellable?
    
    @Published var ohlc: [Double: OHLCNode]! {
        didSet {
            didDataChange.send()
        }
    }
    
    @Published var nodes: [OHLCNode]! {
        didSet {
            didListChange.send()
        }
    }


    init(_ p: String, _ i: Kraken.OHLCInterval) {
        pair = p
        interval = i
        
        dataCancellable = AnyCancellable($data
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.ohlc, on: self))

        nodesCancellable = AnyCancellable($nodeList
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.nodes, on: self))

        
        initSocket()
        subscribe()

        Task {
//            await fetchInitialOHLC()
        }
    }

    func initSocket() {
        var request = URLRequest(url: URL(string: "wss://ws.kraken.com/")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }

    func subscribe() {
        let msg = "{\"event\":\"subscribe\",\"pair\":[\"\(pair)\"], \"subscription\":{ \"name\":\"ohlc\", \"interval\": \(interval.rawValue)}}"
        socket.write(string: msg)
    }

//    func fetchInitialOHLC() async {
//        LogManager.shared.action("Fetch ohlc for \(pair)...")
//        let result: KrakenNetwork.KrakenResult = await Kraken.shared.ohlcData(pair: pair, interval: interval)
//        switch result {
//        case .success(let result):
//            DispatchQueue.main.async {
//                self.data = [:]
////                if let dataForPair = result[self.pair] {
////                    if let arr = dataForPair as? [AnyObject] {
////                        for entry in arr {
////                            if let ntl  = entry as? [AnyObject] {
//////                                let node = OHLCNode(list: entry as)
//////                                self.data[round(node.time)] = node
////                                print("dsf")
////                            }
////                            
////                        }
////                    }
////                }
//                self.nodeList = self.data.values.sorted(by: { $0.time > $1.time })
//                self.subscribe()
//            }
//
//        case .failure(let error):
//            LogManager.shared.error(error.localizedDescription)
//        }
//    }
//
    func parseTextMessage(message: String) {
        do {
            if message == "{\"event\":\"heartbeat\"}" {
                return
            }
            let decoder = JSONDecoder()
            if wsStatus.status == "disconnected" {
                let result = try decoder.decode(KrakenWSStatus.self, from: Data(message.utf8))
                isConnected = true
//                if result.status == "online" && !isSubscribed {
//                    subscribe()
//                }

                wsStatus = result

            } else if !isSubscribed {
                let result = try decoder.decode(KrakenChannelSubscriptionStatus.self, from: Data(message.utf8))
                if result.status == "subscribed" && result.channelName == "ohlc" && result.pair == pair {
                    isSubscribed = true
                }
            } else if isSubscribed {
                let result = try decoder.decode(OHLCUpdateResponse.self, from: Data(message.utf8))

                DispatchQueue.main.async {
                    for record in result.nodes {
                        self.data[round(record.time)] = record
                    }
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
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("Received data: \(string)")
//            parseTextMessage(message: string)
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
