//
//  CanvasEditorViewController.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  畫布編輯器 UI（簡化版）
//

import UIKit
import Combine

/// 畫布編輯器 ViewController
///
/// 簡化版 UI，使用按鈕觸發預設操作來展示 Undo/Redo 機制。
/// 畫布使用簡單的 UIView 繪製圖形。
///
final class CanvasEditorViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = CanvasEditorViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    /// 畫布視圖
    private lazy var canvasView: CanvasView = {
        let view = CanvasView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.cornerRadius = 8
        return view
    }()
    
    /// 狀態標籤
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.text = "圖形數量: 0"
        return label
    }()
    
    /// Undo 按鈕
    private lazy var undoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Undo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(undoTapped), for: .touchUpInside)
        return button
    }()
    
    /// Redo 按鈕
    private lazy var redoButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Redo", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.addTarget(self, action: #selector(redoTapped), for: .touchUpInside)
        return button
    }()
    
    /// 操作按鈕堆疊
    private lazy var actionButtonsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 10
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        title = "畫布編輯器"
        view.backgroundColor = .systemBackground
        
        // Undo/Redo 按鈕區
        let undoRedoStack = UIStackView(arrangedSubviews: [undoButton, redoButton])
        undoRedoStack.translatesAutoresizingMaskIntoConstraints = false
        undoRedoStack.axis = .horizontal
        undoRedoStack.spacing = 20
        undoRedoStack.distribution = .fillEqually
        
        // 操作按鈕 - 分兩列
        let row1 = createButtonRow([
            ("新增圓形", #selector(addCircleTapped)),
            ("新增矩形", #selector(addRectangleTapped)),
        ])
        
        let row2 = createButtonRow([
            ("新增線條", #selector(addLineTapped)),
            ("刪除最後一個", #selector(removeLastTapped)),
        ])
        
        let row3 = createButtonRow([
            ("移動 (+20, +20)", #selector(moveLastTapped)),
            ("變更顏色", #selector(changeColorTapped)),
        ])
        
        let row4 = createButtonRow([
            ("縮放 x1.5", #selector(resizeTapped)),
            ("清空畫布", #selector(clearTapped)),
        ])
        
        actionButtonsStack.addArrangedSubview(row1)
        actionButtonsStack.addArrangedSubview(row2)
        actionButtonsStack.addArrangedSubview(row3)
        actionButtonsStack.addArrangedSubview(row4)
        
        // 加入 View
        view.addSubview(canvasView)
        view.addSubview(statusLabel)
        view.addSubview(undoRedoStack)
        view.addSubview(actionButtonsStack)
        
        // Layout
        NSLayoutConstraint.activate([
            // 畫布
            canvasView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            canvasView.heightAnchor.constraint(equalToConstant: 250),
            
            // 狀態標籤
            statusLabel.topAnchor.constraint(equalTo: canvasView.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Undo/Redo 按鈕
            undoRedoStack.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 16),
            undoRedoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            undoRedoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            undoRedoStack.heightAnchor.constraint(equalToConstant: 44),
            
            // 操作按鈕
            actionButtonsStack.topAnchor.constraint(equalTo: undoRedoStack.bottomAnchor, constant: 20),
            actionButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func createButtonRow(_ buttons: [(String, Selector)]) -> UIStackView {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        
        for (title, action) in buttons {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14)
            button.backgroundColor = .systemBlue.withAlphaComponent(0.1)
            button.layer.cornerRadius = 8
            button.heightAnchor.constraint(equalToConstant: 36).isActive = true
            button.addTarget(self, action: action, for: .touchUpInside)
            stack.addArrangedSubview(button)
        }
        
        return stack
    }
    
    private func setupBindings() {
        // 綁定圖形
        viewModel.$shapes
            .receive(on: DispatchQueue.main)
            .sink { [weak self] shapes in
                self?.canvasView.shapes = shapes
                self?.statusLabel.text = "圖形數量: \(shapes.count)"
            }
            .store(in: &cancellables)
        
        // 綁定 Undo 按鈕
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
        
        // 綁定 Redo 按鈕
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
    }
    
    // MARK: - Actions
    
    @objc private func undoTapped() {
        viewModel.undo()
    }
    
    @objc private func redoTapped() {
        viewModel.redo()
    }
    
    @objc private func addCircleTapped() {
        let x = Double.random(in: 50...250)
        let y = Double.random(in: 50...200)
        viewModel.addCircle(at: Point(x: x, y: y), radius: 30, fillColor: .blue, strokeColor: .black)
    }
    
    @objc private func addRectangleTapped() {
        let x = Double.random(in: 30...200)
        let y = Double.random(in: 30...150)
        viewModel.addRectangle(at: Point(x: x, y: y), size: Size(width: 60, height: 40), fillColor: .green, strokeColor: .black)
    }
    
    @objc private func addLineTapped() {
        let x1 = Double.random(in: 30...150)
        let y1 = Double.random(in: 30...150)
        let x2 = x1 + Double.random(in: 50...100)
        let y2 = y1 + Double.random(in: 30...80)
        viewModel.addLine(from: Point(x: x1, y: y1), to: Point(x: x2, y: y2), strokeColor: .red)
    }
    
    @objc private func removeLastTapped() {
        guard let lastShape = viewModel.shapes.last else { return }
        viewModel.removeShape(shapeId: lastShape.id)
    }
    
    @objc private func moveLastTapped() {
        guard let lastShape = viewModel.shapes.last else { return }
        viewModel.moveShape(shapeId: lastShape.id, offset: Point(x: 20, y: 20))
    }
    
    @objc private func changeColorTapped() {
        guard let lastShape = viewModel.shapes.last else { return }
        let colors: [Color] = [.red, .green, .blue, .yellow]
        let randomColor = colors.randomElement() ?? .red
        viewModel.changeColor(shapeId: lastShape.id, fillColor: randomColor)
    }
    
    @objc private func resizeTapped() {
        guard let lastShape = viewModel.shapes.last else { return }
        
        if let rect = lastShape as? Rectangle {
            let newSize = Size(width: rect.size.width * 1.5, height: rect.size.height * 1.5)
            viewModel.resizeRectangle(shapeId: rect.id, newSize: newSize)
        } else if let circle = lastShape as? Circle {
            viewModel.resizeCircle(shapeId: circle.id, newRadius: circle.radius * 1.5)
        }
    }
    
    @objc private func clearTapped() {
        viewModel.clearCanvas()
    }
}

// MARK: - CanvasView

/// 簡單的畫布視圖，用於繪製圖形
final class CanvasView: UIView {
    
    var shapes: [Shape] = [] {
        didSet { setNeedsDisplay() }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        for shape in shapes {
            drawShape(shape, in: context)
        }
    }
    
    private func drawShape(_ shape: Shape, in context: CGContext) {
        context.saveGState()
        
        // 設定填充色
        let fillColor = UIColor(
            red: shape.fillColor.red,
            green: shape.fillColor.green,
            blue: shape.fillColor.blue,
            alpha: shape.fillColor.alpha
        )
        
        // 設定邊框色
        let strokeColor = UIColor(
            red: shape.strokeColor.red,
            green: shape.strokeColor.green,
            blue: shape.strokeColor.blue,
            alpha: shape.strokeColor.alpha
        )
        
        context.setFillColor(fillColor.cgColor)
        context.setStrokeColor(strokeColor.cgColor)
        context.setLineWidth(2)
        
        switch shape {
        case let rect as Rectangle:
            let frame = CGRect(
                x: rect.position.x,
                y: rect.position.y,
                width: rect.size.width,
                height: rect.size.height
            )
            context.fill(frame)
            context.stroke(frame)
            
        case let circle as Circle:
            let frame = CGRect(
                x: circle.position.x - circle.radius,
                y: circle.position.y - circle.radius,
                width: circle.radius * 2,
                height: circle.radius * 2
            )
            context.fillEllipse(in: frame)
            context.strokeEllipse(in: frame)
            
        case let line as Line:
            context.move(to: CGPoint(x: line.position.x, y: line.position.y))
            context.addLine(to: CGPoint(x: line.endPoint.x, y: line.endPoint.y))
            context.strokePath()
            
        default:
            break
        }
        
        context.restoreGState()
    }
}
