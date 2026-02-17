// MARK: - StorageClient Contract
// Feature: feature/monster5-tca-uikit-integration
// Date: 2026-02-17

import Foundation
import ComposableArchitecture

// MARK: - StorageClient

/// Local Storage 客戶端
/// 負責互動數據的持久化讀寫（UserDefaults），透過 TCA Dependency 注入
struct StorageClient {
    /// 載入所有文章的互動數據
    /// - Returns: postId → PostInteraction 的映射表
    var loadInteractions: @Sendable () -> [Int: PostInteraction]
    
    /// 儲存所有文章的互動數據
    /// - Parameter interactions: postId → PostInteraction 的映射表
    var saveInteractions: @Sendable ([Int: PostInteraction]) -> Void
}

// MARK: - DependencyKey

extension StorageClient: DependencyKey {
    private static let storageKey = "post_interactions"
    
    /// 真實 UserDefaults 實作
    static let liveValue = StorageClient(
        loadInteractions: {
            guard let data = UserDefaults.standard.data(forKey: storageKey) else {
                return [:]
            }
            do {
                let store = try JSONDecoder().decode(PostInteractionStore.self, from: data)
                return store.interactions
            } catch {
                // 資料損毀時 fallback
                return [:]
            }
        },
        saveInteractions: { interactions in
            let store = PostInteractionStore(interactions: interactions)
            if let data = try? JSONEncoder().encode(store) {
                UserDefaults.standard.set(data, forKey: storageKey)
            }
        }
    )
    
    /// 測試用 in-memory 實作
    static let testValue = StorageClient(
        loadInteractions: { [:] },
        saveInteractions: { _ in }
    )
}

// MARK: - DependencyValues Extension

extension DependencyValues {
    var storageClient: StorageClient {
        get { self[StorageClient.self] }
        set { self[StorageClient.self] = newValue }
    }
}

// MARK: - Storage Model

/// 互動數據儲存容器，用於 JSON 序列化
struct PostInteractionStore: Codable {
    var interactions: [Int: PostInteraction]
}
