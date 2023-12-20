//
//  KrakenOHLC.swift
//  dashboard
//
//  Created by km on 20/12/2023.
//

import Foundation
import Combine
import Starscream

struct OHLCData: Equatable, Decodable {
    
}

class KrakenOHLC: WebSocketDelegate, ObservableObject {
   
    var socket: WebSocket!
    @Published var isConnected = false
    @Published var isSubscribed = false
    var pair: String = ""
    @Published var data: OHLCData! = nil
    @Published var wsStatus: WSStatus = .init()
    let didChange = PassthroughSubject<Void, Never>()
    
    private var cancellable: AnyCancellable?

    @Published var ohlc: OHLCData! {
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
                let result = try decoder.decode(OHLCData.self, from: Data(message.utf8))

                DispatchQueue.main.async {
                    self.data = result
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
