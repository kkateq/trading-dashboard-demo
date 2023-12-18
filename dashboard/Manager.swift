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
    var id: UUID = .init()
    var txid: String
    var order: String
    var type: String
}

struct PositionResponse: Identifiable {
    var id: UUID = .init()
    var refid: String
    var pair: String
    var type: String
    var vol: Double
    var cost: Double
    var net: String
    var ordertype: String
    var fee: Double
    var value: Double
    var time: Double
}

class Manager: ObservableObject {
    private var apiKey: String = "YAdPx+LZ+YPxoABmeEdTI+LOe6JlcA9E8w0TI6eW8OiOwQpOQBH0rsnS"
    private var apiSecret: String = "GNsZ3sUrNz+/ZoeLpbAvQzN1f/kRgkftCR/9+kIXXMrLl/KLRQnM1Ml1nWtRJep/06WjOmcz7sk5ezaxr/nUyQ=="
    private var socket_token: String = ""
    private var kraken: Kraken
    @Published var orders: [OrderResponse] = []
    @Published var positions: [PositionResponse] = []

    init() {
        let credentials = Kraken.Credentials(apiKey: apiKey, privateKey: apiSecret)

        kraken = Kraken(credentials: credentials)

        Task {
            await refetchOpenOrders()
            await refetchOpenPositions()
        }
    }

    func handleOrdersResponse(result: KrakenNetwork.KrakenResult) {
        var new_orders: [OrderResponse] = []

        switch result {
        case .success(let orders):

            if let openOrders = orders["open"] {
                let dict = openOrders as? [String: AnyObject]
                for (key, value) in dict! {
                    if let descr = value["descr"] {
                        if let ordertype = value["type"] {
                            if let descrDict = descr as? [String: AnyObject] {
                                if let order = descrDict["order"] {
                                    new_orders.append(OrderResponse(txid: key, order: "\(order)", type: "\(ordertype ?? "")"))
                                }
                            }
                        }
                    }
                }

                DispatchQueue.main.async {
                    self.orders = new_orders
                }
            }

        case .failure(let error):
            print(error)
        }
    }

    func handlePositionsResponse(result: KrakenNetwork.KrakenResult) {
        var new_positions: [PositionResponse] = []

        switch result {
        case .success(let positions):
            if let openOrders = positions["result"] {
                let dict = openOrders as? [String: AnyObject]
                for (key, value) in dict! {
                    print(key)
                    if let pair = value["pair"] as? String,
                       let t = value["type"] as? String,
                       let vol = value["vol"] as? Double,
                       let cost = value["cost"] as? Double,
                       let net = value["net"] as? String,
                       let ordertype = value["ordertype"] as? String,
                       let fee = value["fee"] as? Double,
                       let v = value["value"] as? Double,
                       let tm = value["time"] as? Double
                    {
                        let pos = PositionResponse(refid: key, pair: pair, type: t, vol: vol, cost: cost, net: net, ordertype: ordertype, fee: fee, value: v, time: tm)
                        new_positions.append(pos)
                    }
                }

                DispatchQueue.main.async {
                    self.positions = new_positions
                }
            }

        case .failure(let error):
            print(error)
        }
    }

    func cancelAllOrders() async {
        let result = await kraken.cancelAllOrders()
        switch result {
        case .success(let message):
            if let _ = message["count"] {
                await refetchOpenOrders()
            }
        case .failure(let error):
            print(error)
        }
    }

    func cancelOrder(txid: String) async {
        let result = await kraken.cancelOrder(txid: txid)
        switch result {
        case .success(let message):
            if let _ = message["count"] {
                await refetchOpenOrders()
            }
        case .failure(let error):
            print(error)
        }
    }

    func closePositionMarket(refid: String) async {
        print("Closing position \(refid)")
    }

    func flattenPosition(refid: String) async {
        print("Flattening position \(refid)")
    }

    func refetchOpenPositions() async {
        var new_positions: [PositionResponse] = []
        let result = await kraken.openPositions(docalcs: true)
        switch result {
        case .success(let positions):
            if let openOrders = positions["result"] {
                let dict = openOrders as? [String: AnyObject]
                for (key, value) in dict! {
                    print(key)
                    if let pair = value["pair"] as? String,
                       let t = value["type"] as? String,
                       let vol = value["vol"] as? Double,
                       let cost = value["cost"] as? Double,
                       let net = value["net"] as? String,
                       let ordertype = value["ordertype"] as? String,
                       let fee = value["fee"] as? Double,
                       let v = value["value"] as? Double,
                       let tm = value["time"] as? Double
                    {
                        let pos = PositionResponse(refid: key, pair: pair, type: t, vol: vol, cost: cost, net: net, ordertype: ordertype, fee: fee, value: v, time: tm)
                        new_positions.append(pos)
                    }
                }

                self.positions = new_positions
            }

        case .failure(let error):
            print(error)
        }
    }

    func refetchOpenOrders() async {
        var new_orders: [OrderResponse] = []
        let result: KrakenNetwork.KrakenResult = await kraken.openOrders()
        switch result {
        case .success(let orders):

            if let openOrders = orders["open"] {
                let dict = openOrders as? [String: AnyObject]
                for (key, value) in dict! {
                    if let descr = value["descr"] {
                        if let ordertype = value["type"] {
                            if let descrDict = descr as? [String: AnyObject] {
                                if let order = descrDict["order"] {
                                    new_orders.append(OrderResponse(txid: key, order: "\(order)", type: "\(ordertype ?? "")"))
                                }
                            }
                        }
                    }
                }

                self.orders = new_orders
            }

        case .failure(let error):
            print(error)
        }
    }
}
