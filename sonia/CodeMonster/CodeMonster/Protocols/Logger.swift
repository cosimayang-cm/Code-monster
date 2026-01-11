//
//  Logger.swift
//  CodeMonster
//
//  Created by Sonia Wu on 2026/1/11.
//

import Foundation

/// 日誌級別
enum LogLevel {
    case debug
    case info
    case warning
    case error
    
    var icon: String {
        switch self {
        case .debug: return "🔍"
        case .info: return "ℹ️"
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

/// 日誌協議
protocol Logger {
    func log(_ message: String, level: LogLevel)
}

/// 控制台日誌實現
class ConsoleLogger: Logger {
    func log(_ message: String, level: LogLevel) {
        print("\(level.icon) \(message)")
    }
}

/// 靜默日誌（用於測試）
class SilentLogger: Logger {
    func log(_ message: String, level: LogLevel) {
        // 不輸出任何內容
    }
}
