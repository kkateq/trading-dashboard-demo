//
//  BybitRestApi.swift
//  dashboard
//
//  Created by km on 09/01/2024.
//

import Foundation

class BybitRestApi {
    internal static func constractGetUrl(_ url: String, _ query: String) -> String {
        return "https://api.bybit.com/v5\(url)?\(query)"
    }

    internal static func fetchPrivate(cb: @escaping (Data) -> Void, url: String, query: String = "") async {
        let url = constractGetUrl(url, query)
        guard let url = URL(string: url) else { fatalError("Missing URL") }
        let timestamp = String(format: "%.0f", Date().timeIntervalSince1970 * 1000)
        let recv_window = 5000
        let str = "\(timestamp)\(KeychainHandler.BybitApiKey)\(recv_window)\(query)"
        let signature = generateSignature(api_secret: KeychainHandler.BybitApiSecret, value: str)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("2", forHTTPHeaderField: "X-BAPI-SIGN-TYPE")
        urlRequest.setValue(signature, forHTTPHeaderField: "X-BAPI-SIGN")
        urlRequest.setValue(KeychainHandler.BybitApiKey, forHTTPHeaderField: "X-BAPI-API-KEY")
        urlRequest.setValue(timestamp, forHTTPHeaderField: "X-BAPI-TIMESTAMP")
        urlRequest.setValue("\(recv_window)", forHTTPHeaderField: "X-BAPI-RECV-WINDOW")

        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse else { return }

            if response.statusCode == 200 {
                guard let data = data else { return }

                cb(data)
            }
        }
        dataTask.resume()
    }

    static func fetchPositions(cb: @escaping (Data) -> Void) async {
        LogManager.shared.action("Refetch positions...")

        await fetchPrivate(cb: cb, url: "/position/list", query: "category=spot")
    }
    
    static func fetchOrders(cb: @escaping (Data) -> Void) async {
        LogManager.shared.action("Refetch orders...")

        await fetchPrivate(cb: cb, url: "/order/realtime", query: "category=spot")
    }
    
    static func fetchTradingBalance(cb: @escaping (Data) -> Void) async {
        LogManager.shared.action("Refetch trading account balance...")

        await fetchPrivate(cb: cb, url: "/account/wallet-balance", query: "accountType=UNIFIED")
    }
    
    static func cancellAllOrders(cb: @escaping (Data) -> Void) async {
        LogManager.shared.action("Cancel all orders...")
        
        await fetchPrivate(cb: cb, url: "/order/cancel-all", query: "category=spot")
    }
   
}
