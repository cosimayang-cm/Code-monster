//
//  PostsViewController.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import UIKit
import ComposableArchitecture

final class PostsViewController: UIViewController {
    let store: StoreOf<PostsFeature>

    // MARK: - UI Elements

    private let tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.reuseIdentifier)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 120
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "暫無文章"
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Init

    init(store: StoreOf<PostsFeature>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        store.send(.onAppear)

        observe { [weak self] in
            guard let self else { return }

            // Loading 狀態
            if store.isLoading {
                loadingIndicator.startAnimating()
                tableView.isHidden = true
                emptyLabel.isHidden = true
            } else {
                loadingIndicator.stopAnimating()
                tableView.isHidden = false
                emptyLabel.isHidden = !store.posts.isEmpty
            }

            // 重新整理列表
            tableView.reloadData()

            // Error toast
            if let message = store.errorMessage {
                ToastView.show(in: view, message: message)
            }
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "文章列表"

        tableView.dataSource = self
        tableView.delegate = self

        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

// MARK: - UITableViewDataSource

extension PostsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        store.posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PostTableViewCell.reuseIdentifier,
            for: indexPath
        ) as? PostTableViewCell else {
            return UITableViewCell()
        }

        let postState = store.posts[indexPath.row]
        cell.configure(with: postState)

        cell.onLikeTapped = { [weak self] in
            self?.store.send(.post(.element(id: postState.id, action: .toggleLike)))
        }
        cell.onShareTapped = { [weak self] in
            self?.store.send(.post(.element(id: postState.id, action: .shareTapped)))
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension PostsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postState = store.posts[indexPath.row]
        let detailVC = PostDetailViewController(store: store, postId: postState.id)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
