//
//  PopupChainManager.swift
//  CarSystem
//
//  Created by PopupChain Feature
//  彈窗連鎖顯示機制 (Popup Response Chain)
//

import UIKit
import Combine

/// 彈窗鏈管理器協議
protocol PopupChainManagerProtocol: ObservableObject {
    var currentPopup: PopupType? { get }
    var displayedCount: Int { get }
    var isRunning: Bool { get }

    @discardableResult
    func startChain(on viewController: UIViewController) -> Result<Void, PopupChainError>
    func proceedToNext()
    func cancelChain()
}

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

    /// 單次進入主畫面最多顯示 3 個彈窗 (FR-010)
    private let maxPopupsPerSession = 3

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

    /// 開始彈窗鏈檢查 (FR-001)
    /// - Parameter viewController: 用於呈現彈窗的 ViewController
    /// - Returns: 執行結果
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

    /// 繼續檢查下一個彈窗 (FR-004)
    func proceedToNext() {
        currentHandlerIndex += 1
        currentPopup = nil
        checkAndDisplayNext()
    }

    /// 取消彈窗鏈
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
                if let storage = self.stateStorage as? PopupStateStorage {
                    handler.updateState(storage: storage)
                }
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
