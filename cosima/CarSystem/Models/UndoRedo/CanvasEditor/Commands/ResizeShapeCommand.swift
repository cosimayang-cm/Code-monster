//
//  ResizeShapeCommand.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  縮放圖形命令
//

import Foundation

/// 縮放圖形命令
///
/// 改變圖形大小，支援 Undo/Redo。
/// 針對不同圖形類型有不同的縮放方式：
/// - Rectangle: 改變 size
/// - Circle: 改變 radius
/// - Line: 改變 endPoint（相對於 startPoint 縮放）
///
/// ## 使用範例
/// ```swift
/// let command = ResizeShapeCommand(canvas: canvas, shapeId: rect.id, newSize: Size(width: 200, height: 150))
/// history.execute(command)
/// history.undo()
/// ```
///
final class ResizeShapeCommand: Command {
    
    // MARK: - Properties
    
    /// 命令描述
    var description: String { "縮放圖形" }
    
    /// 目標畫布（weak 避免循環引用）
    private weak var canvas: Canvas?

    /// 要縮放的圖形 ID
    private let shapeId: UUID
    
    /// 新尺寸（用於矩形）
    private let newSize: Size?
    
    /// 新半徑（用於圓形）
    private let newRadius: Double?
    
    /// 新終點（用於線條）
    private let newEndPoint: Point?
    
    /// 原始尺寸（供 undo 使用）
    private var originalSize: Size?
    
    /// 原始半徑（供 undo 使用）
    private var originalRadius: Double?
    
    /// 原始終點（供 undo 使用）
    private var originalEndPoint: Point?
    
    // MARK: - Initialization
    
    /// 初始化縮放矩形命令
    init(canvas: Canvas, shapeId: UUID, newSize: Size) {
        self.canvas = canvas
        self.shapeId = shapeId
        self.newSize = newSize
        self.newRadius = nil
        self.newEndPoint = nil
    }
    
    /// 初始化縮放圓形命令
    init(canvas: Canvas, shapeId: UUID, newRadius: Double) {
        self.canvas = canvas
        self.shapeId = shapeId
        self.newSize = nil
        self.newRadius = newRadius
        self.newEndPoint = nil
    }
    
    /// 初始化縮放線條命令
    init(canvas: Canvas, shapeId: UUID, newEndPoint: Point) {
        self.canvas = canvas
        self.shapeId = shapeId
        self.newSize = nil
        self.newRadius = nil
        self.newEndPoint = newEndPoint
    }
    
    // MARK: - Command Protocol
    
    func execute() {
        guard let canvas = canvas else {
            UndoRedoLogger.warning("Canvas 已被釋放，無法執行", context: "ResizeShapeCommand")
            return
        }
        guard let shape = canvas.shape(withId: shapeId) else {
            UndoRedoLogger.warning("找不到圖形", context: "ResizeShapeCommand", details: ["shapeId": shapeId.uuidString])
            return
        }

        switch shape {
        case let rect as Rectangle:
            originalSize = rect.size
            if let size = newSize {
                rect.size = size
            }

        case let circle as Circle:
            originalRadius = circle.radius
            if let radius = newRadius {
                circle.radius = radius
            }

        case let line as Line:
            originalEndPoint = line.endPoint
            if let endPoint = newEndPoint {
                line.endPoint = endPoint
            }

        default:
            UndoRedoLogger.warning("不支援的圖形類型", context: "ResizeShapeCommand", details: ["type": String(describing: type(of: shape))])
        }

        // 通知 UI 更新
        canvas.notifyShapesChanged()
    }

    func undo() {
        guard let canvas = canvas else {
            UndoRedoLogger.warning("Canvas 已被釋放，無法撤銷", context: "ResizeShapeCommand")
            return
        }
        guard let shape = canvas.shape(withId: shapeId) else {
            UndoRedoLogger.warning("找不到圖形，無法撤銷", context: "ResizeShapeCommand", details: ["shapeId": shapeId.uuidString])
            return
        }

        switch shape {
        case let rect as Rectangle:
            if let size = originalSize {
                rect.size = size
            }

        case let circle as Circle:
            if let radius = originalRadius {
                circle.radius = radius
            }

        case let line as Line:
            if let endPoint = originalEndPoint {
                line.endPoint = endPoint
            }

        default:
            break
        }

        // 通知 UI 更新
        canvas.notifyShapesChanged()
    }
}
