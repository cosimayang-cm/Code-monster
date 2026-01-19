// MARK: - Popup Chain Contracts
// Feature: 彈窗連鎖顯示機制 (Popup Response Chain)
// Date: 2026-01-16
// This file defines the API contracts for the popup chain feature.

import UIKit
import Combine

// MARK: - Enums

/// 彈窗類型枚舉
/// Priority order (FR-002) 由 handlers 陣列順序決定，無需數字屬性
enum PopupType: String, CaseIterable {
    case tutorial = "tutorial"
    case interstitialAd = "interstitial_ad"
    case newFeature = "new_feature"
    case dailyCheckIn = "daily_check_in"
    case predictionResult = "prediction_result"
}

/// 彈窗顯示結果
enum PopupResult {
    case completed          // 用戶完成彈窗互動
    case dismissed          // 用戶關閉彈窗
    case failed(Error)      // 彈窗顯示失敗
}

/// 彈窗鏈錯誤類型
enum PopupChainError: Error, LocalizedError {
    case maxPopupsReached           // 已達單次 3 個上限 (FR-010)
    case popupDisplayFailed         // 彈窗顯示失敗 (FR-011: 跳過不重試)
    case chainInterrupted           // 鏈被外部中斷
    case storageError(Error)        // UserDefaults 讀寫錯誤

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

// MARK: - Data Models

/// 用戶彈窗狀態（UserDefaults 持久化）
struct PopupUserState: Codable, Equatable {
    var hasSeenTutorial: Bool = false
    var lastCheckInDate: Date?
    var lastAdShownDate: Date?
    var seenFeatureAnnouncements: Set<String> = []
    var notifiedPredictionResults: Set<String> = []

    /// 檢查今日是否已簽到
    func hasCheckedInToday() -> Bool {
        guard let date = lastCheckInDate else { return false }
        return Calendar.current.isDateInToday(date)
    }

    /// 檢查今日是否已顯示廣告 (FR-012)
    func hasShownAdToday() -> Bool {
        guard let date = lastAdShownDate else { return false }
        return Calendar.current.isDateInToday(date)
    }
}

// MARK: - Protocols

/// 彈窗處理器協議
/// 每種彈窗類型實作此協議，定義顯示條件與呈現邏輯
/// 優先順序由 PopupChainManager 的 handlers 陣列順序決定
protocol PopupHandler {
    /// 處理的彈窗類型
    var popupType: PopupType { get }

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

// MARK: - Storage Protocol

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

    private let userDefaults: UserDefaults
    private let storageKey = "com.cosima.popupUserState"

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

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
}

// MARK: - Manager Protocol

/// 彈窗鏈管理器協議
protocol PopupChainManagerProtocol: ObservableObject {
    var currentPopup: PopupType? { get }
    var displayedCount: Int { get }
    var isRunning: Bool { get }

    /// 開始彈窗鏈檢查
    /// - Parameter viewController: 用於呈現彈窗的 ViewController
    /// - Returns: 執行結果
    @discardableResult
    func startChain(on viewController: UIViewController) -> Result<Void, PopupChainError>

    /// 繼續檢查下一個彈窗
    func proceedToNext()

    /// 取消彈窗鏈
    func cancelChain()
}

// MARK: - Manager Implementation Contract

/// 彈窗鏈管理器
/// 負責協調彈窗的依序顯示（FR-001 ~ FR-012）
final class PopupChainManager: ObservableObject, PopupChainManagerProtocol {

    // MARK: - Published Properties

    @Published private(set) var currentPopup: PopupType?
    @Published private(set) var displayedCount: Int = 0
    @Published private(set) var isRunning: Bool = false

    // MARK: - Dependencies

    private let handlers: [PopupHandler]
    private let stateStorage: PopupStateStorageProtocol
    private weak var presentingViewController: UIViewController?

    // MARK: - Constants

    private let maxPopupsPerSession = 3  // FR-010

    // MARK: - State

    private var currentHandlerIndex: Int = 0
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    /// 初始化彈窗鏈管理器
    /// - Parameters:
    ///   - handlers: 彈窗處理器陣列，**陣列順序即優先順序** (FR-002)
    ///   - stateStorage: 狀態存儲服務
    /// - Important: handlers 陣列的順序決定彈窗顯示優先順序，索引越小越優先
    init(handlers: [PopupHandler], stateStorage: PopupStateStorageProtocol = PopupStateStorage()) {
        self.handlers = handlers  // 直接使用傳入順序，不排序
        self.stateStorage = stateStorage
    }

    // MARK: - Public Methods

    @discardableResult
    func startChain(on viewController: UIViewController) -> Result<Void, PopupChainError> {
        guard !isRunning else { return .success(()) }

        presentingViewController = viewController
        displayedCount = 0
        currentHandlerIndex = 0
        isRunning = true

        checkAndDisplayNext()
        return .success(())
    }

    func proceedToNext() {
        currentHandlerIndex += 1
        currentPopup = nil
        checkAndDisplayNext()
    }

    func cancelChain() {
        isRunning = false
        currentPopup = nil
        presentingViewController = nil
    }

    // MARK: - Private Methods

    private func checkAndDisplayNext() {
        // FR-010: 檢查是否達到上限
        guard displayedCount < maxPopupsPerSession else {
            finishChain()
            return
        }

        // FR-007: 檢查是否所有彈窗都已處理
        guard currentHandlerIndex < handlers.count else {
            finishChain()
            return
        }

        guard let viewController = presentingViewController else {
            finishChain()
            return
        }

        let handler = handlers[currentHandlerIndex]
        let state = stateStorage.load()

        // FR-008: 各彈窗獨立判斷顯示條件
        if handler.shouldDisplay(state: state) {
            displayPopup(handler: handler, on: viewController)
        } else {
            // 不符合條件，檢查下一個
            proceedToNext()
        }
    }

    private func displayPopup(handler: PopupHandler, on viewController: UIViewController) {
        currentPopup = handler.popupType

        handler.display(on: viewController) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .completed, .dismissed:
                // 更新狀態並繼續
                handler.updateState(storage: self.stateStorage as! PopupStateStorage)
                self.displayedCount += 1
                self.proceedToNext()

            case .failed:
                // FR-011: 顯示失敗直接跳過，不重試
                self.proceedToNext()
            }
        }
    }

    private func finishChain() {
        isRunning = false
        currentPopup = nil
    }
}
