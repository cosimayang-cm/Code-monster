import Foundation

/// 每日簽到彈窗處理器
struct DailyCheckInHandler: PopupHandling {
    
    func shouldHandle(_ context: UserContext) -> Bool {
        !context.hasCheckedInToday
    }
    
    func show(completion: @escaping () -> Void) {
        print("[彈窗] 每日簽到")
        UserDefaults.standard.set(Date(), forKey: "lastCheckInDate")
        completion()
    }
}
