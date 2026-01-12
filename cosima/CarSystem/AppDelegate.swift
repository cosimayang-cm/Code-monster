//
//  AppDelegate.swift
//  CarSystem
//
//  Created by Claude on 2026/1/11.
//
import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // 應用程式啟動時的初始化
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // 從 Storyboard 載入初始畫面
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let initialViewController = storyboard.instantiateInitialViewController() {
            window?.rootViewController = initialViewController
            window?.makeKeyAndVisible()
        }
        
        return true
    }
}
