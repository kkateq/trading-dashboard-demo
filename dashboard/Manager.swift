//
//  OrderManager.swift
//  dashboard
//
//  Created by km on 15/12/2023.
//

import Foundation

struct TokenResponse: Decodable {
    var token: String

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        token = try container.decode(String.self)
    }
}

extension String {
    func utf8DecodedString() -> String {
        let data = self.data(using: .utf8)
        let message = String(data: data!, encoding: .nonLossyASCII) ?? ""
        return message
    }

    func utf8EncodedString() -> String {
        let messageData = data(using: .nonLossyASCII)
        let text = String(data: messageData!, encoding: .utf8) ?? ""
        return text
    }
}

struct OrderResponse: Identifiable {
    var id: String
    var order: String
    var type: String
}

class Manager: ObservableObject {
    private var apiKey: String = "CKQoxz/gPzwrW1+QbTcd8+QUkHOfv8h2AOZXW/jVPVXsEgbqWjIOLNyG"
    private var apiSecret: String = "FjY6MQjTldN4ckdz6wzboCzPMYvdavvr7BHnZKp7S5vUmSBez76vZ8VNNEwZOIbFeN4GkPGQjKAUXDLC/Z4+fg=="
    private var socket_token: String = ""
    private var kraken: Kraken
    @Published var orders: [OrderResponse] = []

    init() {
        let credentials = Kraken.Credentials(apiKey: apiKey, privateKey: apiSecret)

        kraken = Kraken(credentials: credentials)

        refetchOpenOrders()
    }

    func handleOrdersResponse(result: KrakenNetwork.KrakenResult) {
        switch result {
        case .success(let orders):

            if let openOrders = orders["open"] {
                let dict = openOrders as? [String: AnyObject]
                for (key, value) in dict! {
                    if let descr = value["descr"] {
                        if let ordertype = value["type"] {
                            if let descrDict = descr as? [String: AnyObject] {
                                if let order = descrDict["order"] {
                                    self.orders.append(OrderResponse(id: key, order: "\(order)", type: "\(ordertype ?? "")"))
                                }
                            }
                        }
                    }
                }
            }

        case .failure(let error):
            print(error)
        }
    }

    func refetchOpenOrders() {
        kraken.openOrders(completion: handleOrdersResponse)

//        let result = await kraken.serverTime()
//
//        switch result {
//        case .success(let serverTime):
//            print(serverTime["unixtime"]) // 1393056191
//            print(serverTime["rfc1123"]) // "Sun, 13 Mar 2022 08:28:04 GMT"
//        case .failure(let error):
//            print(error)
//        }
    }
}
