//
//  TextEditorViewModel.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  文字編輯器 ViewModel
//

import Foundation
import Combine

/// 文字編輯器 ViewModel
///
/// 封裝 `TextDocument` 和 `CommandHistory`，提供 UI 綁定介面。
/// 負責將使用者操作轉換為對應的 Command 並執行。
///
/// ## 使用範例
/// ```swift
/// let viewModel = TextEditorViewModel()
///
/// // UI 綁定
/// viewModel.$content.sink { print("內容: \($0)") }
/// viewModel.$canUndo.sink { undoButton.isEnabled = $0 }
///
/// // 執行操作
/// viewModel.insertText("Hello", at: 0)
/// viewModel.undo()
/// ```
///
final class TextEditorViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI 綁定)
    
    /// 文件內容
    @Published private(set) var content: String = ""
    
    /// 樣式範圍
    @Published private(set) var styleRanges: [StyleRange] = []
    
    /// 是否可以 Undo
    @Published private(set) var canUndo: Bool = false
    
    /// 是否可以 Redo
    @Published private(set) var canRedo: Bool = false
    
    /// Undo 按鈕顯示文字
    @Published private(set) var undoButtonTitle: String = "Undo"
    
    /// Redo 按鈕顯示文字
    @Published private(set) var redoButtonTitle: String = "Redo"
    
    // MARK: - Private Properties
    
    /// 文件模型
    private let document: TextDocument
    
    /// 命令歷史
    private let history: CommandHistory
    
    /// Combine 訂閱管理
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// 初始化 ViewModel
    ///
    /// - Parameters:
    ///   - document: 文件模型（預設建立新文件）
    ///   - history: 命令歷史（預設建立新歷史）
    init(document: TextDocument = TextDocument(), history: CommandHistory = CommandHistory()) {
        self.document = document
        self.history = history
        
        setupBindings()
    }
    
    // MARK: - Text Operations
    
    /// 插入文字
    ///
    /// - Parameters:
    ///   - text: 要插入的文字
    ///   - position: 插入位置
    func insertText(_ text: String, at position: Int) {
        let command = InsertTextCommand(document: document, text: text, position: position)
        history.execute(command)
    }
    
    /// 刪除文字
    ///
    /// - Parameter range: 要刪除的範圍
    func deleteText(range: Range<Int>) {
        let command = DeleteTextCommand(document: document, range: range)
        history.execute(command)
    }
    
    /// 取代文字
    ///
    /// - Parameters:
    ///   - range: 要取代的範圍
    ///   - newText: 新的文字
    func replaceText(range: Range<Int>, with newText: String) {
        let command = ReplaceTextCommand(document: document, range: range, newText: newText)
        history.execute(command)
    }
    
    /// 套用樣式
    ///
    /// - Parameters:
    ///   - style: 要套用的樣式
    ///   - range: 套用範圍
    func applyStyle(_ style: TextStyle, to range: Range<Int>) {
        let command = ApplyStyleCommand(document: document, style: style, range: range)
        history.execute(command)
    }
    
    // MARK: - Undo/Redo
    
    /// 撤銷
    func undo() {
        history.undo()
    }
    
    /// 重做
    func redo() {
        history.redo()
    }
    
    /// 清除歷史
    func clearHistory() {
        history.clear()
    }
    
    // MARK: - Document Operations
    
    /// 清空文件
    func clearDocument() {
        if !content.isEmpty {
            deleteText(range: 0..<content.count)
        }
    }
    
    /// 設定文件內容（不記錄到歷史）
    func setContent(_ newContent: String) {
        // 使用 Memento 直接設定，不產生 Command
        let memento = TextDocumentMemento(content: newContent, styleRanges: [], timestamp: Date())
        document.restore(from: memento)
        history.clear()
    }
    
    // MARK: - Private Methods
    
    /// 設定資料綁定
    private func setupBindings() {
        // 綁定 Document
        document.$content
            .assign(to: &$content)
        
        document.$styleRanges
            .assign(to: &$styleRanges)
        
        // 綁定 History
        history.$canUndo
            .assign(to: &$canUndo)
        
        history.$canRedo
            .assign(to: &$canRedo)
        
        // Undo 按鈕標題
        history.$undoDescription
            .map { desc in
                if let desc = desc {
                    return "Undo \(desc)"
                }
                return "Undo"
            }
            .assign(to: &$undoButtonTitle)
        
        // Redo 按鈕標題
        history.$redoDescription
            .map { desc in
                if let desc = desc {
                    return "Redo \(desc)"
                }
                return "Redo"
            }
            .assign(to: &$redoButtonTitle)
    }
}
