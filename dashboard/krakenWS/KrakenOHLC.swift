//
//  KrakenOHLC.swift
//  dashboard
//
//  Created by km on 20/12/2023.
//

import Foundation
import Combine
import Starscream


struct OHLCNode: Equatable, Decodable  {
    var time: Double
    var etime: Double
    var open: Double
    var high: Double
    var low: Double
    var close: Double
    var vwap: Double
    var volume: Double
    var count: Int
    
    
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
    var socket: WebSocket!
    @Published var isConnected = false
    @Published var isSubscribed = false
    var pair: String = ""
    @Published var wsStatus: WSStatus = .init()
    let didChange = PassthroughSubject<Void, Never>()
    var channelID: String!
    private var cancellable: AnyCancellable?
//    private var kraken: Kraken
    
    @Published var ohlc: [Double: OHLCNode]! {
        didSet {
            didChange.send()
        }
    }
    
    
    init(_ p: String) {
        pair = p
    
        cancellable = AnyCancellable($data
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.ohlc, on: self))

        var request = URLRequest(url: URL(string: "wss://ws.kraken.com/")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
    }
    
    func subscribe() {
        let msg = "{\"event\":\"subscribe\",\"pair\":[\"\(pair)\"], \"subscription\":{ \"name\":\"ohlc\"}}"
        socket.write(string: msg)
    }
    
    func fetchInitialOHLC()  async {
//            LogManager.shared.action("Refetch open orders...")
//            let result: KrakenNetwork.KrakenResult = await kraken.openOrders()
//            switch result {
//            case .success(let orders):
//                DispatchQueue.main.async {
////                    var new_orders: [OrderResponse] = []
////                    if let openOrders = orders["open"] {
////                        let dict = openOrders as? [String: AnyObject]
////                        for (key, value) in dict! {
////                            if let descr = value["descr"] {
////                                if let ordertype = value["type"] {
////                                    if let descrDict = descr as? [String: AnyObject] {
////                                        if let order = descrDict["order"] {
////                                            new_orders.append(OrderResponse(txid: key, order: "\(order)", type: "\(ordertype ?? "")"))
////                                        }
////                                    }
////                                }
////                            }
////                        }
////
////                        self.ordersData = new_orders
////                    }
//                }
//
//            case .failure(let error):
//                LogManager.shared.error(error.localizedDescription)
//            }
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
