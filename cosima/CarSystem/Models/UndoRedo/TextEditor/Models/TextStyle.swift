//
//  TextStyle.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  文字樣式定義
//

import Foundation

/// 文字樣式 - 使用 OptionSet 支援多重樣式組合
///
/// 一段文字可以同時套用多種樣式，例如「粗體 + 斜體」。
///
/// ## 使用範例
/// ```swift
/// var style: TextStyle = [.bold, .italic]
/// style.insert(.underline)
/// style.contains(.bold)  // true
/// ```
///
struct TextStyle: OptionSet, Hashable, Codable {
    let rawValue: Int
    
    /// 粗體
    static let bold      = TextStyle(rawValue: 1 << 0)
    
    /// 斜體
    static let italic    = TextStyle(rawValue: 1 << 1)
    
    /// 底線
    static let underline = TextStyle(rawValue: 1 << 2)
    
    /// 無樣式
    static let none: TextStyle = []
}

// MARK: - CustomStringConvertible

extension TextStyle: CustomStringConvertible {
    var description: String {
        var styles: [String] = []
        if contains(.bold) { styles.append("粗體") }
        if contains(.italic) { styles.append("斜體") }
        if contains(.underline) { styles.append("底線") }
        return styles.isEmpty ? "無樣式" : styles.joined(separator: "+")
    }
}
