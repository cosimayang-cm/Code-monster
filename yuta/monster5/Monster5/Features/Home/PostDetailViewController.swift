import UIKit
import ComposableArchitecture

final class PostDetailViewController: UIViewController {

    private let store: StoreOf<PostDetailFeature>

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(CommentCell.self, forCellReuseIdentifier: CommentCell.reuseIdentifier)
        tv.dataSource = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 60
        tv.keyboardDismissMode = .interactive
        return tv
    }()

    private lazy var inputBar: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.backgroundColor = .systemBackground
        let separator = UIView()
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.backgroundColor = .separator
        v.addSubview(separator)
        NSLayoutConstraint.activate([
            separator.topAnchor.constraint(equalTo: v.topAnchor),
            separator.leadingAnchor.constraint(equalTo: v.leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: v.trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
        ])
        return v
    }()

    private lazy var commentField: UITextField = {
        let tf = UITextField()
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.placeholder = "Add a comment..."
        tf.borderStyle = .roundedRect
        tf.returnKeyType = .send
        tf.delegate = self
        tf.addTarget(self, action: #selector(commentTextChanged), for: .editingChanged)
        return tf
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        button.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        return button
    }()

    private var inputBarBottomConstraint: NSLayoutConstraint?

    init(store: StoreOf<PostDetailFeature>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Post Detail"
        setupUI()
        setupKeyboardObservers()
        setupNavigationBarButtons()

        observe { [weak self] in
            guard let self else { return }
            commentField.text = store.commentText
            tableView.reloadData()
        }

        if store.shouldFocusComment {
            commentField.becomeFirstResponder()
        }
    }

    private func setupNavigationBarButtons() {
        let likeButton = UIBarButtonItem(
            image: UIImage(systemName: store.interaction.isLiked ? "heart.fill" : "heart"),
            style: .plain,
            target: self,
            action: #selector(likeTapped)
        )
        let shareButton = UIBarButtonItem(
            image: UIImage(systemName: "square.and.arrow.up"),
            style: .plain,
            target: self,
            action: #selector(shareTapped)
        )
        navigationItem.rightBarButtonItems = [shareButton, likeButton]
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(inputBar)
        inputBar.addSubview(commentField)
        inputBar.addSubview(sendButton)

        let bottomConstraint = inputBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        inputBarBottomConstraint = bottomConstraint

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputBar.topAnchor),

            inputBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint,
            inputBar.heightAnchor.constraint(equalToConstant: 52),

            commentField.leadingAnchor.constraint(equalTo: inputBar.leadingAnchor, constant: 12),
            commentField.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            commentField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            commentField.heightAnchor.constraint(equalToConstant: 36),

            sendButton.trailingAnchor.constraint(equalTo: inputBar.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputBar.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 36),
        ])
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        let offset = frame.height - view.safeAreaInsets.bottom
        inputBarBottomConstraint?.constant = -offset
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }
        inputBarBottomConstraint?.constant = 0
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func commentTextChanged() {
        store.send(.commentTextChanged(commentField.text ?? ""))
    }

    @objc private func sendTapped() {
        store.send(.submitComment)
    }

    @objc private func likeTapped() {
        store.send(.toggleLike)
        let imageName = store.interaction.isLiked ? "heart.fill" : "heart"
        navigationItem.rightBarButtonItems?[1].image = UIImage(systemName: imageName)
    }

    @objc private func shareTapped() {
        store.send(.shareTapped)
        let items: [Any] = [store.post.title, store.post.body]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityVC, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension PostDetailViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : store.interaction.comments.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 1 && !store.interaction.comments.isEmpty ? "Comments" : nil
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
            cell.selectionStyle = .none
            cell.textLabel?.text = store.post.title
            cell.textLabel?.font = .systemFont(ofSize: 18, weight: .bold)
            cell.textLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = store.post.body
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.textColor = .secondaryLabel

            let interaction = store.interaction
            let countsText = "❤️ \(interaction.likeCount)  💬 \(interaction.commentCount)  🔗 \(interaction.shareCount)"
            cell.detailTextLabel?.text = "\(store.post.body)\n\n\(countsText)"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: CommentCell.reuseIdentifier,
                for: indexPath
            ) as! CommentCell
            cell.configure(with: store.interaction.comments[indexPath.row])
            return cell
        }
    }
}

// MARK: - UITextFieldDelegate
extension PostDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        store.send(.submitComment)
        return true
    }
}
