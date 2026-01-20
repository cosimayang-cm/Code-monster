import Foundation

/// 彈窗鏈管理器
/// 負責執行外部組裝好的 Handler 鏈
final class PopupChainManager {
    
    // MARK: - Properties
    
    private let handlers: [any PopupHandling]
    
    // MARK: - Init
    
    /// 初始化管理器
    /// - Parameter handlers: 依優先順序排列的 Handler 陣列
    init(handlers: [any PopupHandling]) {
        self.handlers = handlers
    }
    
    // MARK: - Public Methods
    
    /// 開始執行彈窗鏈
    /// - Parameters:
    ///   - context: 使用者狀態
    ///   - completion: 全部執行完成後的回調
    func startChain(with context: UserContext, completion: @escaping () -> Void) {
        runNext(index: 0, context: context, completion: completion)
    }
    
    // MARK: - Private Methods
    
    private func runNext(index: Int, context: UserContext, completion: @escaping () -> Void) {
        guard index < handlers.count else {
            completion()
            return
        }
        
        let handler = handlers[index]
        
        if handler.shouldHandle(context) {
            handler.show { [weak self] in
                self?.runNext(index: index + 1, context: context, completion: completion)
            }
        } else {
            runNext(index: index + 1, context: context, completion: completion)
        }
    }
}
