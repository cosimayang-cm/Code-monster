//
//  CommandHistoryObserver.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import Foundation

// MARK: - FR-025: CommandHistoryObserver Protocol

/// 觀察 CommandHistory 狀態變化的協議
/// 當 CommandHistory 執行 execute(), undo(), redo() 時會通知所有觀察者
///
/// Usage:
/// ```swift
/// class MyViewController: UIViewController, CommandHistoryObserver {
///     private let history = CommandHistory()
///
///     override func viewDidLoad() {
///         super.viewDidLoad()
///         history.addObserver(self)
///     }
///
///     deinit {
///         history.removeObserver(self)
///     }
///
///     func commandHistoryDidChange(_ history: CommandHistory) {
///         undoButton.isEnabled = history.canUndo
///         redoButton.isEnabled = history.canRedo
///     }
/// }
/// ```
protocol CommandHistoryObserver: AnyObject {
    /// 當 CommandHistory 狀態變化時被呼叫
    /// - Parameter history: 發生變化的 CommandHistory 實例
    func commandHistoryDidChange(_ history: CommandHistory)
}

// MARK: - FR-027: WeakCommandHistoryObserver Wrapper

/// 弱引用包裝器，避免 CommandHistory 強引用 Observer 造成循環引用
///
/// 說明：
/// - 使用 struct 包裝 weak reference 是 Swift 常見模式
/// - 當 Observer 被釋放時，weak var 自動變成 nil
/// - CommandHistory 在通知時會自動清理 nil 的 observers
struct WeakCommandHistoryObserver {
    /// 弱引用的觀察者，避免循環引用
    weak var observer: CommandHistoryObserver?

    init(_ observer: CommandHistoryObserver) {
        self.observer = observer
    }
}
