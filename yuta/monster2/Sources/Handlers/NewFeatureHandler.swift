import Foundation

/// 新功能公告彈窗處理器
struct NewFeatureHandler: PopupHandling {
    
    func shouldHandle(_ context: UserContext) -> Bool {
        !context.hasSeenNewFeature
    }
    
    func show(completion: @escaping () -> Void) {
        print("[彈窗] 新功能公告")
        UserDefaults.standard.set(true, forKey: "hasSeenNewFeature")
        completion()
    }
}
