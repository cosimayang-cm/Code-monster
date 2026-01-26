//
//  RemoveStyleCommand.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import Foundation

/// RemoveStyleCommand - 移除樣式的命令
/// 支援樣式 toggle 功能
final class RemoveStyleCommand: Command {

    // MARK: - Properties

    private let document: TextDocument
    private let range: Range<String.Index>
    private let style: TextStyle

    // MARK: - Command Protocol

    var description: String {
        var styleNames: [String] = []
        if style.contains(.bold) { styleNames.append("粗體") }
        if style.contains(.italic) { styleNames.append("斜體") }
        if style.contains(.underline) { styleNames.append("底線") }
        return "移除\(styleNames.joined(separator: "、"))"
    }

    // MARK: - Initialization

    /// 建立移除樣式命令
    /// - Parameters:
    ///   - document: 目標文件
    ///   - range: 要移除樣式的範圍
    ///   - style: 要移除的樣式
    init(document: TextDocument, range: Range<String.Index>, style: TextStyle) {
        self.document = document
        self.range = range
        self.style = style
    }

    // MARK: - Execute & Undo

    func execute() {
        document.removeStyle(style, from: range)
    }

    func undo() {
        document.applyStyle(style, to: range)
    }
}
