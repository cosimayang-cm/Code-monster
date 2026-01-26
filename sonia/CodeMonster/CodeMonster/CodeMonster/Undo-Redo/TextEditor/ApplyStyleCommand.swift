//
//  ApplyStyleCommand.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import Foundation

/// ApplyStyleCommand - 套用樣式的命令
/// FR-010: ApplyStyleCommand supports applying bold/italic/underline styles
final class ApplyStyleCommand: Command {

    // MARK: - Properties

    private let document: TextDocument
    private let range: Range<String.Index>
    private let style: TextStyle
    private var previousStyles: [TextStyleRange] = []

    // MARK: - Command Protocol

    var description: String {
        var styleNames: [String] = []
        if style.contains(.bold) { styleNames.append("粗體") }
        if style.contains(.italic) { styleNames.append("斜體") }
        if style.contains(.underline) { styleNames.append("底線") }
        return "套用\(styleNames.joined(separator: "、"))"
    }

    // MARK: - Initialization

    /// 建立套用樣式命令
    /// - Parameters:
    ///   - document: 目標文件
    ///   - range: 要套用樣式的範圍
    ///   - style: 要套用的樣式
    init(document: TextDocument, range: Range<String.Index>, style: TextStyle) {
        self.document = document
        self.range = range
        self.style = style
    }

    // MARK: - Execute & Undo

    func execute() {
        // 記錄之前的樣式狀態
        previousStyles = document.styles.filter { styleRange in
            styleRange.range.overlaps(range)
        }
        document.applyStyle(style, to: range)
    }

    func undo() {
        document.removeStyle(style, from: range)
        // 還原之前的樣式
        for styleRange in previousStyles {
            document.applyStyle(styleRange.style, to: styleRange.range)
        }
    }
}