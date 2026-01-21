//
//  Logger.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/11.
//

import Foundation

/// 日誌級別
public enum LogLevel {
    case debug
    case info
    case warning
    case error
    
    public var icon: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

/// 日誌協議
public protocol Logger {
    func log(_ message: String, level: LogLevel)
}

/// 控制台日誌實現
public class ConsoleLogger: Logger {
    public init() {}
    
    public func log(_ message: String, level: LogLevel) {
        print("\(level.icon) \(message)")
    }
}
