//
//  CanvasEditorViewController.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import UIKit

/// 畫布編輯器視圖控制器
/// FR-033: 畫布編輯器 UI
/// FR-034: Navigation Bar Undo/Redo 按鈕
/// FR-035: 底部工具列操作按鈕
/// FR-036: Pan gesture 拖曳移動圖形
final class CanvasEditorViewController: UIViewController, CommandHistoryObserver, CanvasViewDelegate {

    // MARK: - Model

    private let canvas = Canvas()
    private let history = CommandHistory()

    // MARK: - UI Elements

    private lazy var canvasView: CanvasView = {
        let view = CanvasView()
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var toolbar: UIToolbar = {
        let bar = UIToolbar()
        bar.translatesAutoresizingMaskIntoConstraints = false
        return bar
    }()

    private lazy var undoBarButton: UIBarButtonItem = {
        UIBarButtonItem(
            image: UIImage(systemName: "arrow.uturn.backward"),
            style: .plain,
            target: self,
            action: #selector(undoTapped)
        )
    }()

    private lazy var redoBarButton: UIBarButtonItem = {
        UIBarButtonItem(
            image: UIImage(systemName: "arrow.uturn.forward"),
            style: .plain,
            target: self,
            action: #selector(redoTapped)
        )
    }()

    // MARK: - Color Options

    private let availableColors: [Color] = [.red, .blue, .green, .black, .white]
    private var currentColorIndex = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupNavigation()
        setupToolbar()

        // 註冊為 Observer
        history.addObserver(self)
        updateButtonStates()
    }

    deinit {
        // 移除 Observer，避免記憶體洩漏
        history.removeObserver(self)
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "畫布編輯器"

        view.addSubview(canvasView)
        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            // CanvasView
            canvasView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            canvasView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            canvasView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            canvasView.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -16),

            // Toolbar
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupNavigation() {
        // Navigation Bar 右上角 Undo/Redo 按鈕 (FR-034)
        navigationItem.rightBarButtonItems = [redoBarButton, undoBarButton]
    }

    private func setupToolbar() {
        // 底部工具列按鈕 (FR-035)
        let addRectButton = UIBarButtonItem(title: "▢", style: .plain, target: self, action: #selector(addRectangleTapped))
        let addCircleButton = UIBarButtonItem(title: "○", style: .plain, target: self, action: #selector(addCircleTapped))
        let addLineButton = UIBarButtonItem(title: "╱", style: .plain, target: self, action: #selector(addLineTapped))
        let scaleUpButton = UIBarButtonItem(title: "➕", style: .plain, target: self, action: #selector(scaleUpTapped))
        let scaleDownButton = UIBarButtonItem(title: "➖", style: .plain, target: self, action: #selector(scaleDownTapped))
        let deleteButton = UIBarButtonItem(title: "🗑", style: .plain, target: self, action: #selector(deleteSelectedTapped))
        let colorButton = UIBarButtonItem(title: "🎨", style: .plain, target: self, action: #selector(changeColorTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        // 設定字體大小
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.systemFont(ofSize: 22)]
        addRectButton.setTitleTextAttributes(attributes, for: .normal)
        addCircleButton.setTitleTextAttributes(attributes, for: .normal)
        addLineButton.setTitleTextAttributes(attributes, for: .normal)
        scaleUpButton.setTitleTextAttributes(attributes, for: .normal)
        scaleDownButton.setTitleTextAttributes(attributes, for: .normal)
        deleteButton.setTitleTextAttributes(attributes, for: .normal)
        colorButton.setTitleTextAttributes(attributes, for: .normal)

        toolbar.items = [
            addRectButton,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            addCircleButton,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            addLineButton,
            flexSpace,
            scaleUpButton,
            scaleDownButton,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            deleteButton,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            colorButton
        ]
    }

    // MARK: - Actions (FR-035)

    @objc private func undoTapped() {
        history.undo()
        refreshCanvasView()
    }

    @objc private func redoTapped() {
        history.redo()
        refreshCanvasView()
    }

    @objc private func addRectangleTapped() {
        let rect = Rectangle(
            id: UUID(),
            position: randomPosition(),
            size: Size(width: 80, height: 60),
            fillColor: currentColor(),
            strokeColor: .black
        )
        let command = AddShapeCommand(canvas: canvas, shape: rect)
        history.execute(command)
        refreshCanvasView()
    }

    @objc private func addCircleTapped() {
        let circle = Circle(
            id: UUID(),
            position: randomPosition(),
            radius: 40,
            fillColor: currentColor(),
            strokeColor: .black
        )
        let command = AddShapeCommand(canvas: canvas, shape: circle)
        history.execute(command)
        refreshCanvasView()
    }

    @objc private func addLineTapped() {
        let startPos = randomPosition()
        let endPos = Point(x: startPos.x + 80, y: startPos.y + 60)
        let line = Line(
            id: UUID(),
            position: startPos,
            endPoint: endPos,
            strokeColor: currentColor()
        )
        let command = AddShapeCommand(canvas: canvas, shape: line)
        history.execute(command)
        refreshCanvasView()
    }

    @objc private func deleteSelectedTapped() {
        guard let selectedId = canvasView.selectedShapeId else {
            // 顯示提示：請先選擇圖形
            let alert = UIAlertController(title: "提示", message: "請先點選要刪除的圖形", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default))
            present(alert, animated: true)
            return
        }

        let command = RemoveShapeCommand(canvas: canvas, shapeId: selectedId)
        history.execute(command)
        refreshCanvasView()
    }

    @objc private func changeColorTapped() {
        guard let selectedId = canvasView.selectedShapeId,
              var shape = canvas.shape(withId: selectedId) else {
            // 顯示提示：請先選擇圖形
            let alert = UIAlertController(title: "提示", message: "請先點選要變更顏色的圖形", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default))
            present(alert, animated: true)
            return
        }

        // 切換到下一個顏色
        currentColorIndex = (currentColorIndex + 1) % availableColors.count
        let newColor = availableColors[currentColorIndex]

        let command = ChangeColorCommand(
            canvas: canvas,
            shapeId: selectedId,
            fillColor: newColor,
            strokeColor: shape.strokeColor
        )
        history.execute(command)
        refreshCanvasView()
    }

    @objc private func scaleUpTapped() {
        resizeSelectedShape(scaleFactor: 1.2)
    }

    @objc private func scaleDownTapped() {
        resizeSelectedShape(scaleFactor: 0.8)
    }

    private func resizeSelectedShape(scaleFactor: Double) {
        guard let selectedId = canvasView.selectedShapeId,
              let shape = canvas.shape(withId: selectedId) else {
            let alert = UIAlertController(title: "提示", message: "請先點選要縮放的圖形", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default))
            present(alert, animated: true)
            return
        }

        // 計算新尺寸
        let newSize: Size
        if let rect = shape as? Rectangle {
            newSize = Size(
                width: rect.size.width * scaleFactor,
                height: rect.size.height * scaleFactor
            )
        } else if let circle = shape as? Circle {
            let diameter = circle.radius * 2 * scaleFactor
            newSize = Size(width: diameter, height: diameter)
        } else {
            // 線條不支援縮放
            let alert = UIAlertController(title: "提示", message: "線條不支援縮放", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "確定", style: .default))
            present(alert, animated: true)
            return
        }

        let command = ResizeShapeCommand(canvas: canvas, shapeId: selectedId, newSize: newSize)
        history.execute(command)
        refreshCanvasView()
    }

    // MARK: - Helpers

    private func randomPosition() -> Point {
        let maxX = canvasView.bounds.width - 100
        let maxY = canvasView.bounds.height - 100
        return Point(
            x: Double.random(in: 20...max(20, maxX)),
            y: Double.random(in: 20...max(20, maxY))
        )
    }

    private func currentColor() -> Color {
        return availableColors[currentColorIndex]
    }

    // MARK: - UI Update

    private func refreshCanvasView() {
        canvasView.sync(with: canvas)
    }

    private func updateButtonStates() {
        undoBarButton.isEnabled = history.canUndo
        redoBarButton.isEnabled = history.canRedo
    }

    // MARK: - CommandHistoryObserver

    func commandHistoryDidChange(_ history: CommandHistory) {
        updateButtonStates()
    }

    // MARK: - CanvasViewDelegate (FR-036)

    func canvasView(_ view: CanvasView, didMoveShape id: UUID, by offset: Point) {
        let command = MoveShapeCommand(canvas: canvas, shapeId: id, offset: offset)
        history.execute(command)
        refreshCanvasView()
    }

    func canvasView(_ view: CanvasView, didSelectShape id: UUID) {
        // 圖形被選中，可以在這裡加入額外邏輯
    }
}
