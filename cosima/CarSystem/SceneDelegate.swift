//
//  SceneDelegate.swift
//  CarSystem
//
//  Created by Claude on 2026/1/11.
//
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // 建立 Tab Bar Controller
        let tabBarController = createTabBarController()

        // 設定 Window
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }

    // MARK: - Tab Bar Setup

    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()

        // Tab 1: 車輛系統（從 Storyboard 載入）
        let carVC = createCarViewController()
        carVC.tabBarItem = UITabBarItem(
            title: "車輛系統",
            image: UIImage(systemName: "car"),
            selectedImage: UIImage(systemName: "car.fill")
        )

        // Tab 2: 畫布編輯器（Undo/Redo 示範）
        let canvasVC = CanvasEditorViewController()
        let canvasNav = UINavigationController(rootViewController: canvasVC)
        canvasNav.tabBarItem = UITabBarItem(
            title: "畫布",
            image: UIImage(systemName: "scribble"),
            selectedImage: UIImage(systemName: "scribble")
        )

        // Tab 3: 文字編輯器（Undo/Redo 示範）
        let textVC = TextEditorViewController()
        let textNav = UINavigationController(rootViewController: textVC)
        textNav.tabBarItem = UITabBarItem(
            title: "文字",
            image: UIImage(systemName: "doc.text"),
            selectedImage: UIImage(systemName: "doc.text.fill")
        )

        tabBarController.viewControllers = [carVC, canvasNav, textNav]

        return tabBarController
    }

    private func createCarViewController() -> UIViewController {
        // 從 Storyboard 載入原本的 CarViewController
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let carVC = storyboard.instantiateInitialViewController() {
            return carVC
        }
        // Fallback: 如果 Storyboard 載入失敗，建立空的 ViewController
        let fallbackVC = UIViewController()
        fallbackVC.view.backgroundColor = .systemBackground
        fallbackVC.title = "車輛系統"
        return fallbackVC
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
