import Foundation

/// 新手教學彈窗處理器
struct TutorialHandler: PopupHandling {
    
    func shouldHandle(_ context: UserContext) -> Bool {
        !context.hasSeenTutorial
    }
    
    func show(completion: @escaping () -> Void) {
        print("[彈窗] 新手教學")
        UserDefaults.standard.set(true, forKey: "hasSeenTutorial")
        completion()
    }
}
