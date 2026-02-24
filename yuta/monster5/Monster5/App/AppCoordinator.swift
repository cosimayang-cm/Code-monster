import UIKit
import Combine
import ComposableArchitecture

final class AppCoordinator: NSObject {

    private let store: StoreOf<AppFeature>
    private let window: UIWindow
    private var navigationController: UINavigationController?
    private var cancellables = Set<AnyCancellable>()
    private var previousPathIDs: [StackElementID] = []
    private var homeStore: StoreOf<HomeFeature>?

    init(store: StoreOf<AppFeature>, window: UIWindow) {
        self.store = store
        self.window = window
    }

    func start() {
        let loginStore = store.scope(state: \.login, action: \.login)
        let loginVC = LoginViewController(store: loginStore)
        window.rootViewController = loginVC
        window.makeKeyAndVisible()

        observeAuthentication()
    }

    private func observeAuthentication() {
        store.publisher
            .map(\.isAuthenticated)
            .removeDuplicates()
            .sink { [weak self] isAuthenticated in
                guard let self, isAuthenticated else { return }
                transitionToHome()
            }
            .store(in: &cancellables)
    }

    private func transitionToHome() {
        guard let homeStore = store.scope(state: \.home, action: \.home) else { return }
        self.homeStore = homeStore

        let homeVC = HomeViewController(store: homeStore)
        let nav = UINavigationController(rootViewController: homeVC)
        nav.delegate = self
        navigationController = nav

        observePath(homeStore: homeStore)

        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: { self.window.rootViewController = nav }
        )
    }

    private func observePath(homeStore: StoreOf<HomeFeature>) {
        homeStore.publisher
            .map(\.path)
            .sink { [weak self] path in
                guard let self else { return }
                let newIDs = Array(path.ids)
                let oldIDs = previousPathIDs
                previousPathIDs = newIDs

                if newIDs.count > oldIDs.count {
                    // Push new screens
                    for id in newIDs.dropFirst(oldIDs.count) {
                        guard let scopedStore = homeStore.scope(
                            state: \.path[id: id],
                            action: \.path[id: id]
                        ) else { continue }

                        switch scopedStore.case {
                        case .postDetail(let detailStore):
                            let detailVC = PostDetailViewController(store: detailStore)
                            navigationController?.pushViewController(detailVC, animated: true)
                        }
                    }
                }
                // Pop handled by UINavigationControllerDelegate
            }
            .store(in: &cancellables)
    }
}

// MARK: - UINavigationControllerDelegate
extension AppCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let homeStore else { return }
        let visiblePathCount = navigationController.viewControllers.count - 1
        let currentIDs = previousPathIDs

        if visiblePathCount < currentIDs.count {
            for id in currentIDs.suffix(from: visiblePathCount).reversed() {
                homeStore.send(.path(.popFrom(id: id)))
            }
            previousPathIDs = Array(currentIDs.prefix(visiblePathCount))
        }
    }
}
