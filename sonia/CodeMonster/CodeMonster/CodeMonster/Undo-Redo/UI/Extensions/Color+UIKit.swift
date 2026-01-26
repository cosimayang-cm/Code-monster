//
//  Color+UIKit.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import UIKit

// MARK: - Color → UIColor Extension

/// 將 Model 層的 Color 轉換為 UIKit 的 UIColor
/// 此擴展放在 UI 層，保持 Model 層不依賴 UIKit
extension Color {
    /// 轉換為 UIColor
    var uiColor: UIColor {
        UIColor(
            red: red,
            green: green,
            blue: blue,
            alpha: alpha
        )
    }
}
