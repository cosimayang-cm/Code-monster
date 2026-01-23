//
//  TextEditorViewController.swift
//  CodeMonster
//
//  Created by Claude on 2026/1/23.
//

import UIKit

/// 文字編輯器視圖控制器
/// FR-030: 文字編輯器 UI
/// FR-031: Navigation Bar Undo/Redo 按鈕
/// FR-032: 底部工具列操作按鈕
final class TextEditorViewController: UIViewController, CommandHistoryObserver {

    // MARK: - Model

    private let document = TextDocument()
    private let history = CommandHistory()

    // MARK: - UI Elements

    private lazy var textView: UITextView = {
        let tv = UITextView()
        tv.font = .systemFont(ofSize: 16)
        tv.isEditable = false  // 使用按鈕操作，非直接編輯
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
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
        title = "文字編輯器"

        view.addSubview(textView)
        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            // TextView
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: toolbar.topAnchor, constant: -16),

            // Toolbar
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    private func setupNavigation() {
        // Navigation Bar 右上角 Undo/Redo 按鈕 (FR-031)
        navigationItem.rightBarButtonItems = [redoBarButton, undoBarButton]
    }

    private func setupToolbar() {
        // 底部工具列按鈕 (FR-032)
        let insertButton = UIBarButtonItem(title: "插入", style: .plain, target: self, action: #selector(insertButtonTapped))
        let deleteButton = UIBarButtonItem(title: "刪除", style: .plain, target: self, action: #selector(deleteButtonTapped))
        let replaceButton = UIBarButtonItem(title: "取代", style: .plain, target: self, action: #selector(replaceButtonTapped))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let boldButton = UIBarButtonItem(title: "B", style: .plain, target: self, action: #selector(boldButtonTapped))
        let italicButton = UIBarButtonItem(title: "I", style: .plain, target: self, action: #selector(italicButtonTapped))
        let underlineButton = UIBarButtonItem(title: "U", style: .plain, target: self, action: #selector(underlineButtonTapped))

        // 設定粗體/斜體/底線按鈕的樣式
        boldButton.setTitleTextAttributes([.font: UIFont.boldSystemFont(ofSize: 17)], for: .normal)
        italicButton.setTitleTextAttributes([.font: UIFont.italicSystemFont(ofSize: 17)], for: .normal)
        underlineButton.setTitleTextAttributes([.underlineStyle: NSUnderlineStyle.single.rawValue], for: .normal)

        toolbar.items = [
            insertButton,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            deleteButton,
            UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil),
            replaceButton,
            flexSpace,
            boldButton,
            italicButton,
            underlineButton
        ]
    }

    // MARK: - Actions (FR-032)

    @objc private func undoTapped() {
        history.undo()
        refreshTextView()
    }

    @objc private func redoTapped() {
        history.redo()
        refreshTextView()
    }

    @objc private func insertButtonTapped() {
        // 在文件末尾插入範例文字
        let sampleTexts = ["Hello ", "World ", "Swift ", "Undo ", "Redo "]
        let randomText = sampleTexts.randomElement() ?? "Text "

        let command = InsertTextCommand(
            document: document,
            text: randomText,
            at: document.content.endIndex
        )
        history.execute(command)
        refreshTextView()
    }

    @objc private func deleteButtonTapped() {
        // 刪除最後一個字元
        guard !document.content.isEmpty else { return }

        let startIndex = document.content.index(before: document.content.endIndex)
        let range = startIndex..<document.content.endIndex

        let command = DeleteTextCommand(document: document, range: range)
        history.execute(command)
        refreshTextView()
    }

    @objc private func replaceButtonTapped() {
        // 將最後一個單字替換為 "[replaced]"
        guard document.content.count >= 3 else { return }

        let endIndex = document.content.endIndex
        let startIndex = document.content.index(endIndex, offsetBy: -3)
        let range = startIndex..<endIndex

        let command = ReplaceTextCommand(
            document: document,
            range: range,
            newText: "[X]"
        )
        history.execute(command)
        refreshTextView()
    }

    @objc private func boldButtonTapped() {
        applyStyle(.bold)
    }

    @objc private func italicButtonTapped() {
        applyStyle(.italic)
    }

    @objc private func underlineButtonTapped() {
        applyStyle(.underline)
    }

    private func applyStyle(_ style: TextStyle) {
        // 對整個文件套用樣式（示範用）
        guard !document.content.isEmpty else { return }

        let range = document.content.startIndex..<document.content.endIndex
        let command = ApplyStyleCommand(document: document, range: range, style: style)
        history.execute(command)
        refreshTextView()
    }

    // MARK: - UI Update

    private func refreshTextView() {
        textView.text = document.content

        // 如果有樣式，套用 attributed string
        if !document.styles.isEmpty {
            let attributedString = NSMutableAttributedString(string: document.content)

            for styleRange in document.styles {
                // 將 String.Index 轉換為 NSRange
                let start = document.content.distance(from: document.content.startIndex, to: styleRange.range.lowerBound)
                let length = document.content.distance(from: styleRange.range.lowerBound, to: styleRange.range.upperBound)
                let nsRange = NSRange(location: start, length: length)

                // 套用樣式
                if styleRange.style.contains(.bold) {
                    attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 16), range: nsRange)
                }
                if styleRange.style.contains(.italic) {
                    attributedString.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: 16), range: nsRange)
                }
                if styleRange.style.contains(.underline) {
                    attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
                }
            }

            textView.attributedText = attributedString
        }
    }

    private func updateButtonStates() {
        undoBarButton.isEnabled = history.canUndo
        redoBarButton.isEnabled = history.canRedo
    }

    // MARK: - CommandHistoryObserver

    func commandHistoryDidChange(_ history: CommandHistory) {
        updateButtonStates()
    }
}
