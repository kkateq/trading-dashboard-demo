//
//  LogManager.swift
//  dashboard
//
//  Created by km on 18/12/2023.
//

import SwiftUI
import Combine

enum LogLevel {
    case info, error, warning
}

struct LogMessage: Identifiable, Hashable, Equatable {
    var id: UUID = .init()
    var text: String
    var level: LogLevel
}

class LogManager: ObservableObject {
    let didChange = PassthroughSubject<Void, Never>()
    
    static let shared = LogManager()
    @Published private(set) var logMessages: [LogMessage] = []
    private var cancellable: AnyCancellable?
    
    @Published var messages: [LogMessage] {
        didSet {
            didChange.send()
        }
    }

    init() {
        self.messages = []
        cancellable = AnyCancellable($logMessages
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .assign(to: \.messages, on: self))        
    }

    func log(_ message: String, level: LogLevel) {
        DispatchQueue.main.async {
            self.logMessages.append(LogMessage(text: message, level: level))
        }
    }

    func info(_ message: String, level: LogLevel = LogLevel.info) {
        DispatchQueue.main.async {
            self.logMessages.append(LogMessage(text: message, level: level))
        }
    }

    func error(_ message: String, level: LogLevel = LogLevel.error) {
        DispatchQueue.main.async {
            self.logMessages.append(LogMessage(text: message, level: level))
        }
    }

    func warn(_ message: String, level: LogLevel = LogLevel.warning) {
        DispatchQueue.main.async {
            self.logMessages.append(LogMessage(text: message, level: level))
        }
    }
}
