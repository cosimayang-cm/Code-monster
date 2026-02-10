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

        // Set initial login screen
        let loginStore = store.scope(state: \.login, action: \.login)
        let loginVC = LoginViewController(store: loginStore)
        setViewControllers([loginVC], animated: false)

        // Observe navigation path changes
        observeNavigationPath()
    }

    // MARK: - Navigation Observation

    private func observeNavigationPath() {
        observe { [weak self] in
            guard let self else { return }

            let pathCount = store.path.count
            let vcCount = viewControllers.count

            // Sync navigation stack with TCA path
            if pathCount > vcCount - 1 {
                // Push new screens
                let newStates = Array(store.path.suffix(pathCount - (vcCount - 1)))
                for pathState in newStates {
                    let vc = makeViewController(for: pathState)
                    pushViewController(vc, animated: true)
                }
            } else if pathCount < vcCount - 1 {
                // Pop screens
                let targetVC = viewControllers[pathCount]
                popToViewController(targetVC, animated: true)
            }
        }
    }

    // MARK: - View Controller Factory

    private func makeViewController(for pathState: AppFeature.Path.State) -> UIViewController {
        switch pathState {
        case let .postsList(state):
            // Find the ID for this state in the path
            guard let id = store.path.ids.first(where: { id in
                if case .postsList = store.path[id: id] {
                    return true
                }
                return false
            }) else {
                fatalError("Could not find posts list state in path")
            }

            let postsListStore = store.scope(
                state: { _ in state },
                action: { .path(.element(id: id, action: .postsList($0))) }
            )
            return PostsListViewController(store: postsListStore)

        case let .postDetail(state):
            // Find the ID for this state in the path
            guard let id = store.path.ids.first(where: { id in
                if case .postDetail = store.path[id: id] {
                    return true
                }
                return false
            }) else {
                fatalError("Could not find post detail state in path")
            }

            let postDetailStore = store.scope(
                state: { _ in state },
                action: { .path(.element(id: id, action: .postDetail($0))) }
            )
            return PostDetailViewController(store: postDetailStore)
        }
    }
}
