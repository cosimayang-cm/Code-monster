import UIKit

final class HomeTableViewCell: UITableViewCell {

    static let reuseIdentifier = "HomeTableViewCell"

    var onShareTapped: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 1
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        return label
    }()

    private let likeIcon: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemRed
        iv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 16),
            iv.heightAnchor.constraint(equalToConstant: 16),
        ])
        return iv
    }()

    private let likeCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()

    private let commentIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "bubble.right"))
        iv.contentMode = .scaleAspectFit
        iv.tintColor = .systemGray
        iv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 16),
            iv.heightAnchor.constraint(equalToConstant: 16),
        ])
        return iv
    }()

    private let commentCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()

    private let shareButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.tintColor = .systemGray
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 28),
            button.heightAnchor.constraint(equalToConstant: 28),
        ])
        return button
    }()

    private lazy var countsStack: UIStackView = {
        let likeStack = UIStackView(arrangedSubviews: [likeIcon, likeCountLabel])
        likeStack.spacing = 4
        likeStack.alignment = .center

        let commentStack = UIStackView(arrangedSubviews: [commentIcon, commentCountLabel])
        commentStack.spacing = 4
        commentStack.alignment = .center

        let sv = UIStackView(arrangedSubviews: [likeStack, commentStack, shareButton])
        sv.spacing = 16
        sv.alignment = .center
        return sv
    }()

    private lazy var contentStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, bodyLabel, countsStack])
        sv.axis = .vertical
        sv.spacing = 4
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(contentStack)
        accessoryType = .disclosureIndicator
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    func configure(with post: Post, interaction: PostInteraction) {
        titleLabel.text = post.title
        bodyLabel.text = post.body.replacingOccurrences(of: "\n", with: " ")

        likeIcon.image = UIImage(systemName: interaction.isLiked ? "heart.fill" : "heart")
        likeCountLabel.text = "\(interaction.likeCount)"
        commentCountLabel.text = "\(interaction.commentCount)"
    }

    @objc private func shareButtonTapped() {
        onShareTapped?()
    }
}
