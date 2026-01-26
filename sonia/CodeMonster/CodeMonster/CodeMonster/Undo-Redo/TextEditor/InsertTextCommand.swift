//
//  InsertTextCommand.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import Foundation

/// InsertTextCommand - 插入文字的命令
/// FR-007: InsertTextCommand supports inserting text at specified position
/// FR-019: Supports coalescing for consecutive insertions
final class InsertTextCommand: Command, CoalescibleCommand {

    // MARK: - Properties

    private let document: TextDocument
    private(set) var text: String
    private let insertIndex: String.Index

    // MARK: - Command Protocol

    var description: String {
        return "插入文字"
    }

    // MARK: - CoalescibleCommand Protocol

    var coalescingTimeout: TimeInterval { return 1.0 }
    var lastExecutionTime: Date = Date()

    // MARK: - Initialization

    /// 建立插入文字命令
    /// - Parameters:
    ///   - document: 目標文件
    ///   - text: 要插入的文字
    ///   - at: 插入位置
    init(document: TextDocument, text: String, at index: String.Index) {
        self.document = document
        self.text = text
        self.insertIndex = index
    }

    // MARK: - Execute & Undo

    func execute() {
        document.insert(text, at: insertIndex)
    }

    func undo() {
        // 計算插入後的結束位置
        let endIndex = document.content.index(insertIndex, offsetBy: text.count)
        document.delete(range: insertIndex..<endIndex)
    }

    // MARK: - Coalescing

    /// 嘗試與另一個命令合併（連續插入合併）
    func coalesce(with other: Command) -> Bool {
        guard let otherInsert = other as? InsertTextCommand,
              otherInsert.document === document else {
            return false
        }

        // 檢查是否是連續插入（新插入位置 = 當前插入位置 + 當前文字長度）
        let expectedNextIndex = document.content.index(insertIndex, offsetBy: text.count)
        guard otherInsert.insertIndex == expectedNextIndex else {
            return false
        }

        // 合併文字
        text += otherInsert.text
        return true
    }
}
