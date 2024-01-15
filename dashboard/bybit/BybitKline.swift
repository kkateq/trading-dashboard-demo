////
////  BybitInstrumentStats.swift
////  dashboard
////
////  Created by km on 15/01/2024.
////
//
//import Combine
//import Foundation
//import Starscream
//
//struct BybitKlineNode: Decodable {
//    var startTime: String
//    var openPrice: String
//    var highPrice: String
//    var lowPrice: String
//    var closePrice: String
//    var volume: String
//    var turnover: String
//}
//
//struct BybitKline: Decodable {
//    
//}
//
//struct BybitKlineSocketResponse: Decodable {
//    var topic: String
//    var data:
//}
//
//class BybitKline: BybitSocketDelegate, ObservableObject {
//    var pair: String
//    var bybitSocket: BybitSocketTemplate
//    var isSubscribed: Bool = false
//    
//    let didChangeOpenInterest = PassthroughSubject<Void, Never>()
//    private var cancellableOpenInterest: AnyCancellable?
//    @Published var lastNode:BybitTickerDataResponse!
//    @Published var data: [BybitTickerDataResponse] = []
//    @Published var history: [BybitTickerDataResponse] {
//        didSet {
//            didChangeOpenInterest.send()
//        }
//    }
//    
//    init(pair: String) {
//        self.pair = pair
//        self.history = []
//        
//        self.bybitSocket = BybitSocketTemplate()
//        bybitSocket.delegate = self
//        
//        self.cancellableOpenInterest = AnyCancellable($data
//            .debounce(for: 0.5, scheduler: DispatchQueue.main)
//            .assign(to: \.history, on: self))
//    }
//    
//    func subscribe(socket: Starscream.WebSocket) {
//        let msg = "{\"op\": \"subscribe\", \"args\": [ \"tickers.\(pair)\" ]}"
//
//        socket.write(string: msg)
//    }
//    
//    func parseMessage(message: String) {
//        do {
//            if message == "{\"event\":\"heartbeat\"}" {
//                return
//            } else if !isSubscribed {
//                let subscriptionStatus = try JSONDecoder().decode(BybitSubscriptionStatus.self, from: Data(message.utf8))
//                if subscriptionStatus.success {
//                    isSubscribed = true
//                }
//            } else if isSubscribed {
//                if message.contains("tickers.\(pair)") {
//                    print(message)
//                    let update = try JSONDecoder().decode(BybitTickerDataResponse.self, from: Data(message.utf8))
//                    
//
//                    DispatchQueue.main.async {
//                        self.data = self.data + [update]
//                        
//                    }
//                }
//            }
//
//        } catch {
//            LogManager.shared.error("error is \(error.localizedDescription)")
//        }
//    }
//    
//    func fetchKline() async {
//        await BybitRestApi.getKline(cb: {
//            do {
//                let res = try JSONDecoder().decode(BybitListRestBase<BybitOpenInterest>.self, from: $0)
//
//                if res.retCode == 0 {
//
//                    DispatchQueue.main.async {
//                        self.openInterestData = res.result.list
//                    }
//
//                } else {
//                    LogManager.shared.error(" retCode\(res.retMsg)")
//                }
//            } catch {
//                LogManager.shared.error("error is \(error.localizedDescription)")
//            }
//        }, symbol: self.pair)
//    }
//}
