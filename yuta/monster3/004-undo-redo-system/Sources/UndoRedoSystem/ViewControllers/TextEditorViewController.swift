#if canImport(UIKit)
import UIKit
import Combine

/// TextEditorViewController - 文字編輯器 UI
///
/// 遵循 PAGEs Framework ViewController 模式，使用 Combine 訂閱 ViewModel 的 @Published 屬性。
/// 負責 UI 渲染與使用者互動，不包含業務邏輯。
///
/// Design rationale:
/// - 使用 constructor-based dependency injection 注入 ViewModel
/// - 使用 Combine 訂閱 @Published 屬性實現響應式 UI
/// - 使用 weak self 避免 retain cycle
/// - UI 層只負責顯示和事件轉發，業務邏輯由 ViewModel 處理
///
/// Architecture:
/// - ViewController (UI layer) → ViewModel (Presentation layer) → Model (Domain layer)
/// - 單向資料流：ViewModel @Published → ViewController UI update
/// - 事件流：User action → ViewController → ViewModel method
public final class TextEditorViewController: UIViewController {
    // MARK: - UI Components

    /// 文字編輯區域
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        return textView
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
    private let viewModel: TextEditorViewModel

    /// Combine 訂閱儲存
    private var cancellables = Set<AnyCancellable>()

    /// 是否正在程式化更新文字（避免遞迴更新）
    private var isProgrammaticUpdate = false

    // MARK: - Initialization

    /// 建立 TextEditorViewController
    ///
    /// - Parameter viewModel: TextEditorViewModel 實例（dependency injection）
    public init(viewModel: TextEditorViewModel) {
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
        title = "文字編輯器"

        view.addSubview(toolbarStackView)
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            // Toolbar
            toolbarStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            toolbarStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            toolbarStackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16),

            // TextView
            textView.topAnchor.constraint(equalTo: toolbarStackView.bottomAnchor, constant: 16),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    // MARK: - Combine Bindings

    /// 設定 Combine 綁定
    ///
    /// 訂閱 ViewModel 的 @Published 屬性，實現響應式 UI 更新。
    /// 使用 weak self 避免 retain cycle。
    private func setupBindings() {
        // 訂閱文字內容變更
        viewModel.$text
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newText in
                self?.updateTextView(with: newText)
            }
            .store(in: &cancellables)

        // 訂閱 Undo 狀態
        viewModel.$canUndo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canUndo in
                self?.undoButton.isEnabled = canUndo
            }
            .store(in: &cancellables)

        // 訂閱 Redo 狀態
        viewModel.$canRedo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] canRedo in
                self?.redoButton.isEnabled = canRedo
            }
            .store(in: &cancellables)
    }

    // MARK: - UI Updates

    /// 更新 TextView 內容
    ///
    /// 避免在程式化更新時觸發 UITextViewDelegate 回調，防止遞迴更新。
    ///
    /// - Parameter text: 新的文字內容
    private func updateTextView(with text: String) {
        guard textView.text != text else { return }

        isProgrammaticUpdate = true
        textView.text = text
        isProgrammaticUpdate = false
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

// MARK: - UITextViewDelegate

extension TextEditorViewController: UITextViewDelegate {
    /// 文字變更時的回調
    ///
    /// 將使用者輸入轉發給 ViewModel 處理。
    /// 注意：只有使用者輸入才會觸發，程式化更新時會跳過。
    public func textViewDidChange(_ textView: UITextView) {
        guard !isProgrammaticUpdate else { return }

        let newText = textView.text ?? ""
        let oldText = viewModel.text

        // 計算變更範圍並建立對應命令
        if newText.count > oldText.count {
            // 插入文字
            let insertedText = String(newText.dropFirst(oldText.count))
            viewModel.insert(insertedText, at: oldText.count)
        } else if newText.count < oldText.count {
            // 刪除文字
            let deletedCount = oldText.count - newText.count
            let range = NSRange(location: newText.count, length: deletedCount)
            viewModel.delete(in: range)
        }
    }
}
#endif
