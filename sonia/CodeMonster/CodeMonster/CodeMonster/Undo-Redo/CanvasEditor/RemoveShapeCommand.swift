//
//  RemoveShapeCommand.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import Foundation

/// RemoveShapeCommand - 移除圖形的命令
/// FR-013: RemoveShapeCommand supports removing shapes from canvas
final class RemoveShapeCommand: Command {

    // MARK: - Properties

    private let canvas: Canvas
    private let shapeId: UUID
    private var removedShape: (any Shape)?
    private var removedIndex: Int?

    // MARK: - Command Protocol

    var description: String {
        return "移除圖形"
    }

    // MARK: - Initialization

    init(canvas: Canvas, shapeId: UUID) {
        self.canvas = canvas
        self.shapeId = shapeId
    }

    // MARK: - Execute & Undo

    func execute() {
        removedIndex = canvas.index(of: shapeId)
        removedShape = canvas.remove(id: shapeId)
    }

    func undo() {
        guard let shape = removedShape, let index = removedIndex else { return }
        canvas.insert(shape, at: index)
    }
}
