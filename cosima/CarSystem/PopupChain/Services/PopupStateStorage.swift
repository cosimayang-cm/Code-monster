//
//  PopupStateStorage.swift
//  CarSystem
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//

import Foundation

/// 彈窗狀態存儲協議（便於測試時 Mock）
protocol PopupStateStorageProtocol {
    func load() -> PopupUserState
    func save(_ state: PopupUserState)
    func markTutorialSeen()
    func markDailyCheckIn()
    func markAdShown()
    func markFeatureSeen(id: String)
    func markPredictionNotified(id: String)
}

/// 彈窗狀態存儲服務（UserDefaults 實作）
final class PopupStateStorage: PopupStateStorageProtocol {

    // MARK: - Properties

    private let userDefaults: UserDefaults
    private let storageKey = "com.cosima.popupUserState"

    // MARK: - Initialization

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Load & Save

    func load() -> PopupUserState {
        guard let data = userDefaults.data(forKey: storageKey),
              let state = try? JSONDecoder().decode(PopupUserState.self, from: data) else {
            return PopupUserState()
        }
        return state
    }

    func save(_ state: PopupUserState) {
        guard let data = try? JSONEncoder().encode(state) else { return }
        userDefaults.set(data, forKey: storageKey)
    }

    // MARK: - Mark Methods

    func markTutorialSeen() {
        var state = load()
        state.hasSeenTutorial = true
        save(state)
    }

    func markDailyCheckIn() {
        var state = load()
        state.lastCheckInDate = Date()
        save(state)
    }

    func markAdShown() {
        var state = load()
        state.lastAdShownDate = Date()
        save(state)
    }

    func markFeatureSeen(id: String) {
        var state = load()
        state.seenFeatureAnnouncements.insert(id)
        save(state)
    }

    func markPredictionNotified(id: String) {
        var state = load()
        state.notifiedPredictionResults.insert(id)
        save(state)
    }

    // MARK: - Reset (for testing)

    func reset() {
        userDefaults.removeObject(forKey: storageKey)
    }
}
