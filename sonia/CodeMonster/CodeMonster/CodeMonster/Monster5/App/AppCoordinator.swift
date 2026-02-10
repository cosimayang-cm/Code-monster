//
//  AppCoordinator.swift
//  CodeMonster - Monster 5: TCA + UIKit Integration
//
//  Created by Claude on 2026-02-10.
//

import UIKit
import ComposableArchitecture

/// Root navigation coordinator managing screen flow
final class AppCoordinator: UINavigationController {

    // MARK: - Properties

    let store: StoreOf<AppFeature>

    // MARK: - Initialization

    init(store: StoreOf<AppFeature>) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self

        // Set initial login screen
        let loginVC = LoginViewController(
            store: store.scope(state: \.login, action: \.login)
        )
        setViewControllers([loginVC], animated: false)

        // Observe navigation state changes
        observeNavigation()
    }

    // MARK: - Navigation Observation

    private func observeNavigation() {
        observe { [weak self] in
            guard let self else { return }

            // Push posts list when logged in
            if store.isLoggedIn && viewControllers.count == 1 {
                let postsListVC = PostsListViewController(
                    store: store.scope(state: \.postsList, action: \.postsList)
                )
                pushViewController(postsListVC, animated: true)
            }

            // Push/pop post detail based on optional state
            if store.postDetail != nil {
                if !(topViewController is PostDetailViewController) {
                    if let detailStore = store.scope(state: \.postDetail, action: \.postDetail) {
                        let detailVC = PostDetailViewController(store: detailStore)
                        pushViewController(detailVC, animated: true)
                    }
                }
            } else {
                if topViewController is PostDetailViewController {
                    popViewController(animated: true)
                }
            }
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension AppCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        // When user navigates back from detail (back button or swipe),
        // sync the final interaction state and clear postDetail
        if store.postDetail != nil && !(topViewController is PostDetailViewController) {
            store.send(.dismissPostDetail)
        }
    }
}
