#if canImport(UIKit)
import UIKit
import Combine

/// CanvasEditorViewController - 畫布編輯器 UI
///
/// 遵循 PAGEs Framework ViewController 模式，使用 Combine 訂閱 ViewModel 的 @Published 屬性。
/// 負責畫布渲染、圖形繪製與使用者互動，不包含業務邏輯。
///
/// Design rationale:
/// - 使用 constructor-based dependency injection 注入 ViewModel
/// - 使用 Combine 訂閱 @Published 屬性實現響應式 UI
/// - 使用 weak self 避免 retain cycle
/// - UI 層只負責顯示和事件轉發，業務邏輯由 ViewModel 處理
/// - 使用 Extensions (Color+UIKit, Point+CoreGraphics) 轉換 Model 型別到 UIKit
///
/// Architecture:
/// - ViewController (UI layer) → ViewModel (Presentation layer) → Model (Domain layer)
/// - 單向資料流：ViewModel @Published → ViewController UI update
/// - 事件流：User action → ViewController → ViewModel method
public final class CanvasEditorViewController: UIViewController {
    // MARK: - UI Components

    /// 畫布視圖
    private lazy var canvasView: CanvasView = {
        let view = CanvasView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()

    /// Undo 按鈕
    private lazy var undoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("復原", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(undoButtonTapped), for: .touchUpInside)
        return button
    }()

    /// Redo 按鈕
    private lazy var redoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("重做", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(redoButtonTapped), for: .touchUpInside)
        return button
    }()

    /// 工具列容器
    private lazy var toolbarStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [undoButton, redoButton])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    // MARK: - Properties

    /// ViewModel（使用 constructor-based dependency injection）
    private let viewModel: CanvasEditorViewModel

    /// Combine 訂閱儲存
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    /// 建立 CanvasEditorViewController
    ///
    /// - Parameter viewModel: CanvasEditorViewModel 實例（dependency injection）
    public init(viewModel: CanvasEditorViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - use init(viewModel:)")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    // MARK: - UI Setup

    /// 設定 UI 佈局
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "畫布編輯器"

        view.addSubview(toolbarStackView)
        view.addSubview(canvasView)

        NSLayoutConstraint.activate([
            // Toolbar
            toolbarStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            toolbarStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toolbarStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),

            // Canvas
            canvasView.topAnchor.constraint(equalTo: toolbarStackView.bottomAnchor, constant: 16),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            canvasView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    // MARK: - Combine Bindings

    /// 設定 Combine 綁定
    ///
    /// 訂閱 ViewModel 的 @Published 屬性，實現響應式 UI 更新。
    /// 使用 weak self 避免 retain cycle。
    private func setupBindings() {
        // 訂閱圖形陣列變更
        viewModel.$shapes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shapes in
                self?.canvasView.shapes = shapes
                self?.canvasView.setNeedsDisplay()
            }
            .store(in: &cancellables)

        // 訂閱 Undo 狀態
        viewModel.$canUndo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canUndo in
                self?.undoButton.isEnabled = canUndo
            }
            .store(in: &cancellables)

        // 訂閱 Undo 按鈕標題
        viewModel.$undoButtonTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.undoButton.setTitle(title, for: .normal)
            }
            .store(in: &cancellables)

        // 訂閱 Redo 狀態
        viewModel.$canRedo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canRedo in
                self?.redoButton.isEnabled = canRedo
            }
            .store(in: &cancellables)

        // 訂閱 Redo 按鈕標題
        viewModel.$redoButtonTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] title in
                self?.redoButton.setTitle(title, for: .normal)
            }
            .store(in: &cancellables)

        // 訂閱選取的圖形 ID
        viewModel.$selectedShapeId
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedId in
                self?.canvasView.selectedShapeId = selectedId
                self?.canvasView.setNeedsDisplay()
            }
            .store(in: &cancellables)
    }

    // MARK: - Actions

    /// Undo 按鈕點擊事件
    @objc private func undoButtonTapped() {
        viewModel.undo()
    }

    /// Redo 按鈕點擊事件
    @objc private func redoButtonTapped() {
        viewModel.redo()
    }
}

// MARK: - CanvasView

/// 自訂畫布視圖，負責繪製圖形
///
/// 使用 Core Graphics 繪製圖形，使用 Extensions 轉換 Model 型別到 UIKit。
private final class CanvasView: UIView {
    /// 要繪製的圖形陣列
    var shapes: [Shape] = []

    /// 目前選取的圖形 ID
    var selectedShapeId: UUID?

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }

        for shape in shapes {
            drawShape(shape, in: context, isSelected: shape.id == selectedShapeId)
        }
    }

    /// 繪製單一圖形
    ///
    /// - Parameters:
    ///   - shape: 要繪製的圖形
    ///   - context: Core Graphics 繪圖上下文
    ///   - isSelected: 是否為選取狀態
    private func drawShape(_ shape: Shape, in context: CGContext, isSelected: Bool) {
        // 使用 Extensions 轉換 Model 型別到 UIKit
        if let rectangle = shape as? Rectangle {
            drawRectangle(rectangle, in: context, isSelected: isSelected)
        } else if let circle = shape as? Circle {
            drawCircle(circle, in: context, isSelected: isSelected)
        } else if let line = shape as? Line {
            drawLine(line, in: context, isSelected: isSelected)
        }
    }

    /// 繪製矩形
    private func drawRectangle(_ rectangle: Rectangle, in context: CGContext, isSelected: Bool) {
        let rect = CGRect(
            origin: rectangle.position.cgPoint,
            size: rectangle.size.cgSize
        )

        // 填充顏色
        if let fillColor = rectangle.fillColor {
            context.setFillColor(fillColor.uiColor.cgColor)
            context.fill(rect)
        }

        // 邊框顏色
        if let strokeColor = rectangle.strokeColor {
            context.setStrokeColor(strokeColor.uiColor.cgColor)
            context.setLineWidth(isSelected ? 3.0 : 1.0)
            context.stroke(rect)
        }

        // 選取指示器
        if isSelected {
            context.setStrokeColor(UIColor.systemBlue.cgColor)
            context.setLineWidth(2.0)
            context.setLineDash(phase: 0, lengths: [5, 3])
            context.stroke(rect)
            context.setLineDash(phase: 0, lengths: [])
        }
    }

    /// 繪製圓形
    private func drawCircle(_ circle: Circle, in context: CGContext, isSelected: Bool) {
        let rect = CGRect(
            x: circle.position.x - circle.radius,
            y: circle.position.y - circle.radius,
            width: circle.radius * 2,
            height: circle.radius * 2
        )

        // 填充顏色
        if let fillColor = circle.fillColor {
            context.setFillColor(fillColor.uiColor.cgColor)
            context.fillEllipse(in: rect)
        }

        // 邊框顏色
        if let strokeColor = circle.strokeColor {
            context.setStrokeColor(strokeColor.uiColor.cgColor)
            context.setLineWidth(isSelected ? 3.0 : 1.0)
            context.strokeEllipse(in: rect)
        }

        // 選取指示器
        if isSelected {
            context.setStrokeColor(UIColor.systemBlue.cgColor)
            context.setLineWidth(2.0)
            context.setLineDash(phase: 0, lengths: [5, 3])
            context.strokeEllipse(in: rect)
            context.setLineDash(phase: 0, lengths: [])
        }
    }

    /// 繪製線條
    private func drawLine(_ line: Line, in context: CGContext, isSelected: Bool) {
        let startPoint = line.position.cgPoint
        let endPoint = line.endPoint.cgPoint

        context.move(to: startPoint)
        context.addLine(to: endPoint)

        if let strokeColor = line.strokeColor {
            context.setStrokeColor(strokeColor.uiColor.cgColor)
        } else {
            context.setStrokeColor(UIColor.black.cgColor)
        }

        context.setLineWidth(isSelected ? 3.0 : 1.0)
        context.strokePath()

        // 選取指示器
        if isSelected {
            // 在線條端點繪製控制點
            let handleRadius: CGFloat = 5.0
            context.setFillColor(UIColor.systemBlue.cgColor)
            context.fillEllipse(in: CGRect(
                x: startPoint.x - handleRadius,
                y: startPoint.y - handleRadius,
                width: handleRadius * 2,
                height: handleRadius * 2
            ))
            context.fillEllipse(in: CGRect(
                x: endPoint.x - handleRadius,
                y: endPoint.y - handleRadius,
                width: handleRadius * 2,
                height: handleRadius * 2
            ))
        }
    }
}
#endif
