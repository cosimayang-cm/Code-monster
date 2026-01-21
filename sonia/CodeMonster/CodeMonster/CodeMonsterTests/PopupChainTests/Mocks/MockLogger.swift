import XCTest
@testable import CodeMonster

/// Mock implementation of Logger for testing
public class MockLogger: Logger {
    public struct LogEntry: Equatable {
        public let message: String
        public let level: LogLevel
        public let timestamp: Date

        public init(message: String, level: LogLevel, timestamp: Date = Date()) {
            self.message = message
            self.level = level
            self.timestamp = timestamp
        }
    }

    public var logs: [LogEntry] = []
    public var isLoggingEnabled = true

    public init() {}

    public func log(_ message: String, level: LogLevel) {
        guard isLoggingEnabled else { return }
        logs.append(LogEntry(message: message, level: level))
    }

    // MARK: - Test Helpers

    public func loggedMessages(for level: LogLevel) -> [String] {
        logs.filter { $0.level == level }.map { $0.message }
    }

    public func hasLogged(_ message: String, level: LogLevel) -> Bool {
        logs.contains { $0.message.contains(message) && $0.level == level }
    }

    public func clear() {
        logs.removeAll()
    }

    public func printLogs() {
        for log in logs {
            print("[\(log.level)] \(log.message)")
        }
    }
}
