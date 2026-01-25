# Plan: Clean Architecture Undo/Redo System (完整版)

## 背景

用戶要求實作 Monster #3 Undo/Redo 系統，並且要求架構必須：
- ✅ 符合 Clean Architecture 原則
- ✅ 符合 SOLID 原則
- ✅ 避免 ViewModel-ViewController 耦合
- ✅ 完全解耦，可測試性高

## 核心改進項目

### 1. Foundation Only：自訂型別取代 UIKit

**問題**：Shape 使用 UIColor, CGPoint, CGSize (UIKit/CoreGraphics)

**解決方案**：定義 Foundation-only 的自訂型別

#### 新增檔案：
- `Sources/Models/Entities/Color.swift` - 自訂顏色型別
- `Sources/Models/Entities/Point.swift` - 自訂座標型別
- `Sources/Models/Entities/Size.swift` - 自訂尺寸型別

```swift
// Color.swift
public struct Color: Equatable, Hashable {
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double

    public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    // 常用顏色
    public static let red = Color(red: 1.0, green: 0, blue: 0)
    public static let green = Color(red: 0, green: 1.0, blue: 0)
    public static let blue = Color(red: 0, green: 0, blue: 1.0)
    public static let white = Color(red: 1.0, green: 1.0, blue: 1.0)
    public static let black = Color(red: 0, green: 0, blue: 0)
    public static let clear = Color(red: 0, green: 0, blue: 0, alpha: 0)
}

// Point.swift
public struct Point: Equatable, Hashable {
    public let x: Double
    public let y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public static let zero = Point(x: 0, y: 0)

    public static func + (lhs: Point, rhs: Point) -> Point {
        Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}

// Size.swift
public struct Size: Equatable, Hashable {
    public let width: Double
    public let height: Double

    public init(width: Double, height: Double) {
        self.width = width
        self.height = height
    }

    public static let zero = Size(width: 0, height: 0)
}
```

#### 修改檔案：
- `Sources/Models/Entities/Shape.swift` - 使用自訂型別
- `Sources/Models/Receivers/Canvas.swift` - 更新方法簽名
- 所有 Shape 實作（Rectangle, Circle, Line）

---

### 2. Protocol 抽象層（Dependency Inversion）

**問題**：高層模組依賴具體類別，違反 SOLID-D

**解決方案**：引入 Protocol 抽象層

#### 新增檔案：
- `Sources/Models/Protocols/TextDocumentProtocol.swift`
- `Sources/Models/Protocols/CanvasProtocol.swift`
- `Sources/Models/Protocols/CommandHistoryProtocol.swift` (已有，確保使用)

```swift
// TextDocumentProtocol.swift
public protocol TextDocumentProtocol: AnyObject {
    var content: String { get }
    var styles: [TextDocument.TextRange: TextStyle] { get }
    var cursorPosition: Int { get set }

    func insert(text: String, at position: Int)
    func delete(range: Range<Int>) -> String
    func replace(range: Range<Int>, with text: String) -> String
    func applyStyle(_ style: TextStyle, to range: Range<Int>)
    func removeStyle(from range: Range<Int>) -> TextStyle?
}

// CanvasProtocol.swift
public protocol CanvasProtocol: AnyObject {
    var shapes: [Shape] { get }
    var selectedShapeId: UUID? { get set }

    func add(shape: Shape)
    func remove(shape: Shape) -> Int?
    func move(shape: Shape, by offset: Point)
    func resize(shape: Shape, to size: Size)
    func changeColor(shape: Shape, fillColor: Color?, strokeColor: Color?)
    func findShape(by id: UUID) -> Shape?
}

// CommandHistoryProtocol.swift (已存在，確保 CommandHistory 實作)
public protocol CommandHistoryProtocol: AnyObject {
    func execute(_ command: Command)
    func undo()
    func redo()
    func clear()

    var canUndo: Bool { get }
    var canRedo: Bool { get }
    var undoDescription: String? { get }
    var redoDescription: String? { get }
    var undoCount: Int { get }
    var redoCount: Int { get }
}
```

#### 修改檔案：
- `Sources/Models/Receivers/TextDocument.swift` - 實作 TextDocumentProtocol
- `Sources/Models/Receivers/Canvas.swift` - 實作 CanvasProtocol
- `Sources/Models/Command/CommandHistory.swift` - 實作 CommandHistoryProtocol
- **所有 Command 實作** - 使用 Protocol 而非具體類別

```swift
// 範例：InsertTextCommand.swift
class InsertTextCommand: Command {
    private weak var document: TextDocumentProtocol?  // ✅ 使用 Protocol
    private let text: String
    private let position: Int

    init(document: TextDocumentProtocol, text: String, position: Int) {
        self.document = document
        self.text = text
        self.position = position
    }
    // ...
}
```

---

### 3. ViewModel-ViewController 解耦（Combine Framework）

**問題**：ViewController 主動查詢 ViewModel，缺少響應式機制

**解決方案**：使用 Combine Framework 的 @Published 實現響應式資料流

#### 修改檔案：
- `Sources/ViewModels/TextEditorViewModel.swift` - 使用 @Published 屬性
- `Sources/ViewModels/CanvasEditorViewModel.swift` - 使用 @Published 屬性
- `Sources/Views/TextEditorViewController.swift` - 訂閱 Publishers
- `Sources/Views/CanvasEditorViewController.swift` - 訂閱 Publishers

```swift
// TextEditorViewModel.swift
import Foundation
import Combine

public class TextEditorViewModel {
    // Published 屬性（響應式）
    @Published public private(set) var content: String = ""
    @Published public private(set) var canUndo: Bool = false
    @Published public private(set) var canRedo: Bool = false
    @Published public private(set) var undoButtonTitle: String = "復原"
    @Published public private(set) var redoButtonTitle: String = "重做"
    @Published public private(set) var error: Error?

    // 依賴注入 (使用 Protocol)
    private let document: TextDocumentProtocol
    private let history: CommandHistoryProtocol

    public init(document: TextDocumentProtocol, history: CommandHistoryProtocol) {
        self.document = document
        self.history = history
        self.content = document.content
        updateUndoRedoState()
    }

    // Actions
    public func insertText(_ text: String, at position: Int) {
        let command = InsertTextCommand(document: document, text: text, position: position)
        history.execute(command)

        // ✅ 更新 Published 屬性，自動通知訂閱者
        content = document.content
        updateUndoRedoState()
    }

    public func undo() {
        guard history.canUndo else { return }
        history.undo()
        content = document.content
        updateUndoRedoState()
    }

    public func redo() {
        guard history.canRedo else { return }
        history.redo()
        content = document.content
        updateUndoRedoState()
    }

    private func updateUndoRedoState() {
        canUndo = history.canUndo
        canRedo = history.canRedo
        undoButtonTitle = history.undoDescription.map { "復原 \($0)" } ?? "復原"
        redoButtonTitle = history.redoDescription.map { "重做 \($0)" } ?? "重做"
    }
}

// TextEditorViewController.swift
import UIKit
import Combine

class TextEditorViewController: UIViewController {
    private let viewModel: TextEditorViewModel
    private var cancellables = Set<AnyCancellable>()  // ✅ 儲存訂閱

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var undoButton: UIButton!
    @IBOutlet weak var redoButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()  // ✅ 設定響應式綁定
    }

    private func setupBindings() {
        // 訂閱內容變更
        viewModel.$content
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newContent in
                self?.textView.text = newContent
            }
            .store(in: &cancellables)

        // 訂閱 Undo 狀態
        viewModel.$canUndo
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: undoButton)
            .store(in: &cancellables)

        viewModel.$undoButtonTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.undoButton.setTitle(title, for: .normal)
            }
            .store(in: &cancellables)

        // 訂閱 Redo 狀態
        viewModel.$canRedo
            .receive(on: DispatchQueue.main)
            .assign(to: \.isEnabled, on: redoButton)
            .store(in: &cancellables)

        viewModel.$redoButtonTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.redoButton.setTitle(title, for: .normal)
            }
            .store(in: &cancellables)

        // 訂閱錯誤
        viewModel.$error
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] error in
                self?.showError(error)
            }
            .store(in: &cancellables)
    }

    private func showError(_ error: Error) {
        let alert = UIAlertController(title: "錯誤", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
    }

    // IBAction 方法
    @IBAction func undoButtonTapped() {
        viewModel.undo()
    }

    @IBAction func redoButtonTapped() {
        viewModel.redo()
    }
}
```

---

### 4. Memento Pattern 簡化（Swift 慣用方式）

**問題**：需要為複雜操作提供快照功能，但不需要過度設計

**解決方案**：直接讓 Originator 實作 MementoOriginator protocol

#### 修改檔案：
- `Sources/Models/Receivers/TextDocument.swift` - 實作 MementoOriginator
- `Sources/Models/Receivers/Canvas.swift` - 實作 MementoOriginator

```swift
// TextDocument.swift
extension TextDocument: MementoOriginator {
    public func createMemento() -> TextDocumentMemento {
        TextDocumentMemento(
            content: content,
            styles: styles,
            cursorPosition: cursorPosition
        )
    }

    public func restore(from memento: TextDocumentMemento) {
        self.content = memento.content
        self.styles = memento.styles
        self.cursorPosition = memento.cursorPosition
    }
}

// Canvas.swift
extension Canvas: MementoOriginator {
    public func createMemento() -> CanvasMemento {
        // Deep copy shapes
        let shapesCopy = shapes.map { $0.copy() }
        return CanvasMemento(
            shapes: shapesCopy,
            selectedShapeId: selectedShapeId
        )
    }

    public func restore(from memento: CanvasMemento) {
        self.shapes = memento.shapes.map { $0.copy() }
        self.selectedShapeId = memento.selectedShapeId
    }
}
```

**使用範例**：Command 直接使用 createMemento/restore

```swift
class BatchEditCommand: Command {
    private weak var document: TextDocumentProtocol?
    private var beforeMemento: TextDocumentMemento?
    private let operations: () -> Void

    func execute() {
        // ✅ 直接呼叫 createMemento
        beforeMemento = (document as? MementoOriginator)?.createMemento()
        operations()
    }

    func undo() {
        guard let memento = beforeMemento,
              let originator = document as? MementoOriginator else { return }
        // ✅ 直接呼叫 restore
        originator.restore(from: memento)
    }

    var description: String { "批次編輯" }
}
```

**說明**：
- Swift 不需要額外的 Caretaker 類別
- Originator 直接提供 createMemento/restore 方法更簡潔
- 符合 Swift 的協定導向設計

---

## 最終架構

```
yuta/monster3-undo-redo/
├── Sources/
│   ├── Models/ (Foundation only)
│   │   ├── Protocols/              # ✅ 新增：抽象層
│   │   │   ├── TextDocumentProtocol.swift
│   │   │   ├── CanvasProtocol.swift
│   │   │   └── CommandHistoryProtocol.swift
│   │   ├── Command/
│   │   │   ├── Command.swift
│   │   │   ├── CommandHistory.swift (實作 Protocol)
│   │   │   ├── TextCommands/
│   │   │   │   ├── InsertTextCommand.swift (使用 Protocol)
│   │   │   │   ├── DeleteTextCommand.swift
│   │   │   │   ├── ReplaceTextCommand.swift
│   │   │   │   └── ApplyStyleCommand.swift
│   │   │   └── CanvasCommands/
│   │   │       ├── AddShapeCommand.swift (使用 Protocol)
│   │   │       ├── RemoveShapeCommand.swift
│   │   │       ├── MoveShapeCommand.swift
│   │   │       ├── ResizeShapeCommand.swift
│   │   │       └── ChangeColorCommand.swift
│   │   ├── Receivers/
│   │   │   ├── TextDocument.swift (實作 Protocol + MementoOriginator)
│   │   │   └── Canvas.swift (實作 Protocol + MementoOriginator)
│   │   ├── Entities/
│   │   │   ├── Color.swift             # ✅ 新增：自訂型別
│   │   │   ├── Point.swift             # ✅ 新增：自訂型別
│   │   │   ├── Size.swift              # ✅ 新增：自訂型別
│   │   │   ├── Shape.swift (使用 Color, Point)
│   │   │   ├── Rectangle.swift
│   │   │   ├── Circle.swift
│   │   │   ├── Line.swift
│   │   │   └── TextStyle.swift
│   │   └── Memento/
│   │       ├── Memento.swift
│   │       ├── TextDocumentMemento.swift
│   │       └── CanvasMemento.swift
│   ├── ViewModels/ (Foundation + Combine)
│   │   ├── TextEditorViewModel.swift (使用 @Published)
│   │   └── CanvasEditorViewModel.swift (使用 @Published)
│   └── Views/ (UIKit + Combine)
│       ├── TextEditorViewController.swift (訂閱 Publishers)
│       ├── CanvasEditorViewController.swift (訂閱 Publishers)
│       └── Extensions/                       # ✅ 建議新增
│           ├── Color+UIKit.swift             # Color <-> UIColor 轉換
│           ├── Point+CoreGraphics.swift      # Point <-> CGPoint 轉換
│           └── Size+CoreGraphics.swift       # Size <-> CGSize 轉換
└── Tests/
    ├── Mocks/                                # ✅ 新增：Mock 實作
    │   ├── MockTextDocument.swift
    │   ├── MockCanvas.swift
    │   └── MockCommandHistory.swift
    ├── CommandTests/
    ├── CommandHistoryTests.swift
    ├── ReceiverTests/
    └── ViewModelTests/                       # ✅ 新增：ViewModel 測試
        ├── TextEditorViewModelTests.swift
        └── CanvasEditorViewModelTests.swift
```

---

## UI 層型別轉換（Extension）

為了在 View 層使用 UIKit，需要轉換器：

```swift
// Color+UIKit.swift
import UIKit

extension Color {
    public var uiColor: UIColor {
        UIColor(red: CGFloat(red),
                green: CGFloat(green),
                blue: CGFloat(blue),
                alpha: CGFloat(alpha))
    }

    public init(uiColor: UIColor) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.init(red: Double(r), green: Double(g), blue: Double(b), alpha: Double(a))
    }
}

// Point+CoreGraphics.swift
import CoreGraphics

extension Point {
    public var cgPoint: CGPoint {
        CGPoint(x: x, y: y)
    }

    public init(cgPoint: CGPoint) {
        self.init(x: Double(cgPoint.x), y: Double(cgPoint.y))
    }
}

// Size+CoreGraphics.swift
import CoreGraphics

extension Size {
    public var cgSize: CGSize {
        CGSize(width: width, height: height)
    }

    public init(cgSize: CGSize) {
        self.init(width: Double(cgSize.width), height: Double(cgSize.height))
    }
}
```

---

## 測試策略（使用 Mock + Combine）

```swift
// MockTextDocument.swift
class MockTextDocument: TextDocumentProtocol {
    var content: String = ""
    var styles: [TextDocument.TextRange: TextStyle] = [:]
    var cursorPosition: Int = 0

    var insertCalled = false
    var deleteCalled = false

    func insert(text: String, at position: Int) {
        insertCalled = true
        content.insert(contentsOf: text, at: content.index(content.startIndex, offsetBy: position))
    }

    func delete(range: Range<Int>) -> String {
        deleteCalled = true
        let start = content.index(content.startIndex, offsetBy: range.lowerBound)
        let end = content.index(content.startIndex, offsetBy: range.upperBound)
        let deleted = String(content[start..<end])
        content.removeSubrange(start..<end)
        return deleted
    }

    // ... 其他方法
}

// TextEditorViewModelTests.swift
import XCTest
import Combine

class TextEditorViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
    }

    func testInsertTextUpdatesPublishedProperties() {
        // Given
        let mockDocument = MockTextDocument()
        let mockHistory = MockCommandHistory()
        let viewModel = TextEditorViewModel(document: mockDocument, history: mockHistory)

        var receivedContent: [String] = []
        var receivedCanUndo: [Bool] = []

        // 訂閱 Publishers
        viewModel.$content
            .sink { receivedContent.append($0) }
            .store(in: &cancellables)

        viewModel.$canUndo
            .sink { receivedCanUndo.append($0) }
            .store(in: &cancellables)

        // When
        viewModel.insertText("Hello", at: 0)

        // Then
        XCTAssertTrue(mockDocument.insertCalled)
        XCTAssertEqual(receivedContent.last, "Hello")
        XCTAssertEqual(receivedCanUndo.last, true)
    }

    func testUndoRedoUpdatesState() {
        // Given
        let mockDocument = MockTextDocument()
        let mockHistory = MockCommandHistory()
        let viewModel = TextEditorViewModel(document: mockDocument, history: mockHistory)

        var canUndoStates: [Bool] = []
        var canRedoStates: [Bool] = []

        viewModel.$canUndo
            .sink { canUndoStates.append($0) }
            .store(in: &cancellables)

        viewModel.$canRedo
            .sink { canRedoStates.append($0) }
            .store(in: &cancellables)

        // When
        viewModel.insertText("Test", at: 0)
        viewModel.undo()
        viewModel.redo()

        // Then
        XCTAssertEqual(canUndoStates, [false, true, false, true])
        XCTAssertEqual(canRedoStates, [false, false, true, false])
    }
}
```

---

## 驗證清單

### ✅ Foundation Only
- [ ] 所有 Model 層檔案只 import Foundation
- [ ] 使用自訂 Color, Point, Size 取代 UIKit 型別
- [ ] View 層使用 extension 轉換型別

### ✅ SOLID 原則
- [ ] S: 每個類別職責單一（Caretaker 分離）
- [ ] O: 使用 Protocol，對擴展開放對修改封閉
- [ ] L: Protocol 可以被具體實作替換
- [ ] I: Protocol 介面分離清楚
- [ ] D: 高層依賴抽象（Protocol）而非具體

### ✅ Clean Architecture
- [ ] View 依賴 ViewModel（單向）
- [ ] ViewModel 依賴 Model Protocol（單向）
- [ ] Model 不依賴任何外層
- [ ] 使用 Combine 解耦 ViewModel-ViewController

### ✅ 可測試性
- [ ] 可以注入 Mock 實作
- [ ] ViewModel 可單元測試（不依賴 UIKit）
- [ ] Command 可單元測試
- [ ] Receiver 可單元測試

---

## 實作順序

### 核心實作（必須完成）

1. **Phase 1: Foundation Only 型別**
   - 新增 Color.swift, Point.swift, Size.swift
   - 更新 Shape protocol 和所有實作

2. **Phase 2: Protocol 抽象層**
   - 新增 TextDocumentProtocol, CanvasProtocol
   - 更新 TextDocument, Canvas 實作 protocol
   - 更新所有 Command 使用 protocol

3. **Phase 3: Combine 響應式架構**
   - 更新 ViewModel 使用 @Published 屬性
   - 確保 ViewModel 準備好供 UI 訂閱

4. **Phase 4: Memento 實作**
   - 確保 TextDocument, Canvas 實作 MementoOriginator
   - 在需要的 Command 中使用 createMemento/restore

5. **Phase 5: 型別轉換 Extension**
   - 新增 Color+UIKit, Point+CoreGraphics, Size+CoreGraphics

6. **Phase 6: 測試（可選）**
   - 新增 Mock 實作
   - 撰寫 ViewModel 單元測試（含 Combine 測試）
   - 撰寫整合測試

**核心完成後可驗證**：在 Unit Test 或 Playground 中測試所有功能

---

### Phase 7: SwiftUI UI 實作（可選，有餘裕時實作）

**前置條件**：核心實作（Phase 1-6）必須完成並驗證通過

**目的**：提供視覺化介面，可在模擬器上實際操作編輯器

#### 7.1 App 基礎架構

```swift
// App.swift
import SwiftUI

@main
struct UndoRedoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

#### 7.2 主畫面（TabView）

```swift
// ContentView.swift
struct ContentView: View {
    var body: some View {
        TabView {
            TextEditorView()
                .tabItem {
                    Label("文字編輯器", systemImage: "doc.text")
                }

            CanvasEditorView()
                .tabItem {
                    Label("畫布編輯器", systemImage: "paintbrush")
                }
        }
    }
}
```

#### 7.3 文字編輯器 UI

```swift
// TextEditorView.swift
import SwiftUI
import Combine

struct TextEditorView: View {
    @StateObject private var viewModel = TextEditorViewModel(
        document: TextDocument(),
        history: CommandHistory()
    )

    @State private var text: String = ""

    var body: some View {
        VStack(spacing: 0) {
            // 工具列
            HStack {
                Button(viewModel.undoButtonTitle) {
                    viewModel.undo()
                }
                .disabled(!viewModel.canUndo)

                Button(viewModel.redoButtonTitle) {
                    viewModel.redo()
                }
                .disabled(!viewModel.canRedo)

                Spacer()

                // 樣式按鈕（Phase 2 功能）
                Button("粗體") {
                    // 套用粗體到選取範圍
                }

                Button("斜體") {
                    // 套用斜體到選取範圍
                }

                Button("底線") {
                    // 套用底線到選取範圍
                }
            }
            .padding()

            Divider()

            // 文字編輯區
            TextEditor(text: $text)
                .font(.system(size: 16))
                .padding()
                .onChange(of: text) { newValue in
                    // 同步到 ViewModel
                    if newValue != viewModel.content {
                        let position = newValue.count - viewModel.content.count
                        if position > 0 {
                            let insertedText = String(newValue.suffix(position))
                            viewModel.insertText(insertedText, at: viewModel.content.count)
                        }
                    }
                }
                .onReceive(viewModel.$content) { newContent in
                    // 從 ViewModel 同步回來
                    if text != newContent {
                        text = newContent
                    }
                }
        }
        .navigationTitle("文字編輯器")
    }
}
```

#### 7.4 畫布編輯器 UI

```swift
// CanvasEditorView.swift
import SwiftUI

struct CanvasEditorView: View {
    @StateObject private var viewModel = CanvasEditorViewModel(
        canvas: Canvas(),
        history: CommandHistory()
    )

    @State private var selectedTool: ShapeTool = .rectangle
    @State private var selectedColor: Color = .red

    enum ShapeTool {
        case rectangle, circle, line
    }

    var body: some View {
        VStack(spacing: 0) {
            // 工具列
            HStack {
                Button(viewModel.undoButtonTitle) {
                    viewModel.undo()
                }
                .disabled(!viewModel.canUndo)

                Button(viewModel.redoButtonTitle) {
                    viewModel.redo()
                }
                .disabled(!viewModel.canRedo)

                Spacer()

                // 圖形工具
                Picker("工具", selection: $selectedTool) {
                    Text("矩形").tag(ShapeTool.rectangle)
                    Text("圓形").tag(ShapeTool.circle)
                    Text("線條").tag(ShapeTool.line)
                }
                .pickerStyle(.segmented)

                // 顏色選擇
                ColorPicker("顏色", selection: $selectedColor)
            }
            .padding()

            Divider()

            // 畫布區域
            CanvasDrawingView(
                viewModel: viewModel,
                selectedTool: selectedTool,
                selectedColor: selectedColor
            )
        }
        .navigationTitle("畫布編輯器")
    }
}

struct CanvasDrawingView: View {
    @ObservedObject var viewModel: CanvasEditorViewModel
    let selectedTool: CanvasEditorView.ShapeTool
    let selectedColor: SwiftUI.Color

    var body: some View {
        Canvas { context, size in
            // 繪製所有圖形
            for shape in viewModel.shapes {
                drawShape(shape, in: context)
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    // 根據 selectedTool 新增圖形
                    addShape(from: value.startLocation, to: value.location)
                }
        )
    }

    private func drawShape(_ shape: Shape, in context: GraphicsContext) {
        // 將 Model 的 Shape 轉換為 SwiftUI 繪圖
        let uiColor = shape.fillColor?.uiColor ?? UIColor.clear

        // 繪製邏輯...
    }

    private func addShape(from start: CGPoint, to end: CGPoint) {
        let modelColor = Models.Color(uiColor: UIColor(selectedColor))
        let startPoint = Models.Point(cgPoint: start)
        let endPoint = Models.Point(cgPoint: end)

        switch selectedTool {
        case .rectangle:
            let size = Models.Size(
                width: abs(end.x - start.x),
                height: abs(end.y - start.y)
            )
            viewModel.addRectangle(at: startPoint, size: size, fillColor: modelColor)

        case .circle:
            let radius = hypot(end.x - start.x, end.y - start.y)
            viewModel.addCircle(at: startPoint, radius: radius, fillColor: modelColor)

        case .line:
            viewModel.addLine(from: startPoint, to: endPoint, strokeColor: modelColor)
        }
    }
}
```

#### 7.5 ViewModel 補充方法

需要在 CanvasEditorViewModel 中新增便利方法：

```swift
// CanvasEditorViewModel.swift 補充
extension CanvasEditorViewModel {
    func addRectangle(at position: Point, size: Size, fillColor: Color?) {
        let rectangle = Rectangle(position: position, size: size, fillColor: fillColor)
        let command = AddShapeCommand(canvas: canvas, shape: rectangle)
        history.execute(command)
        updateState()
    }

    func addCircle(at position: Point, radius: Double, fillColor: Color?) {
        let circle = Circle(position: position, radius: radius, fillColor: fillColor)
        let command = AddShapeCommand(canvas: canvas, shape: circle)
        history.execute(command)
        updateState()
    }

    func addLine(from start: Point, to end: Point, strokeColor: Color?) {
        let line = Line(position: start, endPoint: end, strokeColor: strokeColor)
        let command = AddShapeCommand(canvas: canvas, shape: line)
        history.execute(command)
        updateState()
    }

    var shapes: [Shape] {
        canvas.shapes
    }
}
```

#### 7.6 新增檔案清單

**SwiftUI 檔案**（7 個）：
1. `App.swift` - App 入口點
2. `ContentView.swift` - TabView 主畫面
3. `TextEditorView.swift` - 文字編輯器 UI
4. `CanvasEditorView.swift` - 畫布編輯器 UI（含 CanvasDrawingView）
5. `Info.plist` - App 設定
6. `Assets.xcassets` - 資源檔案
7. `Preview Content/` - SwiftUI Previews

**注意事項**：
- SwiftUI 需要 iOS 13+
- 使用 `@StateObject` 持有 ViewModel
- 使用 `@ObservedObject` 傳遞 ViewModel
- 透過 `$` 雙向綁定和 `.onReceive()` 訂閱 @Published

**驗證方式**：
- 在 iPhone 模擬器上運行
- 實際輸入文字、點擊 Undo/Redo
- 在畫布上繪製圖形、移動、改顏色
- 驗證所有操作都能正確 Undo/Redo

---

## 關鍵檔案清單

### 需要新增的檔案 (11 個)
1. `Sources/Models/Entities/Color.swift`
2. `Sources/Models/Entities/Point.swift`
3. `Sources/Models/Entities/Size.swift`
4. `Sources/Models/Protocols/TextDocumentProtocol.swift`
5. `Sources/Models/Protocols/CanvasProtocol.swift`
6. `Sources/Views/Extensions/Color+UIKit.swift`
7. `Sources/Views/Extensions/Point+CoreGraphics.swift`
8. `Sources/Views/Extensions/Size+CoreGraphics.swift`
9. `Tests/Mocks/MockTextDocument.swift`
10. `Tests/Mocks/MockCanvas.swift`
11. `Tests/Mocks/MockCommandHistory.swift`

### 需要修改的檔案 (13 個)
1. `Sources/Models/Entities/Shape.swift` - 使用自訂型別
2. `Sources/Models/Entities/Rectangle.swift` - 使用自訂型別
3. `Sources/Models/Entities/Circle.swift` - 使用自訂型別
4. `Sources/Models/Entities/Line.swift` - 使用自訂型別
5. `Sources/Models/Receivers/TextDocument.swift` - 實作 Protocol + MementoOriginator
6. `Sources/Models/Receivers/Canvas.swift` - 實作 Protocol + MementoOriginator
7. `Sources/Models/Command/CommandHistory.swift` - 確保實作 Protocol
8. 所有 TextCommands/*.swift - 使用 Protocol
9. 所有 CanvasCommands/*.swift - 使用 Protocol
10. `Sources/ViewModels/TextEditorViewModel.swift` - 使用 @Published
11. `Sources/ViewModels/CanvasEditorViewModel.swift` - 使用 @Published
12. `Sources/Views/TextEditorViewController.swift` - 訂閱 Combine Publishers
13. `Sources/Views/CanvasEditorViewController.swift` - 訂閱 Combine Publishers

---

## 驗證方式

### 編譯驗證
```bash
# 確保 Model 層只依賴 Foundation
grep -r "import UIKit" Sources/Models/
# 應該沒有任何輸出

grep -r "import CoreGraphics" Sources/Models/
# 應該沒有任何輸出（除了可能在 Point.swift 等內部實作）
```

### 測試驗證
```bash
# 執行所有單元測試
swift test

# 執行 ViewModel 測試（不應依賴 UIKit）
swift test --filter ViewModelTests
```

### 架構驗證
- ✅ ViewModel 不應 import UIKit
- ✅ Model 層完全不知道 View 層存在
- ✅ 可以在不啟動 UI 的情況下測試所有業務邏輯

---

## 結論

此計劃將目前設計改進為**完整 Clean Architecture**：
- ✅ 符合 SOLID 所有原則
- ✅ 完全解耦，高度可測試
- ✅ Foundation Only 限制
- ✅ 使用 Combine Framework 實現響應式架構
- ✅ Protocol 抽象層，易於擴展
- ✅ 遵循 Swift 現代開發最佳實踐

**檔案數量**：
- 新增：11 個
- 修改：13 個

**預估時間**：3 小時

**關鍵改進**：
1. 使用 `@Published` 取代 Delegate Pattern（更現代、更簡潔）
2. 移除不必要的 Caretaker（遵循 Swift 慣用方式）
3. Combine Framework 提供更好的資料流管理
4. 完全符合 Foundation-only 和 Clean Architecture 要求
