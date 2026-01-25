import Foundation
import Combine

// MARK: - Command Protocol

/// Protocol defining the Command Pattern interface.
public protocol Command {
    func execute()
    func undo()
    var description: String { get }
}

// MARK: - CommandHistory

/// Manages undo/redo history using two stacks.
public final class CommandHistory {
    private var undoStack: [Command] = []
    private var redoStack: [Command] = []

    public init() {}

    public func execute(_ command: Command) {
        command.execute()
        undoStack.append(command)
        redoStack.removeAll()
    }

    public func undo() {
        guard let command = undoStack.popLast() else { return }
        command.undo()
        redoStack.append(command)
    }

    public func redo() {
        guard let command = redoStack.popLast() else { return }
        command.execute()
        undoStack.append(command)
    }

    public var canUndo: Bool { !undoStack.isEmpty }
    public var canRedo: Bool { !redoStack.isEmpty }
    public var undoDescription: String? { undoStack.last?.description }
    public var redoDescription: String? { redoStack.last?.description }
}

// MARK: - Basic Types

/// 2D point representation
public struct Point: Equatable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public static let zero = Point(x: 0, y: 0)
}

extension Point: CustomStringConvertible {
    public var description: String {
        "(\(x), \(y))"
    }
}

/// 2D size representation
public struct Size: Equatable {
    public let width: Double
    public let height: Double

    public init(width: Double, height: Double) {
        self.width = max(0, width)
        self.height = max(0, height)
    }

    public static let zero = Size(width: 0, height: 0)
}

extension Size: CustomStringConvertible {
    public var description: String {
        "\(width) × \(height)"
    }
}

/// Color representation (RGBA)
public struct Color: Equatable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red.clamped(to: 0...1)
        self.green = green.clamped(to: 0...1)
        self.blue = blue.clamped(to: 0...1)
        self.alpha = alpha.clamped(to: 0...1)
    }

    public static let black = Color(red: 0, green: 0, blue: 0)
    public static let white = Color(red: 1, green: 1, blue: 1)
    public static let red = Color(red: 1, green: 0, blue: 0)
    public static let green = Color(red: 0, green: 1, blue: 0)
    public static let blue = Color(red: 0, green: 0, blue: 1)
    public static let yellow = Color(red: 1, green: 1, blue: 0)
}

private extension Double {
    func clamped(to range: ClosedRange<Double>) -> Double {
        min(max(self, range.lowerBound), range.upperBound)
    }
}

/// Text style representation
public struct TextStyle: Equatable {
    public let isBold: Bool
    public let isItalic: Bool
    public let isUnderlined: Bool

    public init(isBold: Bool = false, isItalic: Bool = false, isUnderlined: Bool = false) {
        self.isBold = isBold
        self.isItalic = isItalic
        self.isUnderlined = isUnderlined
    }

    public static let bold = TextStyle(isBold: true)
    public static let italic = TextStyle(isItalic: true)
    public static let underline = TextStyle(isUnderlined: true)
}

// MARK: - Shape Protocol

/// Shape protocol for all drawable shapes
public protocol Shape: AnyObject {
    var id: UUID { get }
    var position: Point { get set }
    var fillColor: Color? { get set }
    var strokeColor: Color? { get set }
    func copy() -> Shape
}

/// Circle shape
public final class Circle: Shape {
    public let id: UUID
    public var position: Point
    public var radius: Double
    public var fillColor: Color?
    public var strokeColor: Color?

    public init(position: Point, radius: Double, fillColor: Color? = nil, strokeColor: Color? = nil) {
        self.id = UUID()
        self.position = position
        self.radius = radius
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }

    public func copy() -> Shape {
        Circle(position: position, radius: radius, fillColor: fillColor, strokeColor: strokeColor)
    }
}

/// Rectangle shape
public final class Rectangle: Shape {
    public let id: UUID
    public var position: Point
    public var size: Size
    public var fillColor: Color?
    public var strokeColor: Color?

    public init(position: Point, size: Size, fillColor: Color? = nil, strokeColor: Color? = nil) {
        self.id = UUID()
        self.position = position
        self.size = size
        self.fillColor = fillColor
        self.strokeColor = strokeColor
    }

    public func copy() -> Shape {
        Rectangle(position: position, size: size, fillColor: fillColor, strokeColor: strokeColor)
    }
}

// MARK: - Memento Protocol

public protocol Memento {
    var timestamp: Date { get }
}

// MARK: - TextDocument

/// Text document with memento support
public final class TextDocument {
    private var text: String
    private var styleMap: [NSRange: TextStyle] = [:]

    public init(text: String = "") {
        self.text = text
    }

    public func getText() -> String {
        return text
    }

    public func insert(_ newText: String, at position: Int) {
        guard !newText.isEmpty else { return }
        let safePosition = max(0, min(position, text.count))
        let index = text.index(text.startIndex, offsetBy: safePosition)
        text.insert(contentsOf: newText, at: index)
    }

    public func delete(in range: NSRange) {
        guard range.location >= 0, range.length > 0, range.location < text.count else { return }
        let safeLength = min(range.length, text.count - range.location)
        let startIndex = text.index(text.startIndex, offsetBy: range.location)
        let endIndex = text.index(startIndex, offsetBy: safeLength)
        text.removeSubrange(startIndex..<endIndex)
    }

    public func replace(in range: NSRange, with newText: String) {
        delete(in: range)
        insert(newText, at: range.location)
    }

    public func applyStyle(_ style: TextStyle, in range: NSRange) {
        guard range.location >= 0, range.length > 0, range.location < text.count else { return }
        let safeLength = min(range.length, text.count - range.location)
        let safeRange = NSRange(location: range.location, length: safeLength)
        styleMap[safeRange] = style
    }

    @discardableResult
    public func removeStyle(in range: NSRange) -> TextStyle? {
        return styleMap.removeValue(forKey: range)
    }

    public func getStyle(in range: NSRange) -> TextStyle? {
        return styleMap[range]
    }

    public func getAllStyles() -> [NSRange: TextStyle] {
        return styleMap
    }

    // Memento support
    public struct TextDocumentMemento: Memento {
        public let text: String
        public let styleMap: [NSRange: TextStyle]
        public let timestamp: Date
    }

    public func createMemento() -> TextDocumentMemento {
        return TextDocumentMemento(text: text, styleMap: styleMap, timestamp: Date())
    }

    public func restore(from memento: TextDocumentMemento) {
        self.text = memento.text
        self.styleMap = memento.styleMap
    }
}

// MARK: - Canvas

/// Canvas for managing shapes
public final class Canvas {
    private(set) public var shapes: [Shape] = []
    public var selectedShapeId: UUID?

    public init() {}

    public func add(shape: Shape) {
        shapes.append(shape)
    }

    @discardableResult
    public func remove(shape: Shape) -> Int? {
        guard let index = shapes.firstIndex(where: { $0.id == shape.id }) else { return nil }
        shapes.remove(at: index)
        return index
    }

    public func move(shape: Shape, by offset: Point) {
        shape.position = Point(x: shape.position.x + offset.x, y: shape.position.y + offset.y)
    }

    public func resize(shape: Shape, to size: Size) {
        if let rectangle = shape as? Rectangle {
            rectangle.size = size
        } else if let circle = shape as? Circle {
            circle.radius = size.width / 2
        }
    }

    public func changeColor(shape: Shape, fillColor: Color?? = nil, strokeColor: Color?? = nil) {
        if let fill = fillColor {
            shape.fillColor = fill
        }
        if let stroke = strokeColor {
            shape.strokeColor = stroke
        }
    }

    // Memento support
    public struct CanvasMemento: Memento {
        public let shapes: [Shape]
        public let selectedShapeId: UUID?
        public let timestamp: Date
    }

    public func createMemento() -> CanvasMemento {
        let shapesCopy = shapes.map { $0.copy() }
        return CanvasMemento(shapes: shapesCopy, selectedShapeId: selectedShapeId, timestamp: Date())
    }

    public func restore(from memento: CanvasMemento) {
        self.shapes = memento.shapes.map { $0.copy() }
        self.selectedShapeId = memento.selectedShapeId
    }
}

// MARK: - Text Commands

/// Insert text command
public final class InsertTextCommand: Command {
    private weak var document: TextDocument?
    private let text: String
    private let position: Int
    private var beforeMemento: TextDocument.TextDocumentMemento?

    public init(document: TextDocument, text: String, position: Int) {
        self.document = document
        self.text = text
        self.position = position
    }

    public func execute() {
        guard let document = document else { return }
        if beforeMemento == nil {
            beforeMemento = document.createMemento()
        }
        document.insert(text, at: position)
    }

    public func undo() {
        guard let document = document, let memento = beforeMemento else { return }
        document.restore(from: memento)
    }

    public var description: String {
        let truncated = text.count > 20 ? String(text.prefix(20)) + "..." : text
        return "Insert '\(truncated)' at position \(position)"
    }
}

/// Delete text command
public final class DeleteTextCommand: Command {
    private weak var document: TextDocument?
    private let range: NSRange
    private var beforeMemento: TextDocument.TextDocumentMemento?

    public init(document: TextDocument, range: NSRange) {
        self.document = document
        self.range = range
    }

    public func execute() {
        guard let document = document else { return }
        if beforeMemento == nil {
            beforeMemento = document.createMemento()
        }
        document.delete(in: range)
    }

    public func undo() {
        guard let document = document, let memento = beforeMemento else { return }
        document.restore(from: memento)
    }

    public var description: String {
        return "Delete text at range (\(range.location), \(range.length))"
    }
}

/// Replace text command
public final class ReplaceTextCommand: Command {
    private weak var document: TextDocument?
    private let range: NSRange
    private let newText: String
    private var beforeMemento: TextDocument.TextDocumentMemento?

    public init(document: TextDocument, range: NSRange, newText: String) {
        self.document = document
        self.range = range
        self.newText = newText
    }

    public func execute() {
        guard let document = document else { return }
        if beforeMemento == nil {
            beforeMemento = document.createMemento()
        }
        document.replace(in: range, with: newText)
    }

    public func undo() {
        guard let document = document, let memento = beforeMemento else { return }
        document.restore(from: memento)
    }

    public var description: String {
        return "Replace text at range (\(range.location), \(range.length)) with '\(newText)'"
    }
}

/// Apply style command
public final class ApplyStyleCommand: Command {
    private weak var document: TextDocument?
    private let style: TextStyle
    private let range: NSRange
    private var beforeMemento: TextDocument.TextDocumentMemento?

    public init(document: TextDocument, style: TextStyle, range: NSRange) {
        self.document = document
        self.style = style
        self.range = range
    }

    public func execute() {
        guard let document = document else { return }
        if beforeMemento == nil {
            beforeMemento = document.createMemento()
        }
        document.applyStyle(style, in: range)
    }

    public func undo() {
        guard let document = document, let memento = beforeMemento else { return }
        document.restore(from: memento)
    }

    public var description: String {
        var attrs: [String] = []
        if style.isBold { attrs.append("bold") }
        if style.isItalic { attrs.append("italic") }
        if style.isUnderlined { attrs.append("underline") }
        return "Apply style (\(attrs.joined(separator: ", "))) to range (\(range.location), \(range.length))"
    }
}

// MARK: - Canvas Commands

/// Add shape command
public final class AddShapeCommand: Command {
    private weak var canvas: Canvas?
    private let shape: Shape

    public init(canvas: Canvas, shape: Shape) {
        self.canvas = canvas
        self.shape = shape
    }

    public func execute() {
        canvas?.add(shape: shape)
    }

    public func undo() {
        canvas?.remove(shape: shape)
    }

    public var description: String {
        return "Add shape (id: \(shape.id))"
    }
}

/// Delete shape command
public final class DeleteShapeCommand: Command {
    private weak var canvas: Canvas?
    private let shape: Shape
    private var removedIndex: Int?

    public init(canvas: Canvas, shape: Shape) {
        self.canvas = canvas
        self.shape = shape
    }

    public func execute() {
        removedIndex = canvas?.remove(shape: shape)
    }

    public func undo() {
        canvas?.add(shape: shape)
    }

    public var description: String {
        return "Delete shape (id: \(shape.id))"
    }
}

/// Move shape command
public final class MoveShapeCommand: Command {
    private weak var canvas: Canvas?
    private let shape: Shape
    private let offset: Point

    public init(canvas: Canvas, shape: Shape, offset: Point) {
        self.canvas = canvas
        self.shape = shape
        self.offset = offset
    }

    public func execute() {
        canvas?.move(shape: shape, by: offset)
    }

    public func undo() {
        canvas?.move(shape: shape, by: Point(x: -offset.x, y: -offset.y))
    }

    public var description: String {
        return "Move shape by \(offset)"
    }
}

/// Resize shape command
public final class ResizeShapeCommand: Command {
    private weak var canvas: Canvas?
    private let shape: Shape
    private let newSize: Size
    private var oldSize: Size?

    public init(canvas: Canvas, shape: Shape, newSize: Size) {
        self.canvas = canvas
        self.shape = shape
        self.newSize = newSize
    }

    public func execute() {
        if let rect = shape as? Rectangle {
            oldSize = rect.size
        } else if let circle = shape as? Circle {
            oldSize = Size(width: circle.radius * 2, height: circle.radius * 2)
        }
        canvas?.resize(shape: shape, to: newSize)
    }

    public func undo() {
        guard let oldSize = oldSize else { return }
        canvas?.resize(shape: shape, to: oldSize)
    }

    public var description: String {
        return "Resize shape to \(newSize)"
    }
}

/// Change fill color command
public final class ChangeFillColorCommand: Command {
    private weak var canvas: Canvas?
    private let shape: Shape
    private let newColor: Color?
    private var oldColor: Color?

    public init(canvas: Canvas, shape: Shape, newColor: Color?) {
        self.canvas = canvas
        self.shape = shape
        self.newColor = newColor
    }

    public func execute() {
        oldColor = shape.fillColor
        canvas?.changeColor(shape: shape, fillColor: newColor)
    }

    public func undo() {
        canvas?.changeColor(shape: shape, fillColor: oldColor)
    }

    public var description: String {
        return "Change fill color"
    }
}

/// Change stroke color command
public final class ChangeStrokeColorCommand: Command {
    private weak var canvas: Canvas?
    private let shape: Shape
    private let newColor: Color?
    private var oldColor: Color?

    public init(canvas: Canvas, shape: Shape, newColor: Color?) {
        self.canvas = canvas
        self.shape = shape
        self.newColor = newColor
    }

    public func execute() {
        oldColor = shape.strokeColor
        canvas?.changeColor(shape: shape, strokeColor: newColor)
    }

    public func undo() {
        canvas?.changeColor(shape: shape, strokeColor: oldColor)
    }

    public var description: String {
        return "Change stroke color"
    }
}
