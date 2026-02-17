//
//  PostDetailViewController.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import UIKit
import ComposableArchitecture

final class PostDetailViewController: UIViewController {
    /// PostsFeature store（透過 IdentifiedAction 操作子 state）
    private let store: StoreOf<PostsFeature>
    private let postId: Int

    // MARK: - UI Elements

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .regular)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()

    // Interaction bar
    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return button
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        return button
    }()

    // Comment section
    private let commentSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "💬 留言"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        return label
    }()

    private let commentTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "寫下留言..."
        field.borderStyle = .roundedRect
        field.returnKeyType = .send
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let addCommentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("送出", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let commentsStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    // MARK: - Init

    init(store: StoreOf<PostsFeature>, postId: Int) {
        self.store = store
        self.postId = postId
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()

        observe { [weak self] in
            guard let self,
                  let state = store.posts[id: postId] else { return }

            // 文章內容
            titleLabel.text = state.post.title
            bodyLabel.text = state.post.body

            // 按讚
            let interaction = state.interaction
            if interaction.isLiked {
                likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                likeButton.tintColor = .systemRed
            } else {
                likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                likeButton.tintColor = .systemBlue
            }
            likeButton.setTitle(" \(interaction.likeCount)", for: .normal)

            // 分享
            shareButton.setTitle(" \(interaction.shareCount)", for: .normal)

            // 留言列表
            commentsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            commentSectionLabel.text = "💬 留言 (\(interaction.comments.count))"

            for comment in interaction.comments {
                let commentView = createCommentView(comment)
                commentsStack.addArrangedSubview(commentView)
            }

            if interaction.comments.isEmpty {
                let emptyLabel = UILabel()
                emptyLabel.text = "尚無留言"
                emptyLabel.textColor = .tertiaryLabel
                emptyLabel.font = .systemFont(ofSize: 14)
                commentsStack.addArrangedSubview(emptyLabel)
            }
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "文章詳情"

        // Interaction bar
        let interactionBar = UIStackView(arrangedSubviews: [likeButton, shareButton, UIView()])
        interactionBar.axis = .horizontal
        interactionBar.spacing = 24

        // Separator
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true

        // Comment input row
        let commentInputStack = UIStackView(arrangedSubviews: [commentTextField, addCommentButton])
        commentInputStack.axis = .horizontal
        commentInputStack.spacing = 8

        // Add all to content stack
        contentStack.addArrangedSubview(titleLabel)
        contentStack.addArrangedSubview(bodyLabel)
        contentStack.addArrangedSubview(interactionBar)
        contentStack.addArrangedSubview(separator)
        contentStack.addArrangedSubview(commentSectionLabel)
        contentStack.addArrangedSubview(commentInputStack)
        contentStack.addArrangedSubview(commentsStack)

        contentStack.setCustomSpacing(8, after: titleLabel)
        contentStack.setCustomSpacing(20, after: bodyLabel)
        contentStack.setCustomSpacing(16, after: interactionBar)

        // Layout
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),

            commentTextField.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    private func setupActions() {
        likeButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            // 按讚動畫
            UIView.animate(withDuration: 0.1, animations: {
                self.likeButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            }) { _ in
                UIView.animate(withDuration: 0.1) {
                    self.likeButton.transform = .identity
                }
            }
            store.send(.post(.element(id: postId, action: .toggleLike)))
        }, for: .touchUpInside)

        shareButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            store.send(.post(.element(id: postId, action: .shareTapped)))
        }, for: .touchUpInside)

        addCommentButton.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            store.send(.post(.element(id: postId, action: .addComment)))
            commentTextField.text = ""
            view.endEditing(true)
        }, for: .touchUpInside)

        commentTextField.addAction(UIAction { [weak self] _ in
            guard let self else { return }
            store.send(.post(.element(id: postId, action: .commentTextChanged(commentTextField.text ?? ""))))
        }, for: .editingChanged)

        // 點擊空白處收起鍵盤
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Helpers

    private func createCommentView(_ comment: PostComment) -> UIView {
        let container = UIView()

        let contentLabel = UILabel()
        contentLabel.text = comment.content
        contentLabel.font = .systemFont(ofSize: 14)
        contentLabel.numberOfLines = 0
        contentLabel.translatesAutoresizingMaskIntoConstraints = false

        let dateLabel = UILabel()
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: comment.createdAt)
        dateLabel.font = .systemFont(ofSize: 11)
        dateLabel.textColor = .tertiaryLabel
        dateLabel.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(contentLabel)
        container.addSubview(dateLabel)

        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 8
        container.clipsToBounds = true

        NSLayoutConstraint.activate([
            contentLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            contentLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            contentLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),

            dateLabel.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
            dateLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -8),
        ])

        return container
    }
}
