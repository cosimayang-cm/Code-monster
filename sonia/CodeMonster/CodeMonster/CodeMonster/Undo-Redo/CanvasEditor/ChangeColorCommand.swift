//
//  ChangeColorCommand.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import Foundation

/// ChangeColorCommand - 變更圖形顏色的命令
/// FR-016: ChangeColorCommand supports changing shape fill/stroke color
final class ChangeColorCommand: Command {

    // MARK: - Properties

    private let canvas: Canvas
    private let shapeId: UUID
    private let newFillColor: Color?
    private let newStrokeColor: Color?
    private var previousFillColor: Color?
    private var previousStrokeColor: Color?

    // MARK: - Command Protocol

    var description: String {
        return "變更顏色"
    }

    // MARK: - Initialization

    /// 建立變更顏色命令
    /// - Parameters:
    ///   - canvas: 目標畫布
    ///   - shapeId: 圖形的 UUID
    ///   - fillColor: 新的填充顏色（nil 表示不變更）
    ///   - strokeColor: 新的邊框顏色（nil 表示不變更）
    init(canvas: Canvas, shapeId: UUID, fillColor: Color? = nil, strokeColor: Color? = nil) {
        self.canvas = canvas
        self.shapeId = shapeId
        self.newFillColor = fillColor
        self.newStrokeColor = strokeColor
    }

    // MARK: - Execute & Undo

    func execute() {
        guard var shape = canvas.shape(withId: shapeId) else { return }

        previousFillColor = shape.fillColor
        previousStrokeColor = shape.strokeColor

        if let fill = newFillColor {
            shape.fillColor = fill
        }
        if let stroke = newStrokeColor {
            shape.strokeColor = stroke
        }

        canvas.updateShape(id: shapeId, with: shape)
    }

    func undo() {
        guard var shape = canvas.shape(withId: shapeId) else { return }

        if let prevFill = previousFillColor {
            shape.fillColor = prevFill
        }
        if let prevStroke = previousStrokeColor {
            shape.strokeColor = prevStroke
        }

        canvas.updateShape(id: shapeId, with: shape)
    }
}
