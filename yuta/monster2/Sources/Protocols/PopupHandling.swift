import Foundation

/// 彈窗處理協定
/// 定義每個 Handler 必須實作的方法（編譯期強制）
protocol PopupHandling {
    /// 判斷是否應該顯示此彈窗
    func shouldHandle(_ context: UserContext) -> Bool
    
    /// 顯示彈窗，完成後呼叫 completion
    func show(completion: @escaping () -> Void)
}
