//
//  PopupChainError.swift
//  CarSystem
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//

import Foundation

/// 彈窗鏈錯誤類型
enum PopupChainError: Error, LocalizedError {
    /// 已達單次 3 個上限 (FR-010)
    case maxPopupsReached

    /// 彈窗顯示失敗 (FR-011: 跳過不重試)
    case popupDisplayFailed

    /// 鏈被外部中斷
    case chainInterrupted

    /// UserDefaults 讀寫錯誤
    case storageError(Error)

    var errorDescription: String? {
        switch self {
        case .maxPopupsReached:
            return "已達本次彈窗顯示上限"
        case .popupDisplayFailed:
            return "彈窗顯示失敗"
        case .chainInterrupted:
            return "彈窗流程被中斷"
        case .storageError(let error):
            return "狀態存儲錯誤: \(error.localizedDescription)"
        }
    }
}
