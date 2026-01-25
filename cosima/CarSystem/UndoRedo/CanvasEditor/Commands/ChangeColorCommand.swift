//
//  ChangeColorCommand.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  變更顏色命令
//

import Foundation

/// 變更顏色命令
///
/// 改變圖形的填充色和/或邊框色，支援 Undo/Redo。
///
/// ## 使用範例
/// ```swift
/// // 只改變填充色
/// let command = ChangeColorCommand(canvas: canvas, shapeId: rect.id, newFillColor: .red)
/// history.execute(command)
///
/// // 同時改變填充色和邊框色
/// let command2 = ChangeColorCommand(canvas: canvas, shapeId: rect.id, newFillColor: .blue, newStrokeColor: .black)
/// history.execute(command2)
/// ```
///
final class ChangeColorCommand: Command {
    
    // MARK: - Properties
    
    /// 命令描述
    var description: String { "變更顏色" }
    
    /// 目標畫布
    private let canvas: Canvas
    
    /// 要變更顏色的圖形 ID
    private let shapeId: UUID
    
    /// 新填充色（nil 表示不改變）
    private let newFillColor: Color?
    
    /// 新邊框色（nil 表示不改變）
    private let newStrokeColor: Color?
    
    /// 原始填充色（供 undo 使用）
    private var originalFillColor: Color?
    
    /// 原始邊框色（供 undo 使用）
    private var originalStrokeColor: Color?
    
    // MARK: - Initialization
    
    /// 初始化變更顏色命令
    ///
    /// - Parameters:
    ///   - canvas: 目標畫布
    ///   - shapeId: 要變更顏色的圖形 ID
    ///   - newFillColor: 新填充色（nil 表示不改變）
    ///   - newStrokeColor: 新邊框色（nil 表示不改變）
    init(canvas: Canvas, shapeId: UUID, newFillColor: Color? = nil, newStrokeColor: Color? = nil) {
        self.canvas = canvas
        self.shapeId = shapeId
        self.newFillColor = newFillColor
        self.newStrokeColor = newStrokeColor
    }
    
    // MARK: - Command Protocol
    
    func execute() {
        guard let shape = canvas.shape(withId: shapeId) else { return }
        
        // 保存原始顏色
        originalFillColor = shape.fillColor
        originalStrokeColor = shape.strokeColor
        
        // 套用新顏色
        if let fillColor = newFillColor {
            shape.fillColor = fillColor
        }
        if let strokeColor = newStrokeColor {
            shape.strokeColor = strokeColor
        }
    }
    
    func undo() {
        guard let shape = canvas.shape(withId: shapeId) else { return }
        
        // 還原原始顏色
        if let fillColor = originalFillColor, newFillColor != nil {
            shape.fillColor = fillColor
        }
        if let strokeColor = originalStrokeColor, newStrokeColor != nil {
            shape.strokeColor = strokeColor
        }
    }
}
