//
//  PopupHandler.swift
//  CarSystem
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//

import UIKit

/// 彈窗處理器協議
/// 每種彈窗類型實作此協議，定義顯示條件與呈現邏輯
/// 優先順序由 PopupChainManager 的 handlers 陣列順序決定
protocol PopupHandler {

    /// 處理的彈窗類型
    var popupType: PopupType { get }

    /// 用戶關閉（dismissed）此彈窗後是否終止彈窗鏈
    /// - 預設為 false（繼續檢查下一個彈窗）
    /// - 新手教學設為 true（用戶選擇關閉時，不再顯示其他彈窗）
    /// - 注意：只在 dismissed 時生效，completed 仍會繼續彈窗鏈
    var stopsChainOnDismiss: Bool { get }

    /// 判斷是否應該顯示此彈窗
    /// - Parameter state: 用戶彈窗狀態
    /// - Returns: 是否應顯示
    func shouldDisplay(state: PopupUserState) -> Bool

    /// 顯示彈窗
    /// - Parameters:
    ///   - viewController: 用於呈現的 ViewController
    ///   - completion: 完成回調，傳回顯示結果
    func display(on viewController: UIViewController, completion: @escaping (PopupResult) -> Void)

    /// 更新用戶狀態（彈窗顯示後調用）
    /// - Parameter storage: 狀態存儲服務
    func updateState(storage: PopupStateStorage)
}

// MARK: - Default Implementation

extension PopupHandler {
    /// 預設不終止彈窗鏈
    var stopsChainOnDismiss: Bool { false }
}
