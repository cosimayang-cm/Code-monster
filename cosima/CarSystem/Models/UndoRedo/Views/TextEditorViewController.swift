//
//  TextEditorViewController.swift
//  CarSystem
//
//  Code Monster #3: Undo/Redo 系統
//  文字編輯器 UI（簡化版）
//

import UIKit
import Combine

/// 文字編輯器 ViewController
///
/// 簡化版 UI，使用按鈕觸發預設操作來展示 Undo/Redo 機制。
///
final class TextEditorViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel = TextEditorViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    /// 文件內容顯示
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .left
        label.backgroundColor = .secondarySystemBackground
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.text = "（空文件）"
        return label
    }()
    
    /// 狀態標籤
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
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
        stack.spacing = 12
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
        title = "文字編輯器"
        view.backgroundColor = .systemBackground
        
        // Undo/Redo 按鈕區
        let undoRedoStack = UIStackView(arrangedSubviews: [undoButton, redoButton])
        undoRedoStack.translatesAutoresizingMaskIntoConstraints = false
        undoRedoStack.axis = .horizontal
        undoRedoStack.spacing = 20
        undoRedoStack.distribution = .fillEqually
        
        // 操作按鈕
        let actions: [(String, Selector)] = [
            ("插入 \"Hello\"", #selector(insertHelloTapped)),
            ("插入 \" World\"", #selector(insertWorldTapped)),
            ("刪除最後 5 字元", #selector(deleteLast5Tapped)),
            ("取代 \"Hello\" → \"Hi\"", #selector(replaceHelloTapped)),
            ("套用粗體 (前5字)", #selector(applyBoldTapped)),
            ("套用斜體 (前5字)", #selector(applyItalicTapped)),
            ("清空文件", #selector(clearTapped)),
        ]
        
        for (title, action) in actions {
            let button = createActionButton(title: title, action: action)
            actionButtonsStack.addArrangedSubview(button)
        }
        
        // 加入 View
        view.addSubview(contentLabel)
        view.addSubview(statusLabel)
        view.addSubview(undoRedoStack)
        view.addSubview(actionButtonsStack)
        
        // Layout
        NSLayoutConstraint.activate([
            // 內容區
            contentLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            contentLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 100),
            
            // 狀態標籤
            statusLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 12),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            // Undo/Redo 按鈕
            undoRedoStack.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            undoRedoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            undoRedoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            undoRedoStack.heightAnchor.constraint(equalToConstant: 44),
            
            // 操作按鈕
            actionButtonsStack.topAnchor.constraint(equalTo: undoRedoStack.bottomAnchor, constant: 30),
            actionButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    private func createActionButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
    
    private func setupBindings() {
        // 綁定內容
        viewModel.$content
            .receive(on: DispatchQueue.main)
            .sink { [weak self] content in
                self?.contentLabel.text = content.isEmpty ? "（空文件）" : content
            }
            .store(in: &cancellables)
        
        // 綁定樣式資訊
        viewModel.$styleRanges
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ranges in
                self?.updateStyleInfo(ranges)
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
    
    private func updateStyleInfo(_ ranges: [StyleRange]) {
        if ranges.isEmpty {
            statusLabel.text = "字數: \(viewModel.content.count) | 無樣式"
        } else {
            let styleDesc = ranges.map { "\($0.range): \($0.style)" }.joined(separator: ", ")
            statusLabel.text = "字數: \(viewModel.content.count) | 樣式: \(styleDesc)"
        }
    }
    
    // MARK: - Actions
    
    @objc private func undoTapped() {
        viewModel.undo()
    }
    
    @objc private func redoTapped() {
        viewModel.redo()
    }
    
    @objc private func insertHelloTapped() {
        viewModel.insertText("Hello", at: viewModel.content.count)
    }
    
    @objc private func insertWorldTapped() {
        viewModel.insertText(" World", at: viewModel.content.count)
    }
    
    @objc private func deleteLast5Tapped() {
        let count = viewModel.content.count
        guard count >= 5 else { return }
        viewModel.deleteText(range: (count - 5)..<count)
    }
    
    @objc private func replaceHelloTapped() {
        guard let range = viewModel.content.range(of: "Hello") else { return }
        let start = viewModel.content.distance(from: viewModel.content.startIndex, to: range.lowerBound)
        let end = viewModel.content.distance(from: viewModel.content.startIndex, to: range.upperBound)
        viewModel.replaceText(range: start..<end, with: "Hi")
    }
    
    @objc private func applyBoldTapped() {
        guard viewModel.content.count >= 5 else { return }
        viewModel.applyStyle(.bold, to: 0..<5)
    }
    
    @objc private func applyItalicTapped() {
        guard viewModel.content.count >= 5 else { return }
        viewModel.applyStyle(.italic, to: 0..<5)
    }
    
    @objc private func clearTapped() {
        viewModel.clearDocument()
    }
}
