//
//  UndoRedoLogger.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  日誌工具
//

import Foundation
import OSLog

/// Undo/Redo 系統專用日誌工具
///
/// 使用 Apple 的 os_log 系統，提供統一的日誌介面。
/// 日誌可在 Console.app 中以 subsystem "com.cosima.UndoRedo" 過濾查看。
///
/// ## 使用範例
/// ```swift
/// UndoRedoLogger.warning("找不到圖形", context: "MoveShapeCommand", details: ["shapeId": id])
/// UndoRedoLogger.error("Canvas 已被釋放", context: "AddShapeCommand")
/// ```
///
enum UndoRedoLogger {

    // MARK: - Private

    private static let logger = Logger(subsystem: "com.cosima.UndoRedo", category: "Command")

    // MARK: - Public Methods

    /// 記錄除錯訊息
    static func debug(_ message: String, context: String? = nil) {
        let formatted = formatMessage(message, context: context)
        logger.debug("\(formatted)")
    }

    /// 記錄一般資訊
    static func info(_ message: String, context: String? = nil) {
        let formatted = formatMessage(message, context: context)
        logger.info("\(formatted)")
    }

    /// 記錄警告（操作失敗但不影響系統穩定）
    static func warning(_ message: String, context: String? = nil, details: [String: Any]? = nil) {
        let formatted = formatMessage(message, context: context, details: details)
        logger.warning("\(formatted)")
    }

    /// 記錄錯誤（可能影響功能正常運作）
    static func error(_ message: String, context: String? = nil, details: [String: Any]? = nil) {
        let formatted = formatMessage(message, context: context, details: details)
        logger.error("\(formatted)")
    }

    // MARK: - Private Methods

    private static func formatMessage(_ message: String, context: String? = nil, details: [String: Any]? = nil) -> String {
        var result = ""

        if let context = context {
            result += "[\(context)] "
        }

        result += message

        if let details = details, !details.isEmpty {
            let detailsString = details.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            result += " (\(detailsString))"
        }

        return result
    }
}
