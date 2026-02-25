import UIKit
import ComposableArchitecture

final class HomeViewController: UIViewController {

    let store: StoreOf<HomeFeature>

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(HomeTableViewCell.self, forCellReuseIdentifier: HomeTableViewCell.reuseIdentifier)
        tv.dataSource = self
        tv.delegate = self
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 80
        return tv
    }()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()

    init(store: StoreOf<HomeFeature>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Posts"
        setupUI()

        observe { [weak self] in
            guard let self else { return }
            if store.isLoading {
                activityIndicator.startAnimating()
            } else {
                activityIndicator.stopAnimating()
            }
            // Access tracked properties so observe re-fires on changes
            let _ = store.posts
            let _ = store.interactions
            tableView.reloadData()
        }

        store.send(.onAppear)
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        store.posts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: HomeTableViewCell.reuseIdentifier,
            for: indexPath
        ) as! HomeTableViewCell
        let post = store.posts[indexPath.row]
        let interaction = store.interactions[post.id] ?? PostInteraction()
        cell.configure(with: post, interaction: interaction)
        cell.onShareTapped = { [weak self] in
            let items: [Any] = [post.title, post.body]
            let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
            self?.present(activityVC, animated: true)
        }
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let post = store.posts[indexPath.row]
        store.send(.postTapped(post))
    }

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let post = store.posts[indexPath.row]
        let commentAction = UIContextualAction(style: .normal, title: "Comment") { [weak self] _, _, completion in
            self?.store.send(.commentTapped(post))
            completion(true)
        }
        commentAction.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [commentAction])
    }
}
