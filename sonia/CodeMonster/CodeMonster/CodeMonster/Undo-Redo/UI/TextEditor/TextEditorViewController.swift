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
        tv.isSelectable = true // 允許選取文字以進行取代操作
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "點擊「快速新增隨機字詞」插入文字，或選取文字後點擊「取代」輸入自訂內容"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

        view.addSubview(instructionLabel)
        view.addSubview(textView)
        view.addSubview(toolbar)

        NSLayoutConstraint.activate([
            // Instruction Label
            instructionLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            // TextView
            textView.topAnchor.constraint(equalTo: instructionLabel.bottomAnchor, constant: 12),
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
        let insertButton = UIBarButtonItem(title: "快速新增隨機字詞", style: .plain, target: self, action: #selector(insertButtonTapped))
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
        // 檢查是否有選取範圍
        let selectedNSRange = textView.selectedRange
        guard selectedNSRange.length > 0 else {
            showAlert(title: "請先選取文字", message: "請在文字區域中選取要取代的文字範圍")
            return
        }

        // 將 NSRange 轉換為 String.Index
        guard let stringRange = Range(selectedNSRange, in: document.content) else { return }

        let selectedText = String(document.content[stringRange])

        // 彈出輸入框讓用戶輸入新文案
        let alert = UIAlertController(
            title: "取代文字",
            message: "將「\(selectedText)」取代為：",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "輸入新文字"
        }

        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        alert.addAction(UIAlertAction(title: "取代", style: .default) { [weak self] _ in
            guard let self = self,
                  let newText = alert.textFields?.first?.text else { return }

            let command = ReplaceTextCommand(
                document: self.document,
                range: stringRange,
                newText: newText
            )
            self.history.execute(command)
            self.refreshTextView()
        })

        present(alert, animated: true)
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default))
        present(alert, animated: true)
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
        guard !document.content.isEmpty else { return }

        // 檢查是否有選取範圍，有則套用到選取範圍，否則套用到整個文件
        let selectedNSRange = textView.selectedRange
        let range: Range<String.Index>

        if selectedNSRange.length > 0,
           let stringRange = Range(selectedNSRange, in: document.content) {
            range = stringRange
        } else {
            range = document.content.startIndex..<document.content.endIndex
        }

        // Toggle 邏輯：如果已有該樣式則移除，否則套用
        if document.hasStyle(style, in: range) {
            let command = RemoveStyleCommand(document: document, range: range, style: style)
            history.execute(command)
        } else {
            let command = ApplyStyleCommand(document: document, range: range, style: style)
            history.execute(command)
        }
        refreshTextView()
    }

    // MARK: - UI Update

    private func refreshTextView() {
        guard !document.content.isEmpty else {
            textView.text = ""
            return
        }

        let attributedString = NSMutableAttributedString(string: document.content)
        let fullRange = NSRange(location: 0, length: document.content.count)

        // 預設字體
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: fullRange)

        // 收集同一範圍的所有樣式並合併
        var stylesByRange: [Range<String.Index>: TextStyle] = [:]
        for styleRange in document.styles {
            if var existing = stylesByRange[styleRange.range] {
                existing.insert(styleRange.style)
                stylesByRange[styleRange.range] = existing
            } else {
                stylesByRange[styleRange.range] = styleRange.style
            }
        }

        // 套用合併後的樣式
        for (range, style) in stylesByRange {
            let start = document.content.distance(from: document.content.startIndex, to: range.lowerBound)
            let length = document.content.distance(from: range.lowerBound, to: range.upperBound)
            let nsRange = NSRange(location: start, length: length)

            // 使用 UIFontDescriptor 組合粗體和斜體
            var traits: UIFontDescriptor.SymbolicTraits = []
            if style.contains(.bold) {
                traits.insert(.traitBold)
            }
            if style.contains(.italic) {
                traits.insert(.traitItalic)
            }

            if !traits.isEmpty {
                if let descriptor = UIFont.systemFont(ofSize: 16).fontDescriptor.withSymbolicTraits(traits) {
                    let font = UIFont(descriptor: descriptor, size: 16)
                    attributedString.addAttribute(.font, value: font, range: nsRange)
                }
            }

            // 底線獨立處理
            if style.contains(.underline) {
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: nsRange)
            }
        }

        textView.attributedText = attributedString
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
