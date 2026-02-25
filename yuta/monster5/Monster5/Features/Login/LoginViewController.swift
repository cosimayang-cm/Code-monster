import UIKit
import ComposableArchitecture

final class LoginViewController: UIViewController {

    private let store: StoreOf<LoginFeature>

    private lazy var stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Monster5"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()

    private lazy var usernameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username"
        tf.borderStyle = .roundedRect
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.addTarget(self, action: #selector(usernameChanged), for: .editingChanged)
        return tf
    }()

    private lazy var passwordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.borderStyle = .roundedRect
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(passwordChanged), for: .editingChanged)
        return tf
    }()

    private lazy var loginButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Login"
        config.cornerStyle = .medium
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        return button
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()

    init(store: StoreOf<LoginFeature>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        observe { [weak self] in
            guard let self else { return }
            usernameField.text = store.username
            passwordField.text = store.password
            loginButton.isEnabled = !store.isLoading
            if store.isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
            if let error = store.errorMessage {
                errorLabel.text = error
                errorLabel.isHidden = false
            } else {
                errorLabel.isHidden = true
            }
        }
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        view.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(usernameField)
        stackView.addArrangedSubview(passwordField)
        stackView.addArrangedSubview(loginButton)
        stackView.addArrangedSubview(activityIndicator)
        stackView.addArrangedSubview(errorLabel)

        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            loginButton.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    @objc private func usernameChanged() {
        store.send(.usernameChanged(usernameField.text ?? ""))
    }

    @objc private func passwordChanged() {
        store.send(.passwordChanged(passwordField.text ?? ""))
    }

    @objc private func loginTapped() {
        store.send(.loginButtonTapped)
    }
}
