//
//  AppDelegate.swift
//  CarSystem
//
//  Created by Claude on 2026/1/11.
//
import UIKit
import ComposableArchitecture

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var monster5Coordinator: Monster5Coordinator?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 建立 Window
        window = UIWindow(frame: UIScreen.main.bounds)

        // 建立 Tab Bar Controller
        let tabBarController = createTabBarController()

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        return true
    }

    // MARK: - Tab Bar Setup

    private func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()

        // 美化 Tab Bar 外觀
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground

        // 設定選中/未選中的顏色
        appearance.stackedLayoutAppearance.selected.iconColor = .systemBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.systemBlue]
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]

        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance

        // 添加上方分隔線
        tabBarController.tabBar.layer.borderWidth = 0.5
        tabBarController.tabBar.layer.borderColor = UIColor.systemGray4.cgColor

        // Tab 1: 車輛系統（從 Storyboard 載入）
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let carVC: UIViewController
        if let vc = storyboard.instantiateInitialViewController() {
            carVC = vc
        } else {
            carVC = UIViewController()
            carVC.view.backgroundColor = .systemBackground
        }
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

        // Tab 4: Monster5（TCA + UIKit 整合實戰）
        let monster5Nav = createMonster5Tab()

        tabBarController.viewControllers = [carVC, canvasNav, textNav, monster5Nav]

        return tabBarController
    }

    // MARK: - Monster5 Setup

    private func createMonster5Tab() -> UINavigationController {
        let store = Store(initialState: Monster5AppFeature.State()) {
            Monster5AppFeature()
        }
        let coordinator = Monster5Coordinator(store: store)
        self.monster5Coordinator = coordinator

        coordinator.navigationController.tabBarItem = UITabBarItem(
            title: "Monster5",
            image: UIImage(systemName: "newspaper"),
            selectedImage: UIImage(systemName: "newspaper.fill")
        )
        return coordinator.navigationController
    }
}
