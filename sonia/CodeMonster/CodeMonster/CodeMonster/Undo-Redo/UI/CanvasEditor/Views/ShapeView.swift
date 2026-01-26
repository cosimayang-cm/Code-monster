//
//  ShapeView.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import UIKit

// MARK: - ShapeViewDelegate

/// ShapeView 拖曳事件代理
protocol ShapeViewDelegate: AnyObject {
    /// 當圖形被拖曳移動時呼叫
    /// - Parameters:
    ///   - view: 被拖曳的 ShapeView
    ///   - offset: 總位移量
    func shapeView(_ view: ShapeView, didMoveBy offset: Point)
}

// MARK: - ShapeView

/// 繪製單一圖形的 UIView
/// 支援 Rectangle, Circle, Line 三種圖形類型
final class ShapeView: UIView {

    // MARK: - Properties

    /// 對應的 Shape ID
    let shapeId: UUID

    /// 圖形資料
    var shape: any Shape {
        didSet {
            setNeedsDisplay()
            updateFrame()
        }
    }

    /// 拖曳事件代理
    weak var delegate: ShapeViewDelegate?

    // MARK: - Private Properties

    /// 拖曳開始時的位置
    private var dragStartPosition: CGPoint = .zero

    /// 累積的拖曳位移
    private var totalTranslation: CGPoint = .zero

    // MARK: - Initialization

    init(shape: any Shape) {
        self.shapeId = shape.id
        self.shape = shape
        super.init(frame: .zero)
        setupView()
        updateFrame()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupView() {
        backgroundColor = .clear
        isUserInteractionEnabled = true

        // 加入拖曳手勢
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }

    private func updateFrame() {
        switch shape {
        case let rect as Rectangle:
            frame = CGRect(
                x: rect.position.x,
                y: rect.position.y,
                width: rect.size.width,
                height: rect.size.height
            )

        case let circle as Circle:
            // 圓形 position 是圓心，frame 需要調整
            let diameter = circle.radius * 2
            frame = CGRect(
                x: circle.position.x - circle.radius,
                y: circle.position.y - circle.radius,
                width: diameter,
                height: diameter
            )

        case let line as Line:
            // 線條的 frame 包含起點和終點
            let minX = min(line.position.x, line.endPoint.x)
            let minY = min(line.position.y, line.endPoint.y)
            let maxX = max(line.position.x, line.endPoint.x)
            let maxY = max(line.position.y, line.endPoint.y)
            frame = CGRect(
                x: minX,
                y: minY,
                width: max(maxX - minX, 10),  // 最小寬度 10
                height: max(maxY - minY, 10)  // 最小高度 10
            )

        default:
            break
        }
    }

    // MARK: - Drawing

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        switch shape {
        case let rectangle as Rectangle:
            drawRectangle(rectangle, in: context, rect: rect)

        case let circle as Circle:
            drawCircle(circle, in: context, rect: rect)

        case let line as Line:
            drawLine(line, in: context, rect: rect)

        default:
            break
        }
    }

    private func drawRectangle(_ rectangle: Rectangle, in context: CGContext, rect: CGRect) {
        // 填充
        context.setFillColor(rectangle.fillColor.uiColor.cgColor)
        context.fill(rect)

        // 邊框
        context.setStrokeColor(rectangle.strokeColor.uiColor.cgColor)
        context.setLineWidth(2)
        context.stroke(rect)
    }

    private func drawCircle(_ circle: Circle, in context: CGContext, rect: CGRect) {
        let circleRect = rect.insetBy(dx: 1, dy: 1)  // 留邊框空間

        // 填充
        context.setFillColor(circle.fillColor.uiColor.cgColor)
        context.fillEllipse(in: circleRect)

        // 邊框
        context.setStrokeColor(circle.strokeColor.uiColor.cgColor)
        context.setLineWidth(2)
        context.strokeEllipse(in: circleRect)
    }

    private func drawLine(_ line: Line, in context: CGContext, rect: CGRect) {
        // 轉換為本地座標
        let startPoint = CGPoint(
            x: line.position.x - frame.origin.x,
            y: line.position.y - frame.origin.y
        )
        let endPoint = CGPoint(
            x: line.endPoint.x - frame.origin.x,
            y: line.endPoint.y - frame.origin.y
        )

        context.setStrokeColor(line.strokeColor.uiColor.cgColor)
        context.setLineWidth(2)
        context.move(to: startPoint)
        context.addLine(to: endPoint)
        context.strokePath()
    }

    // MARK: - Gesture Handling

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: superview)

        switch gesture.state {
        case .began:
            dragStartPosition = center
            totalTranslation = .zero

        case .changed:
            // 即時移動視圖
            center = CGPoint(
                x: dragStartPosition.x + translation.x,
                y: dragStartPosition.y + translation.y
            )
            totalTranslation = translation

        case .ended, .cancelled:
            // 通知代理總位移量
            let offset = Point(x: Double(totalTranslation.x), y: Double(totalTranslation.y))
            delegate?.shapeView(self, didMoveBy: offset)

        default:
            break
        }
    }
}
