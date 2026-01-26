//
//  Shape.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import Foundation

// MARK: - Point

/// Point - 2D 座標點
struct Point: Equatable {
    var x: Double
    var y: Double

    init(x: Double = 0, y: Double = 0) {
        self.x = x
        self.y = y
    }

    /// 加上偏移量
    func offset(by delta: Point) -> Point {
        return Point(x: x + delta.x, y: y + delta.y)
    }
}

// MARK: - Size

/// Size - 尺寸
struct Size: Equatable {
    var width: Double
    var height: Double

    init(width: Double = 0, height: Double = 0) {
        self.width = width
        self.height = height
    }
}

// MARK: - Shape Protocol

/// Shape - 圖形協議
/// 所有圖形必須實作此協議
protocol Shape {
    var id: UUID { get }
    var position: Point { get set }
    var fillColor: Color { get set }
    var strokeColor: Color { get set }
}

// MARK: - Rectangle

/// Rectangle - 矩形
struct Rectangle: Shape {
    let id: UUID
    var position: Point
    var size: Size
    var fillColor: Color
    var strokeColor: Color

    init(
        id: UUID = UUID(),
        position: Point = Point(),
        size: Size = Size(width: 100, height: 100),
        fillColor: Color = .white,
        strokeColor: Color = .black
    ) {
        self.id = id
        self.position = position
        self.size = size
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }
}

// MARK: - Circle

/// Circle - 圓形
struct Circle: Shape {
    let id: UUID
    var position: Point  // center
    var radius: Double
    var fillColor: Color
    var strokeColor: Color

    init(
        id: UUID = UUID(),
        position: Point = Point(),
        radius: Double = 50,
        fillColor: Color = .white,
        strokeColor: Color = .black
    ) {
        self.id = id
        self.position = position
        self.radius = radius
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }
}

// MARK: - Line

/// Line - 線條
struct Line: Shape {
    let id: UUID
    var position: Point  // start point
    var endPoint: Point
    var strokeColor: Color

    // Lines don't have fill
    var fillColor: Color {
        get { return .clear }
        set { } // no-op
    }

    init(
        id: UUID = UUID(),
        position: Point = Point(),
        endPoint: Point = Point(x: 100, y: 100),
        strokeColor: Color = .black
    ) {
        self.id = id
        self.position = position
        self.endPoint = endPoint
        self.strokeColor = strokeColor
    }
}
