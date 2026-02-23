//
//  Monster5Coordinator.swift
//  CarSystem
//
//  Monster5 - TCA + UIKit 整合實戰
//

import UIKit
import ComposableArchitecture

/// Monster5 App 導航協調器
/// 負責 TCA State 與 UINavigationController 之間的同步
final class Monster5Coordinator {
    let store: StoreOf<Monster5AppFeature>
    let navigationController: UINavigationController

    private var postsVC: PostsViewController?

    init(store: StoreOf<Monster5AppFeature>) {
        self.store = store

        // 建立 LoginVC 作為根視圖
        let loginVC = LoginViewController(
            store: store.scope(state: \.login, action: \.login)
        )
        self.navigationController = UINavigationController(rootViewController: loginVC)
        self.navigationController.navigationBar.prefersLargeTitles = true

        // 登入成功回調 → 導航到文章列表
        loginVC.onLoginSuccess = { [weak self] _ in
            self?.navigateToPosts()
        }
    }

    private func navigateToPosts() {
        // 確保 AppFeature 已建立 PostsFeature State
        guard store.posts != nil else { return }

        let postsStore = store.scope(state: \.posts!, action: \.posts)
        let vc = PostsViewController(store: postsStore)
        postsVC = vc
        vc.navigationItem.hidesBackButton = true
        navigationController.pushViewController(vc, animated: true)
    }
}
