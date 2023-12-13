//
//  KrakenWS2.swift
//  dashboard
//
//  Created by km on 13/12/2023.
//

import Combine
import Foundation

struct APIResponse: Codable {
    var data: [PriceData]
    var type: String
    private enum CodingKeys: String, CodingKey {
        case data, type
    }
}

struct PriceData: Codable {
    public var p: Float
    private enum CodingKeys: String, CodingKey {
        case p
    }
}

class KrakenWS2: ObservableObject {
    private let urlSession = URLSession(configuration: .default)
    private var webSocketTask: URLSessionWebSocketTask?
    private let baseURL = URL(string: "wss://ws.kraken.com/")!
    let didChange = PassthroughSubject<Void, Never>()
    @Published var data: String = ""

    private var cancellable: AnyCancellable?
    var priceResult: String = "" {
        didSet {
            didChange.send()
        }
    }

    init() {
        cancellable = AnyCancellable($data
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.priceResult, on: self))
    }

    func connect() {
        stop()
        webSocketTask = urlSession.webSocketTask(with: baseURL)
        webSocketTask?.resume()
        sendMessage()
        receiveMessage()
    }

    func stop() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }

    private func sendMessage() {
        let string = "{\"event\":\"subscribe\",\"pair\":[\"MATIC:USD\"], \"subscription\":{ \"name\":\"book\"}}"
        let message = URLSessionWebSocketTask.Message.string(string)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket couldn’t send message because: \(error)")
            }
        }
    }

    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Error in receiving message: \(error)")
            case .success(.string(let str)):
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(APIResponse.self, from: Data(str.utf8))
                    DispatchQueue.main.async {
                        self?.data = "\(result.data)"
                    }
                } catch {
                    print("error is \(error.localizedDescription)")
                }
                self?.receiveMessage()
            default:
                print("default")
            }
        }
    }
}
