//
//  PostTableViewCell.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import UIKit

final class PostTableViewCell: UITableViewCell {
    static let reuseIdentifier = "PostTableViewCell"

    // MARK: - Closures

    var onLikeTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let commentIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "bubble.right"))
        imageView.tintColor = .systemGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let commentCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let shareCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        onLikeTapped = nil
        onShareTapped = nil
    }

    // MARK: - Setup

    private func setupUI() {
        selectionStyle = .none

        // Content stack
        let contentStack = UIStackView(arrangedSubviews: [titleLabel, bodyLabel])
        contentStack.axis = .vertical
        contentStack.spacing = 4
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        // Interaction bar
        let likeStack = UIStackView(arrangedSubviews: [likeButton, likeCountLabel])
        likeStack.axis = .horizontal
        likeStack.spacing = 4
        likeStack.alignment = .center

        let commentStack = UIStackView(arrangedSubviews: [commentIcon, commentCountLabel])
        commentStack.axis = .horizontal
        commentStack.spacing = 4
        commentStack.alignment = .center

        let shareStack = UIStackView(arrangedSubviews: [shareButton, shareCountLabel])
        shareStack.axis = .horizontal
        shareStack.spacing = 4
        shareStack.alignment = .center

        let interactionBar = UIStackView(arrangedSubviews: [likeStack, commentStack, shareStack, UIView()])
        interactionBar.axis = .horizontal
        interactionBar.spacing = 20
        interactionBar.translatesAutoresizingMaskIntoConstraints = false

        // Separator
        let separator = UIView()
        separator.backgroundColor = .separator
        separator.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(contentStack)
        contentView.addSubview(interactionBar)
        contentView.addSubview(separator)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            interactionBar.topAnchor.constraint(equalTo: contentStack.bottomAnchor, constant: 8),
            interactionBar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            interactionBar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            interactionBar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            likeButton.widthAnchor.constraint(equalToConstant: 24),
            likeButton.heightAnchor.constraint(equalToConstant: 24),
            commentIcon.widthAnchor.constraint(equalToConstant: 20),
            commentIcon.heightAnchor.constraint(equalToConstant: 20),
            shareButton.widthAnchor.constraint(equalToConstant: 24),
            shareButton.heightAnchor.constraint(equalToConstant: 24),

            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
        ])

        // Actions
        likeButton.addAction(UIAction { [weak self] _ in
            self?.onLikeTapped?()
        }, for: .touchUpInside)

        shareButton.addAction(UIAction { [weak self] _ in
            self?.onShareTapped?()
        }, for: .touchUpInside)
    }

    // MARK: - Configure

    func configure(with state: PostDetailFeature.State) {
        titleLabel.text = state.post.title
        bodyLabel.text = state.post.body

        let interaction = state.interaction
        likeCountLabel.text = "\(interaction.likeCount)"
        commentCountLabel.text = "\(interaction.comments.count)"
        shareCountLabel.text = "\(interaction.shareCount)"

        if interaction.isLiked {
            likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            likeButton.tintColor = .systemRed
        } else {
            likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            likeButton.tintColor = .systemGray
        }
    }
}
