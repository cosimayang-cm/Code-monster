//
//  PostCell.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import UIKit

/// Custom table view cell for displaying post with interaction counts
final class PostCell: UITableViewCell {

    // MARK: - Callback

    var onLikeTapped: (() -> Void)?
    var onShareTapped: (() -> Void)?

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let bodyPreviewLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let commentCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .systemFont(ofSize: 12)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let interactionStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    // MARK: - Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupViews() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(bodyPreviewLabel)
        contentView.addSubview(interactionStackView)

        interactionStackView.addArrangedSubview(likeButton)
        interactionStackView.addArrangedSubview(commentCountLabel)
        interactionStackView.addArrangedSubview(shareButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            bodyPreviewLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            bodyPreviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bodyPreviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            interactionStackView.topAnchor.constraint(equalTo: bodyPreviewLabel.bottomAnchor, constant: 12),
            interactionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            interactionStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),
            interactionStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        likeButton.addTarget(self, action: #selector(likeTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func likeTapped() {
        onLikeTapped?()
    }

    @objc private func shareTapped() {
        onShareTapped?()
    }

    // MARK: - Configuration

    func configure(with postWithInteraction: PostWithInteraction) {
        titleLabel.text = postWithInteraction.post.title
        bodyPreviewLabel.text = postWithInteraction.post.body

        let interaction = postWithInteraction.interaction
        let icon = interaction.isLiked ? "❤️" : "🤍"
        likeButton.setTitle("\(icon) \(interaction.likeCount)", for: .normal)
        commentCountLabel.text = "💬 \(interaction.commentCount)"
        shareButton.setTitle("↗️ \(interaction.shareCount)", for: .normal)
    }
}
