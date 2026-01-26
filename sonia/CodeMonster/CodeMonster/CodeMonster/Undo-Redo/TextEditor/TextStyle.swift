//
//  TextStyle.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import Foundation

// MARK: - TextStyle

/// TextStyle - 文字樣式 OptionSet
/// FR-010: Support bold, italic, underline styles
struct TextStyle: OptionSet, Equatable {
    let rawValue: Int

    static let bold = TextStyle(rawValue: 1 << 0)
    static let italic = TextStyle(rawValue: 1 << 1)
    static let underline = TextStyle(rawValue: 1 << 2)

    /// 無樣式
    static let none: TextStyle = []
}

// MARK: - TextStyleRange

/// TextStyleRange - 樣式範圍
/// 記錄某個範圍套用的樣式
struct TextStyleRange: Equatable {
    let range: Range<String.Index>
    let style: TextStyle

    init(range: Range<String.Index>, style: TextStyle) {
        self.range = range
        self.style = style
    }
}
