//
//  Bybitbook.swift
//  dashboard
//
//  Created by km on 04/01/2024.
//

import Foundation
import Starscream

class Bybitbook: BybitSocketDelegate, ObservableObject {
    var pair: String
    var depth: Int
    var bybitSocket: BybitSocketTemplate
    var isSubscribed: Bool = false
    
    init(_ p: String, _ d: Int = 50) {
        self.pair = p
        self.depth = d
        self.bybitSocket = BybitSocketTemplate()
        self.bybitSocket.delegate = self
    }
    
    func subscribe(socket: WebSocket) {
        let msg = "{\"req_id\":\"orderbookid\", \"op\": \"subscribe\", \"args\": [ \"orderbook.\(self.depth).\(pair.lowercased())\" ]}"
        socket.write(string: msg)
        print("Subscribed")
    }
    
    func parseMessage(message: String) {
        print("Parse message \(message)")
//        print(message)
//        do {
//            if message == "{\"event\":\"heartbeat\"}" {
//                return
//            } else if isSubscribed {
//                if message == "{\"result\":null,\"id\":\"1\"}" {
//                    isSubscribed = true
//
//
//                }
//            }
//
//        } catch {
//            LogManager.shared.error("error is \(error.localizedDescription)")
//        }
    }
}
