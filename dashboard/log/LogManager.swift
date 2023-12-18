//
//  LogManager.swift
//  dashboard
//
//  Created by km on 18/12/2023.
//

import SwiftUI


enum LogLevel {
    case info, error, warning
}
struct LogMessage: Identifiable, Hashable {
    var id: UUID = UUID()
    var text: String
    var level: LogLevel
}

class LogManager: ObservableObject {
    static let shared = LogManager()
    @Published private(set) var logMessages: [LogMessage] = []

    func log(_ message: String, level: LogLevel) {
        logMessages.append(LogMessage(text: message, level: level))
    }
    
    func info(_ message: String, level: LogLevel = LogLevel.info) {
        logMessages.append(LogMessage(text: message, level: level))
    }
    
    func error(_ message: String, level: LogLevel = LogLevel.error) {
        logMessages.append(LogMessage(text: message, level: level))
    }
    
    func warn(_ message: String, level: LogLevel = LogLevel.warning) {
        logMessages.append(LogMessage(text: message, level: level))
    }
}
