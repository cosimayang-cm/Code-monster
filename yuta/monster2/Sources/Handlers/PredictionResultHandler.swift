import Foundation

/// 猜多空結果彈窗處理器
struct PredictionResultHandler: PopupHandling {
    
    func shouldHandle(_ context: UserContext) -> Bool {
        context.hasPredictionResult
    }
    
    func show(completion: @escaping () -> Void) {
        print("[彈窗] 猜多空結果")
        completion()
    }
}
