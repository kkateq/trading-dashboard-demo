//
//  BybitRestApi.swift
//  dashboard
//
//  Created by km on 09/01/2024.
//

import Foundation

extension Dictionary {
    /// Convert Dictionary to JSON string
    /// - Throws: exception if dictionary cannot be converted to JSON data or when data cannot be converted to UTF8 string
    /// - Returns: JSON string
    func toJson() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self)
        if let string = String(data: data, encoding: .utf8) {
            return string
        }
        throw NSError(domain: "Dictionary", code: 1, userInfo: ["message": "Data cannot be converted to .utf8 string"])
    }
}

enum BybitRestApi {
    /// Encodes a Dictionary of parameters to a URL-friendly String
    /// - Parameter params: The parameters for the API endpoint
    /// - Returns: A String containing all parameters
    private static func encode(params: [String: String]) -> String {
        var urlComponents = URLComponents()
        var parameters: [URLQueryItem] = []
        let parametersDictionary = params

        for (key, value) in parametersDictionary {
            let newParameter = URLQueryItem(name: key, value: value)
            parameters.append(newParameter)
        }

        urlComponents.queryItems = parameters
        return urlComponents.url?.query ?? ""
    }

    private static func paramsToJson(params: [String: Any] = [:]) -> String {
        do {
            return try params.toJson()
        } catch {
            print("Error converting params to json")
        }

        return ""
    }
    
    private static func fetchPublic(cb: @escaping (Data) -> Void, route: String, params: [String: String] = [:]) async {
        let query = encode(params: params)
        let url = "https://api.bybit.com/v5\(route)?\(query)"
        guard let url = URL(string: url) else { fatalError("Missing URL") }
      
        let urlRequest = URLRequest(url: url)
        let session = URLSession.shared

        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Request error: ", error)
                return
            }
            
//            let p = String(decoding: data!, as: UTF8.self)

            guard let response = response as? HTTPURLResponse else { return }

            if response.statusCode == 200 {
                guard let data = data else { return }

                cb(data)
            }
        }
        dataTask.resume()
    }
    
    private static func fetchPrivate(cb: @escaping (Data) -> Void, route: String, params: [String: String] = [:]) async {
        let query = encode(params: params)
        let url = "https://api.bybit.com/v5\(route)?\(query)"
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
            
//            let p = String(decoding: data!, as: UTF8.self)

            guard let response = response as? HTTPURLResponse else { return }

            if response.statusCode == 200 {
                guard let data = data else { return }

                cb(data)
            }
        }
        dataTask.resume()
    }

    private static func postPrivate(cb: @escaping (Data) -> Void, route: String, params: [String: Any] = [:]) async {
        let url = "https://api.bybit.com/v5\(route)"
        guard let url = URL(string: url) else { fatalError("Missing URL") }
        let timestamp = String(format: "%.0f", Date().timeIntervalSince1970 * 1000)
        let recv_window = 5000
        let urlParams = paramsToJson(params: params)
        let str = "\(timestamp)\(KeychainHandler.BybitApiKey)\(recv_window)\(urlParams)"
        let signature = generateSignature(api_secret: KeychainHandler.BybitApiSecret, value: str)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("2", forHTTPHeaderField: "X-BAPI-SIGN-TYPE")
        urlRequest.setValue(signature, forHTTPHeaderField: "X-BAPI-SIGN")
        urlRequest.setValue(KeychainHandler.BybitApiKey, forHTTPHeaderField: "X-BAPI-API-KEY")
        urlRequest.setValue(timestamp, forHTTPHeaderField: "X-BAPI-TIMESTAMP")
        urlRequest.setValue("\(recv_window)", forHTTPHeaderField: "X-BAPI-RECV-WINDOW")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = urlParams.data(using: .utf8)

        let session = URLSession.shared
        let dataTask = session.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print("Request error: ", error)
                return
            }
//
//            let p = String(decoding: data!, as: UTF8.self)

            guard let response = response as? HTTPURLResponse else { return }

            if response.statusCode == 200 {
                guard let data = data else { return }

                cb(data)
            }
        }
        dataTask.resume()
    }

    static func fetchPositions(cb: @escaping (Data) -> Void, symbol: String) async {
        LogManager.shared.action("Refetch positions...")

        await fetchPrivate(cb: cb, route: "/position/list", params: ["category": "linear", "symbol": symbol])
    }

    static func fetchOrders(cb: @escaping (Data) -> Void, symbol: String) async {
        LogManager.shared.action("Refetch orders...")

        await fetchPrivate(cb: cb, route: "/order/realtime", params: ["category": "linear", "symbol": symbol])
    }

    static func fetchTradingBalance(cb: @escaping (Data) -> Void) async {
        LogManager.shared.action("Refetch trading account balance...")

        await fetchPrivate(cb: cb, route: "/account/wallet-balance", params: ["accountType": "UNIFIED", "coin": "USDT"])
    }

    static func cancelAllOrders(cb: @escaping (Data) -> Void, symbol: String) async {
        LogManager.shared.action("Cancel all orders...")

        await postPrivate(cb: cb, route: "/order/cancel-all", params: ["category": "linear", "symbol": symbol])
    }

    static func cancelOrder(cb: @escaping (Data) -> Void, orderId: String, symbol: String) async {
        LogManager.shared.action("Cancel order \(orderId)")

        await postPrivate(cb: cb, route: "/order/cancel", params: ["category": "linear", "symbol": symbol, "orderId": orderId])
    }

    static func createOrder(cb: @escaping (Data) -> Void, params: [String: Any]) async {
        await postPrivate(cb: cb, route: "/order/create", params: params)
    }
    
    static func openInterest(cb: @escaping (Data) -> Void, symbol: String) async {
        LogManager.shared.action("Fetch open interest...")

        await fetchPublic(cb: cb, route: "/market/open-interest", params: ["symbol": symbol, "category": "linear", "interval": "5min"])
    }
    
    static func instrumentInfo(cb: @escaping (Data) -> Void, symbol: String) async {
        LogManager.shared.action("Fetch instrument info...")

        await fetchPublic(cb: cb, route: "/market/instruments-info", params: ["symbol": symbol, "category": "linear"])
    }
    
}
