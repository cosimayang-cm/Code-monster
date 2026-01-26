//
//  CanvasEditorViewModel.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  畫布編輯器 ViewModel
//

import Foundation
import Combine

/// 畫布編輯器 ViewModel
///
/// 封裝 `Canvas` 和 `CommandHistory`，提供 UI 綁定介面。
/// 負責將使用者操作轉換為對應的 Command 並執行。
///
/// ## 使用範例
/// ```swift
/// let viewModel = CanvasEditorViewModel()
///
/// // UI 綁定
/// viewModel.$shapes.sink { updateCanvasView($0) }
/// viewModel.$canUndo.sink { undoButton.isEnabled = $0 }
///
/// // 執行操作
/// viewModel.addCircle(at: Point(x: 100, y: 100), radius: 50)
/// viewModel.undo()
/// ```
///
final class CanvasEditorViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI 綁定)
    
    /// 畫布上的所有圖形
    @Published private(set) var shapes: [Shape] = []
    
    /// 目前選取的圖形 ID
    @Published private(set) var selectedShapeId: UUID?
    
    /// 是否可以 Undo
    @Published private(set) var canUndo: Bool = false
    
    /// 是否可以 Redo
    @Published private(set) var canRedo: Bool = false
    
    /// Undo 按鈕顯示文字
    @Published private(set) var undoButtonTitle: String = "Undo"
    
    /// Redo 按鈕顯示文字
    @Published private(set) var redoButtonTitle: String = "Redo"
    
    // MARK: - Computed Properties
    
    /// 目前選取的圖形
    var selectedShape: Shape? {
        guard let id = selectedShapeId else { return nil }
        return shapes.first { $0.id == id }
    }
    
    /// 圖形數量
    var shapeCount: Int { shapes.count }
    
    // MARK: - Private Properties
    
    /// 畫布模型
    private let canvas: Canvas
    
    /// 命令歷史
    private let history: CommandHistory
    
    /// Combine 訂閱管理
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// 初始化 ViewModel
    ///
    /// - Parameters:
    ///   - canvas: 畫布模型（預設建立新畫布）
    ///   - history: 命令歷史（預設建立新歷史）
    init(canvas: Canvas = Canvas(), history: CommandHistory = CommandHistory()) {
        self.canvas = canvas
        self.history = history
        
        setupBindings()
    }
    
    // MARK: - Add Shape Operations
    
    /// 新增矩形
    ///
    /// - Parameters:
    ///   - position: 左上角位置
    ///   - size: 尺寸
    ///   - fillColor: 填充色
    ///   - strokeColor: 邊框色
    /// - Returns: 新建的矩形
    @discardableResult
    func addRectangle(
        at position: Point,
        size: Size,
        fillColor: Color = .white,
        strokeColor: Color = .black
    ) -> Rectangle {
        let rect = Rectangle(position: position, size: size, fillColor: fillColor, strokeColor: strokeColor)
        let command = AddShapeCommand(canvas: canvas, shape: rect)
        history.execute(command)
        return rect
    }
    
    /// 新增圓形
    ///
    /// - Parameters:
    ///   - position: 圓心位置
    ///   - radius: 半徑
    ///   - fillColor: 填充色
    ///   - strokeColor: 邊框色
    /// - Returns: 新建的圓形
    @discardableResult
    func addCircle(
        at position: Point,
        radius: Double,
        fillColor: Color = .white,
        strokeColor: Color = .black
    ) -> Circle {
        let circle = Circle(position: position, radius: radius, fillColor: fillColor, strokeColor: strokeColor)
        let command = AddShapeCommand(canvas: canvas, shape: circle)
        history.execute(command)
        return circle
    }
    
    /// 新增線條
    ///
    /// - Parameters:
    ///   - startPoint: 起點
    ///   - endPoint: 終點
    ///   - strokeColor: 線條顏色
    /// - Returns: 新建的線條
    @discardableResult
    func addLine(
        from startPoint: Point,
        to endPoint: Point,
        strokeColor: Color = .black
    ) -> Line {
        let line = Line(startPoint: startPoint, endPoint: endPoint, strokeColor: strokeColor)
        let command = AddShapeCommand(canvas: canvas, shape: line)
        history.execute(command)
        return line
    }

    /// 新增手繪路徑
    ///
    /// - Parameters:
    ///   - points: 路徑上的所有點
    ///   - strokeColor: 線條顏色
    ///   - lineWidth: 線條寬度
    /// - Returns: 新建的路徑
    @discardableResult
    func addPath(
        points: [Point],
        strokeColor: Color = .black,
        lineWidth: Double = 3.0
    ) -> Path {
        let path = Path(points: points, strokeColor: strokeColor, lineWidth: lineWidth)
        let command = AddShapeCommand(canvas: canvas, shape: path)
        history.execute(command)
        return path
    }

    // MARK: - Shape Operations
    
    /// 刪除圖形
    ///
    /// - Parameter shapeId: 要刪除的圖形 ID
    func removeShape(shapeId: UUID) {
        let command = RemoveShapeCommand(canvas: canvas, shapeId: shapeId)
        history.execute(command)
    }
    
    /// 刪除目前選取的圖形
    func removeSelectedShape() {
        guard let id = selectedShapeId else { return }
        removeShape(shapeId: id)
    }
    
    /// 移動圖形
    ///
    /// - Parameters:
    ///   - shapeId: 要移動的圖形 ID
    ///   - offset: 移動偏移量
    func moveShape(shapeId: UUID, offset: Point) {
        let command = MoveShapeCommand(canvas: canvas, shapeId: shapeId, offset: offset)
        history.execute(command)
    }
    
    /// 移動目前選取的圖形
    ///
    /// - Parameter offset: 移動偏移量
    func moveSelectedShape(offset: Point) {
        guard let id = selectedShapeId else { return }
        moveShape(shapeId: id, offset: offset)
    }
    
    /// 縮放矩形
    ///
    /// - Parameters:
    ///   - shapeId: 要縮放的矩形 ID
    ///   - newSize: 新尺寸
    func resizeRectangle(shapeId: UUID, newSize: Size) {
        let command = ResizeShapeCommand(canvas: canvas, shapeId: shapeId, newSize: newSize)
        history.execute(command)
    }
    
    /// 縮放圓形
    ///
    /// - Parameters:
    ///   - shapeId: 要縮放的圓形 ID
    ///   - newRadius: 新半徑
    func resizeCircle(shapeId: UUID, newRadius: Double) {
        let command = ResizeShapeCommand(canvas: canvas, shapeId: shapeId, newRadius: newRadius)
        history.execute(command)
    }
    
    /// 變更顏色
    ///
    /// - Parameters:
    ///   - shapeId: 要變更顏色的圖形 ID
    ///   - fillColor: 新填充色（nil 表示不改變）
    ///   - strokeColor: 新邊框色（nil 表示不改變）
    func changeColor(shapeId: UUID, fillColor: Color? = nil, strokeColor: Color? = nil) {
        let command = ChangeColorCommand(canvas: canvas, shapeId: shapeId, newFillColor: fillColor, newStrokeColor: strokeColor)
        history.execute(command)
    }
    
    /// 變更目前選取圖形的顏色
    func changeSelectedShapeColor(fillColor: Color? = nil, strokeColor: Color? = nil) {
        guard let id = selectedShapeId else { return }
        changeColor(shapeId: id, fillColor: fillColor, strokeColor: strokeColor)
    }
    
    // MARK: - Selection
    
    /// 選取圖形
    ///
    /// - Parameter shapeId: 要選取的圖形 ID
    func select(shapeId: UUID?) {
        canvas.select(shapeId: shapeId)
    }
    
    /// 清除選取
    func clearSelection() {
        canvas.clearSelection()
    }
    
    // MARK: - Undo/Redo
    
    /// 撤銷
    func undo() {
        history.undo()
    }
    
    /// 重做
    func redo() {
        history.redo()
    }
    
    /// 清除歷史
    func clearHistory() {
        history.clear()
    }
    
    // MARK: - Canvas Operations
    
    /// 清空畫布
    func clearCanvas() {
        // 使用 CompositeCommand 將所有刪除操作組合成一個命令
        let composite = CompositeCommand(description: "清空畫布")
        for shape in shapes {
            composite.add(RemoveShapeCommand(canvas: canvas, shapeId: shape.id))
        }
        if !composite.isEmpty {
            history.execute(composite)
        }
    }
    
    // MARK: - Private Methods
    
    /// 設定資料綁定
    private func setupBindings() {
        // 綁定 Canvas
        canvas.$shapes
            .assign(to: &$shapes)
        
        canvas.$selectedShapeId
            .assign(to: &$selectedShapeId)
        
        // 綁定 History
        history.$canUndo
            .assign(to: &$canUndo)
        
        history.$canRedo
            .assign(to: &$canRedo)
        
        // Undo 按鈕標題
        history.$undoDescription
            .map { desc in
                if let desc = desc {
                    return "Undo \(desc)"
                }
                return "Undo"
            }
            .assign(to: &$undoButtonTitle)
        
        // Redo 按鈕標題
        history.$redoDescription
            .map { desc in
                if let desc = desc {
                    return "Redo \(desc)"
                }
                return "Redo"
            }
            .assign(to: &$redoButtonTitle)
    }
}
