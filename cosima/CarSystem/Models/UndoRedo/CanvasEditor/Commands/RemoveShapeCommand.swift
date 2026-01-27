//
//  RemoveShapeCommand.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  刪除圖形命令
//

import Foundation

/// 刪除圖形命令
///
/// 從畫布移除圖形，支援 Undo/Redo。
/// 執行時會保存圖形快照及位置，以便 Undo 時還原。
///
/// ## 使用範例
/// ```swift
/// let command = RemoveShapeCommand(canvas: canvas, shapeId: circle.id)
/// history.execute(command)  // 圓形被移除
/// history.undo()            // 圓形還原到原位置
/// ```
///
final class RemoveShapeCommand: Command {
    
    // MARK: - Properties
    
    /// 命令描述
    var description: String { "刪除圖形" }
    
    /// 目標畫布（weak 避免循環引用）
    private weak var canvas: Canvas?

    /// 要移除的圖形 ID
    private let shapeId: UUID

    /// 被移除的圖形快照（execute 後設定，供 undo 使用）
    private var removedSnapshot: ShapeSnapshot?

    /// 被移除圖形在陣列中的位置（execute 後設定，供 undo 使用）
    private var removedIndex: Int?

    // MARK: - Initialization

    /// 初始化刪除圖形命令
    ///
    /// - Parameters:
    ///   - canvas: 目標畫布
    ///   - shapeId: 要移除的圖形 ID
    init(canvas: Canvas, shapeId: UUID) {
        self.canvas = canvas
        self.shapeId = shapeId
    }

    // MARK: - Command Protocol

    func execute() {
        guard let canvas = canvas else {
            UndoRedoLogger.warning("Canvas 已被釋放，無法執行", context: "RemoveShapeCommand")
            return
        }

        // 先保存快照
        if let shape = canvas.shape(withId: shapeId) {
            removedSnapshot = shape.snapshot()
        } else {
            UndoRedoLogger.warning("找不到圖形", context: "RemoveShapeCommand", details: ["shapeId": shapeId.uuidString])
        }

        // 移除並記錄位置
        if let result = canvas.remove(shapeId: shapeId) {
            removedIndex = result.index
        }
    }

    func undo() {
        guard let canvas = canvas else {
            UndoRedoLogger.warning("Canvas 已被釋放，無法撤銷", context: "RemoveShapeCommand")
            return
        }
        guard let snapshot = removedSnapshot else {
            UndoRedoLogger.warning("無快照紀錄，無法撤銷", context: "RemoveShapeCommand")
            return
        }
        guard let index = removedIndex else {
            UndoRedoLogger.warning("無位置紀錄，無法撤銷", context: "RemoveShapeCommand")
            return
        }

        // 從快照還原圖形並插入原位置
        let shape = snapshot.restore()
        canvas.insert(shape, at: index)
    }
}
