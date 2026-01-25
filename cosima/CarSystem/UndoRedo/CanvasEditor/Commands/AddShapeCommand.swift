//
//  AddShapeCommand.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  新增圖形命令
//

import Foundation

/// 新增圖形命令
///
/// 在畫布上新增圖形，支援 Undo/Redo。
///
/// ## 使用範例
/// ```swift
/// let circle = Circle(position: Point(x: 100, y: 100), radius: 50)
/// let command = AddShapeCommand(canvas: canvas, shape: circle)
/// history.execute(command)  // 畫布上出現圓形
/// history.undo()            // 圓形被移除
/// ```
///
final class AddShapeCommand: Command {
    
    // MARK: - Properties
    
    /// 命令描述
    var description: String { "新增\(shape.typeName)" }
    
    /// 目標畫布
    private let canvas: Canvas
    
    /// 要新增的圖形
    private let shape: Shape
    
    // MARK: - Initialization
    
    /// 初始化新增圖形命令
    ///
    /// - Parameters:
    ///   - canvas: 目標畫布
    ///   - shape: 要新增的圖形
    init(canvas: Canvas, shape: Shape) {
        self.canvas = canvas
        self.shape = shape
    }
    
    // MARK: - Command Protocol
    
    func execute() {
        canvas.add(shape)
    }
    
    func undo() {
        canvas.remove(shapeId: shape.id)
    }
}
