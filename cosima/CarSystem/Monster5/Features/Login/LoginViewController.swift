//
//  LoginViewController.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import UIKit
import ComposableArchitecture

final class LoginViewController: UIViewController {
    let store: StoreOf<LoginFeature>

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Monster5"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "TCA + UIKit 整合實戰"
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let usernameField: UITextField = {
        let field = UITextField()
        field.placeholder = "帳號 (emilys)"
        field.borderStyle = .roundedRect
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .next
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let passwordField: UITextField = {
        let field = UITextField()
        field.placeholder = "密碼 (emilyspass)"
        field.borderStyle = .roundedRect
        field.isSecureTextEntry = true
        field.returnKeyType = .done
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("登入", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.lightGray, for: .disabled)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.color = .white
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Callbacks

    var onLoginSuccess: ((User) -> Void)?

    // MARK: - Toast tracking

    private var lastErrorMessage: String?

    // MARK: - Init

    init(store: StoreOf<LoginFeature>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()

        observe { [weak self] in
            guard let self else { return }

            // 更新 loading 狀態
            loginButton.isEnabled = !store.isLoading
            if store.isLoading {
                loginButton.backgroundColor = .systemGray4
                loadingIndicator.startAnimating()
            } else {
                loginButton.backgroundColor = .systemBlue
                loadingIndicator.stopAnimating()
            }

            // 登入成功 → 回調
            if let user = store.user {
                onLoginSuccess?(user)
            }

            // 顯示 Error Toast
            let currentError = store.errorMessage
            if let message = currentError, message != lastErrorMessage {
                ToastView.show(in: view, message: message)
            }
            lastErrorMessage = currentError
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "登入"

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel, subtitleLabel, usernameField, passwordField, loginButton,
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.setCustomSpacing(4, after: titleLabel)
        stackView.setCustomSpacing(32, after: subtitleLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        loginButton.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),

            usernameField.heightAnchor.constraint(equalToConstant: 44),
            passwordField.heightAnchor.constraint(equalToConstant: 44),
            loginButton.heightAnchor.constraint(equalToConstant: 50),

            loadingIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: loginButton.trailingAnchor, constant: -16),
        ])
    }

    private func setupActions() {
        usernameField.addAction(UIAction { [weak self] _ in
            self?.store.send(.set(\.username, self?.usernameField.text ?? ""))
        }, for: .editingChanged)

        passwordField.addAction(UIAction { [weak self] _ in
            self?.store.send(.set(\.password, self?.passwordField.text ?? ""))
        }, for: .editingChanged)

        loginButton.addAction(UIAction { [weak self] _ in
            self?.store.send(.loginButtonTapped)
        }, for: .touchUpInside)

        // 點擊空白處收起鍵盤
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
