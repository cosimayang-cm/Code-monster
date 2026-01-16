import Foundation

/// Log severity levels
enum LogLevel {
    case debug
    case info
    case warning
    case error
}

/// Logs messages for debugging and error tracking.
protocol Logger {
    /// Logs a message at the specified level.
    /// - Parameters:
    ///   - message: The message to log.
    ///   - level: The severity level.
    func log(_ message: String, level: LogLevel)
}

// MARK: - Convenience Extensions

extension Logger {
    func debug(_ message: String) {
        log(message, level: .debug)
    }

    func info(_ message: String) {
        log(message, level: .info)
    }

    func warning(_ message: String) {
        log(message, level: .warning)
    }

    func error(_ message: String) {
        log(message, level: .error)
    }
}
