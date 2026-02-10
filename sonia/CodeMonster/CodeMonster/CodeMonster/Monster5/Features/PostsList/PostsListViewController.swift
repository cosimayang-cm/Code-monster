//
//  PostsListViewController.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import UIKit
import ComposableArchitecture

/// Posts list view controller displaying feed with interactions
final class PostsListViewController: UIViewController {

    // MARK: - Properties

    let store: StoreOf<PostsListFeature>

    // MARK: - UI Components

    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.delegate = self
        table.dataSource = self
        table.register(PostCell.self, forCellReuseIdentifier: "PostCell")
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let errorContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Retry", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No posts available"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    // MARK: - Initialization

    init(store: StoreOf<PostsListFeature>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Posts"
        view.backgroundColor = .systemBackground
        setupViews()
        setupObservation()
        store.send(.onAppear)
    }

    // MARK: - Setup

    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorContainerView)
        view.addSubview(emptyLabel)

        errorContainerView.addSubview(errorLabel)
        errorContainerView.addSubview(retryButton)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            errorContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            errorLabel.centerXAnchor.constraint(equalTo: errorContainerView.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: errorContainerView.centerYAnchor, constant: -30),
            errorLabel.leadingAnchor.constraint(equalTo: errorContainerView.leadingAnchor, constant: 20),
            errorLabel.trailingAnchor.constraint(equalTo: errorContainerView.trailingAnchor, constant: -20),

            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 20),
            retryButton.centerXAnchor.constraint(equalTo: errorContainerView.centerXAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
    }

    private func setupObservation() {
        observe { [weak self] in
            guard let self else { return }

            let isLoading = store.isLoading
            let errorMessage = store.errorMessage
            let posts = store.posts

            if isLoading {
                loadingIndicator.startAnimating()
                tableView.isHidden = true
                errorContainerView.isHidden = true
                emptyLabel.isHidden = true
            } else if let error = errorMessage {
                loadingIndicator.stopAnimating()
                tableView.isHidden = true
                errorContainerView.isHidden = false
                emptyLabel.isHidden = true
                errorLabel.text = error
            } else if posts.isEmpty {
                loadingIndicator.stopAnimating()
                tableView.isHidden = true
                errorContainerView.isHidden = true
                emptyLabel.isHidden = false
            } else {
                loadingIndicator.stopAnimating()
                tableView.isHidden = false
                errorContainerView.isHidden = true
                emptyLabel.isHidden = true
                tableView.reloadData()
            }
        }
    }

    // MARK: - Actions

    @objc private func retryTapped() {
        store.send(.retryTapped)
    }
}

// MARK: - UITableViewDataSource

extension PostsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell else {
            return UITableViewCell()
        }

        let post = store.posts[indexPath.row]
        cell.configure(with: post)
        cell.onLikeTapped = { [weak self] in
            self?.store.send(.likeTapped(postId: post.id))
        }
        cell.onShareTapped = { [weak self] in
            self?.store.send(.shareTapped(postId: post.id))
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PostsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = store.posts[indexPath.row]
        store.send(.postTapped(post))
    }
}
