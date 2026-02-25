import UIKit
import ComposableArchitecture

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let store = Store(initialState: AppFeature.State()) {
            AppFeature()
        }

        let coordinator = AppCoordinator(store: store, window: window)
        self.coordinator = coordinator
        coordinator.start()
    }
}
