//
//  CanvasView.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import UIKit

// MARK: - CanvasViewDelegate

/// CanvasView 事件代理
protocol CanvasViewDelegate: AnyObject {
    /// 當圖形被移動時呼叫
    /// - Parameters:
    ///   - view: CanvasView
    ///   - id: 被移動的圖形 ID
    ///   - offset: 位移量
    func canvasView(_ view: CanvasView, didMoveShape id: UUID, by offset: Point)

    /// 當圖形被選中時呼叫
    /// - Parameters:
    ///   - view: CanvasView
    ///   - id: 被選中的圖形 ID
    func canvasView(_ view: CanvasView, didSelectShape id: UUID)
}

// MARK: - CanvasView

/// 管理多個 ShapeView 的容器視圖
final class CanvasView: UIView {

    // MARK: - Properties

    /// Shape ID → ShapeView 映射
    private var shapeViews: [UUID: ShapeView] = [:]

    /// 畫布事件代理
    weak var delegate: CanvasViewDelegate?

    /// 當前選中的圖形 ID
    private(set) var selectedShapeId: UUID?

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .white
        layer.borderColor = UIColor.systemGray4.cgColor
        layer.borderWidth = 1
        clipsToBounds = true
    }

    // MARK: - Public Methods

    /// 同步 Model Canvas 狀態到 UI
    /// - Parameter canvas: Model 層的 Canvas
    func sync(with canvas: Canvas) {
        // 找出需要移除的 ShapeView
        let currentIds = Set(shapeViews.keys)
        let modelIds = Set(canvas.shapes.map { $0.id })

        // 移除不存在於 Model 的 ShapeView
        for id in currentIds.subtracting(modelIds) {
            removeShapeView(id: id)
        }

        // 新增或更新 ShapeView
        for shape in canvas.shapes {
            if let existingView = shapeViews[shape.id] {
                // 更新現有的 ShapeView
                updateShapeView(existingView, with: shape)
            } else {
                // 新增 ShapeView
                addShapeView(for: shape)
            }
        }
    }

    /// 選中指定圖形
    /// - Parameter id: 圖形 ID，傳入 nil 取消選取
    func selectShape(id: UUID?) {
        // 取消之前的選取樣式
        if let previousId = selectedShapeId, let previousView = shapeViews[previousId] {
            previousView.layer.borderWidth = 0
        }

        selectedShapeId = id

        // 套用新的選取樣式
        if let newId = id, let newView = shapeViews[newId] {
            newView.layer.borderColor = UIColor.systemBlue.cgColor
            newView.layer.borderWidth = 2
        }
    }

    // MARK: - Private Methods

    private func addShapeView(for shape: any Shape) {
        let shapeView = ShapeView(shape: shape)
        shapeView.delegate = self
        shapeViews[shape.id] = shapeView
        addSubview(shapeView)

        // 加入點擊手勢用於選取
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleShapeTap(_:)))
        shapeView.addGestureRecognizer(tapGesture)
    }

    private func removeShapeView(id: UUID) {
        guard let shapeView = shapeViews[id] else { return }
        shapeView.removeFromSuperview()
        shapeViews.removeValue(forKey: id)

        // 如果移除的是選中的圖形，取消選取
        if selectedShapeId == id {
            selectedShapeId = nil
        }
    }

    private func updateShapeView(_ shapeView: ShapeView, with shape: any Shape) {
        shapeView.shape = shape
    }

    // MARK: - Gesture Handling

    @objc private func handleShapeTap(_ gesture: UITapGestureRecognizer) {
        guard let shapeView = gesture.view as? ShapeView else { return }
        selectShape(id: shapeView.shapeId)
        delegate?.canvasView(self, didSelectShape: shapeView.shapeId)
    }
}

// MARK: - ShapeViewDelegate

extension CanvasView: ShapeViewDelegate {
    func shapeView(_ view: ShapeView, didMoveBy offset: Point) {
        delegate?.canvasView(self, didMoveShape: view.shapeId, by: offset)
    }
}
