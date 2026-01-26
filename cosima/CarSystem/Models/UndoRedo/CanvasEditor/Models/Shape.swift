//
//  Shape.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  圖形定義
//

import Foundation

// MARK: - 基礎類型

/// 2D 座標點
struct Point: Equatable, Codable {
    var x: Double
    var y: Double
    
    static let zero = Point(x: 0, y: 0)
    
    /// 加上偏移量
    func offset(by delta: Point) -> Point {
        return Point(x: x + delta.x, y: y + delta.y)
    }
}

/// 尺寸
struct Size: Equatable, Codable {
    var width: Double
    var height: Double
    
    static let zero = Size(width: 0, height: 0)
    
    /// 縮放
    func scaled(by factor: Double) -> Size {
        return Size(width: width * factor, height: height * factor)
    }
}

/// 顏色（RGBA）
struct Color: Equatable, Codable {
    var red: Double    // 0.0 ~ 1.0
    var green: Double  // 0.0 ~ 1.0
    var blue: Double   // 0.0 ~ 1.0
    var alpha: Double  // 0.0 ~ 1.0
    
    // MARK: - 預設顏色
    
    static let black = Color(red: 0, green: 0, blue: 0, alpha: 1)
    static let white = Color(red: 1, green: 1, blue: 1, alpha: 1)
    static let red = Color(red: 1, green: 0, blue: 0, alpha: 1)
    static let green = Color(red: 0, green: 1, blue: 0, alpha: 1)
    static let blue = Color(red: 0, green: 0, blue: 1, alpha: 1)
    static let yellow = Color(red: 1, green: 1, blue: 0, alpha: 1)
    static let clear = Color(red: 0, green: 0, blue: 0, alpha: 0)
}

// MARK: - Shape Protocol

/// 圖形協議 - 所有圖形的共同介面
protocol Shape: AnyObject {
    /// 唯一識別碼
    var id: UUID { get }
    
    /// 圖形位置（左上角或圓心）
    var position: Point { get set }
    
    /// 填充顏色
    var fillColor: Color { get set }
    
    /// 邊框顏色
    var strokeColor: Color { get set }
    
    /// 圖形類型名稱
    var typeName: String { get }
    
    /// 建立快照（用於 Undo/Memento）
    func snapshot() -> ShapeSnapshot
}

// MARK: - 矩形

/// 矩形圖形
final class Rectangle: Shape {
    let id: UUID
    var position: Point
    var size: Size
    var fillColor: Color
    var strokeColor: Color
    
    var typeName: String { "矩形" }
    
    init(
        id: UUID = UUID(),
        position: Point,
        size: Size,
        fillColor: Color = .white,
        strokeColor: Color = .black
    ) {
        self.id = id
        self.position = position
        self.size = size
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }
    
    func snapshot() -> ShapeSnapshot {
        return .rectangle(
            id: id,
            position: position,
            size: size,
            fillColor: fillColor,
            strokeColor: strokeColor
        )
    }
}

// MARK: - 圓形

/// 圓形圖形
final class Circle: Shape {
    let id: UUID
    var position: Point  // 圓心
    var radius: Double
    var fillColor: Color
    var strokeColor: Color
    
    var typeName: String { "圓形" }
    
    init(
        id: UUID = UUID(),
        position: Point,
        radius: Double,
        fillColor: Color = .white,
        strokeColor: Color = .black
    ) {
        self.id = id
        self.position = position
        self.radius = radius
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }
    
    func snapshot() -> ShapeSnapshot {
        return .circle(
            id: id,
            position: position,
            radius: radius,
            fillColor: fillColor,
            strokeColor: strokeColor
        )
    }
}

// MARK: - 線條

/// 線條圖形
final class Line: Shape {
    let id: UUID
    var position: Point  // 起點
    var endPoint: Point  // 終點
    var fillColor: Color  // 線條不使用填充色
    var strokeColor: Color
    
    var typeName: String { "線條" }
    
    init(
        id: UUID = UUID(),
        startPoint: Point,
        endPoint: Point,
        strokeColor: Color = .black
    ) {
        self.id = id
        self.position = startPoint
        self.endPoint = endPoint
        self.fillColor = .clear
        self.strokeColor = strokeColor
    }
    
    func snapshot() -> ShapeSnapshot {
        return .line(
            id: id,
            startPoint: position,
            endPoint: endPoint,
            strokeColor: strokeColor
        )
    }
}

// MARK: - 手繪路徑

/// 手繪路徑圖形（自由繪圖）
final class Path: Shape {
    let id: UUID
    var position: Point  // 第一個點
    var points: [Point]  // 所有點
    var fillColor: Color
    var strokeColor: Color
    var lineWidth: Double

    var typeName: String { "手繪" }

    init(
        id: UUID = UUID(),
        points: [Point],
        strokeColor: Color = .black,
        lineWidth: Double = 3.0
    ) {
        self.id = id
        self.position = points.first ?? .zero
        self.points = points
        self.fillColor = .clear
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
    }

    func snapshot() -> ShapeSnapshot {
        return .path(
            id: id,
            points: points,
            strokeColor: strokeColor,
            lineWidth: lineWidth
        )
    }
}

// MARK: - ShapeSnapshot

/// 圖形快照 - 值類型，用於 Memento Pattern
///
/// 因為 Shape 是 class（reference type），直接保存參考會有狀態共享問題。
/// ShapeSnapshot 是 enum（value type），保存圖形的完整狀態副本。
enum ShapeSnapshot: Equatable, Codable {
    case rectangle(id: UUID, position: Point, size: Size, fillColor: Color, strokeColor: Color)
    case circle(id: UUID, position: Point, radius: Double, fillColor: Color, strokeColor: Color)
    case line(id: UUID, startPoint: Point, endPoint: Point, strokeColor: Color)
    case path(id: UUID, points: [Point], strokeColor: Color, lineWidth: Double)

    /// 從快照建立圖形實例
    func restore() -> Shape {
        switch self {
        case .rectangle(let id, let position, let size, let fillColor, let strokeColor):
            return Rectangle(id: id, position: position, size: size, fillColor: fillColor, strokeColor: strokeColor)
        case .circle(let id, let position, let radius, let fillColor, let strokeColor):
            return Circle(id: id, position: position, radius: radius, fillColor: fillColor, strokeColor: strokeColor)
        case .line(let id, let startPoint, let endPoint, let strokeColor):
            return Line(id: id, startPoint: startPoint, endPoint: endPoint, strokeColor: strokeColor)
        case .path(let id, let points, let strokeColor, let lineWidth):
            return Path(id: id, points: points, strokeColor: strokeColor, lineWidth: lineWidth)
        }
    }

    /// 圖形 ID
    var id: UUID {
        switch self {
        case .rectangle(let id, _, _, _, _): return id
        case .circle(let id, _, _, _, _): return id
        case .line(let id, _, _, _): return id
        case .path(let id, _, _, _): return id
        }
    }
}
