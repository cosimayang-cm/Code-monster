//
//  MoveShapeCommand.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  移動圖形命令
//

import Foundation

/// 移動圖形命令
///
/// 改變圖形位置，支援 Undo/Redo。
///
/// ## 使用範例
/// ```swift
/// // circle.position == Point(x: 100, y: 100)
/// let command = MoveShapeCommand(canvas: canvas, shapeId: circle.id, offset: Point(x: 20, y: 30))
/// history.execute(command)  // circle.position == Point(x: 120, y: 130)
/// history.undo()            // circle.position == Point(x: 100, y: 100)
/// ```
///
final class MoveShapeCommand: Command {
    
    // MARK: - Properties
    
    /// 命令描述
    var description: String { "移動圖形" }
    
    /// 目標畫布（weak 避免循環引用）
    private weak var canvas: Canvas?
    
    /// 要移動的圖形 ID
    private let shapeId: UUID
    
    /// 移動偏移量
    private var offset: Point
    
    /// 移動前的位置（execute 後設定，供 undo 使用）
    private var originalPosition: Point?
    
    /// 命令建立時間（用於合併判斷，合併時會更新）
    private(set) var timestamp: Date
    
    // MARK: - Initialization
    
    /// 初始化移動圖形命令
    ///
    /// - Parameters:
    ///   - canvas: 目標畫布
    ///   - shapeId: 要移動的圖形 ID
    ///   - offset: 移動偏移量
    init(canvas: Canvas, shapeId: UUID, offset: Point) {
        self.canvas = canvas
        self.shapeId = shapeId
        self.offset = offset
        self.timestamp = Date()
    }
    
    // MARK: - Command Protocol
    
    func execute() {
        guard let canvas = canvas else {
            UndoRedoLogger.warning("Canvas 已被釋放，無法執行", context: "MoveShapeCommand")
            return
        }
        guard let shape = canvas.shape(withId: shapeId) else {
            UndoRedoLogger.warning("找不到圖形", context: "MoveShapeCommand", details: ["shapeId": shapeId.uuidString])
            return
        }

        // 保存原位置
        if originalPosition == nil {
            originalPosition = shape.position
        }

        // 移動
        shape.position = shape.position.offset(by: offset)

        // 通知 UI 更新
        canvas.notifyShapesChanged()
    }

    func undo() {
        guard let canvas = canvas else {
            UndoRedoLogger.warning("Canvas 已被釋放，無法撤銷", context: "MoveShapeCommand")
            return
        }
        guard let shape = canvas.shape(withId: shapeId) else {
            UndoRedoLogger.warning("找不到圖形，無法撤銷", context: "MoveShapeCommand", details: ["shapeId": shapeId.uuidString])
            return
        }
        guard let original = originalPosition else {
            UndoRedoLogger.warning("無原始位置紀錄，無法撤銷", context: "MoveShapeCommand")
            return
        }

        shape.position = original

        // 通知 UI 更新
        canvas.notifyShapesChanged()
    }
}

// MARK: - CoalescibleCommand

extension MoveShapeCommand: CoalescibleCommand {
    
    /// 嘗試合併連續的移動操作
    ///
    /// 合併條件：
    /// 1. 另一個命令也是 MoveShapeCommand
    /// 2. 操作同一個畫布和圖形
    /// 3. 在時間窗口內
    func coalesce(with command: Command) -> Bool {
        guard let other = command as? MoveShapeCommand,
              other.canvas === self.canvas,
              other.shapeId == self.shapeId,
              isWithinCoalescingWindow(of: other) else {
            return false
        }

        // 合併偏移量
        self.offset = Point(
            x: self.offset.x + other.offset.x,
            y: self.offset.y + other.offset.y
        )

        // 更新時間戳記，確保下一次合併判斷使用最新時間
        self.timestamp = other.timestamp

        return true
    }
}
