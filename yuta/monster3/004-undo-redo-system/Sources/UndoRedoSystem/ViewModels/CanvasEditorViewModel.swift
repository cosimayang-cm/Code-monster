import Foundation
import Combine

/// CanvasEditorViewModel - 畫布編輯器 ViewModel
///
/// 遵循 PAGEs Framework ViewModel 模式，使用 Combine @Published 屬性實現響應式架構。
/// 負責管理畫布狀態、執行命令、提供 UI 綁定。
///
/// Design rationale:
/// - 使用 @Published 屬性自動通知 UI 更新
/// - 透過 Protocol 注入依賴（CanvasProtocol, CommandHistoryProtocol）
/// - 封裝 Command 建立邏輯，UI 層只需呼叫方法
/// - Foundation + Combine only
public final class CanvasEditorViewModel: ObservableObject {
    // MARK: - Published Properties

    /// 畫布上的所有圖形
    @Published public private(set) var shapes: [Shape] = []

    /// 是否可以執行 Undo
    @Published public private(set) var canUndo: Bool = false

    /// 是否可以執行 Redo
    @Published public private(set) var canRedo: Bool = false

    /// Undo 按鈕標題
    @Published public private(set) var undoButtonTitle: String = "復原"

    /// Redo 按鈕標題
    @Published public private(set) var redoButtonTitle: String = "重做"

    /// 目前選取的圖形 ID
    @Published public var selectedShapeId: UUID?

    // MARK: - Private Properties

    private let canvas: CanvasProtocol
    private let commandHistory: CommandHistoryProtocol

    // MARK: - Initialization

    /// 建立 CanvasEditorViewModel
    ///
    /// - Parameters:
    ///   - canvas: 畫布實例（透過 CanvasProtocol 注入）
    ///   - commandHistory: 命令歷史管理（透過 CommandHistoryProtocol 注入）
    public init(
        canvas: CanvasProtocol,
        commandHistory: CommandHistoryProtocol
    ) {
        self.canvas = canvas
        self.commandHistory = commandHistory

        // 初始化狀態
        updatePublishedProperties()
    }

    // MARK: - Canvas Operations

    /// 新增矩形圖形
    ///
    /// - Parameters:
    ///   - position: 左上角座標
    ///   - size: 矩形大小
    ///   - fillColor: 填充顏色
    ///   - strokeColor: 邊框顏色
    public func addRectangle(
        at position: Point,
        size: Size,
        fillColor: Color? = nil,
        strokeColor: Color? = nil
    ) {
        let rectangle = Rectangle(
            position: position,
            size: size,
            fillColor: fillColor,
            strokeColor: strokeColor
        )
        let command = AddShapeCommand(canvas: canvas, shape: rectangle)
        executeCommand(command)
    }

    /// 新增圓形圖形
    ///
    /// - Parameters:
    ///   - position: 圓心座標
    ///   - radius: 半徑
    ///   - fillColor: 填充顏色
    ///   - strokeColor: 邊框顏色
    public func addCircle(
        at position: Point,
        radius: Double,
        fillColor: Color? = nil,
        strokeColor: Color? = nil
    ) {
        let circle = Circle(
            position: position,
            radius: radius,
            fillColor: fillColor,
            strokeColor: strokeColor
        )
        let command = AddShapeCommand(canvas: canvas, shape: circle)
        executeCommand(command)
    }

    /// 新增線條圖形
    ///
    /// - Parameters:
    ///   - startPoint: 起點座標
    ///   - endPoint: 終點座標
    ///   - strokeColor: 線條顏色
    public func addLine(
        from startPoint: Point,
        to endPoint: Point,
        strokeColor: Color? = nil
    ) {
        let line = Line(
            position: startPoint,
            endPoint: endPoint,
            strokeColor: strokeColor
        )
        let command = AddShapeCommand(canvas: canvas, shape: line)
        executeCommand(command)
    }

    /// 刪除圖形
    ///
    /// - Parameter shape: 要刪除的圖形
    public func deleteShape(_ shape: Shape) {
        let command = DeleteShapeCommand(canvas: canvas, shape: shape)
        executeCommand(command)
    }

    /// 移動圖形
    ///
    /// - Parameters:
    ///   - shape: 要移動的圖形
    ///   - offset: 位移量
    public func moveShape(_ shape: Shape, by offset: Point) {
        let command = MoveShapeCommand(canvas: canvas, shape: shape, offset: offset)
        executeCommand(command)
    }

    /// 縮放圖形
    ///
    /// - Parameters:
    ///   - id: 圖形 ID
    ///   - newSize: 新的尺寸
    public func resizeShape(id: UUID, newSize: Size) {
        guard let shape = canvas.findShape(by: id) else { return }
        let command = ResizeShapeCommand(canvas: canvas, shape: shape, newSize: newSize)
        executeCommand(command)
    }

    /// 變更圖形填充顏色
    ///
    /// - Parameters:
    ///   - id: 圖形 ID
    ///   - color: 新的填充顏色（nil 表示清除填充）
    public func changeFillColor(id: UUID, color: Color?) {
        guard let shape = canvas.findShape(by: id) else { return }
        let command = ChangeFillColorCommand(canvas: canvas, shape: shape, newColor: color)
        executeCommand(command)
    }

    /// 變更圖形邊框顏色
    ///
    /// - Parameters:
    ///   - id: 圖形 ID
    ///   - color: 新的邊框顏色（nil 表示清除邊框）
    public func changeStrokeColor(id: UUID, color: Color?) {
        guard let shape = canvas.findShape(by: id) else { return }
        let command = ChangeStrokeColorCommand(canvas: canvas, shape: shape, newColor: color)
        executeCommand(command)
    }

    // MARK: - Undo/Redo Operations

    /// 執行 Undo
    public func undo() {
        commandHistory.undo()
        updatePublishedProperties()
    }

    /// 執行 Redo
    public func redo() {
        commandHistory.redo()
        updatePublishedProperties()
    }

    // MARK: - Private Helpers

    /// 執行命令並更新 UI 狀態
    ///
    /// - Parameter command: 要執行的命令
    private func executeCommand(_ command: Command) {
        commandHistory.execute(command)
        updatePublishedProperties()
    }

    /// 更新所有 @Published 屬性
    private func updatePublishedProperties() {
        shapes = canvas.shapes
        canUndo = commandHistory.canUndo
        canRedo = commandHistory.canRedo

        if let undoDesc = commandHistory.undoDescription {
            undoButtonTitle = "復原：\(undoDesc)"
        } else {
            undoButtonTitle = "復原"
        }

        if let redoDesc = commandHistory.redoDescription {
            redoButtonTitle = "重做：\(redoDesc)"
        } else {
            redoButtonTitle = "重做"
        }

        selectedShapeId = canvas.selectedShapeId
    }
}
