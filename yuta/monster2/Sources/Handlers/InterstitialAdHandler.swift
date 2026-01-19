import Foundation

/// 插頁式廣告彈窗處理器
struct InterstitialAdHandler: PopupHandling {
    
    func shouldHandle(_ context: UserContext) -> Bool {
        !context.hasSeenInterstitialAd
    }
    
    func show(completion: @escaping () -> Void) {
        print("[彈窗] 插頁式廣告")
        UserDefaults.standard.set(true, forKey: "hasSeenInterstitialAd")
        completion()
    }
}
