import Foundation

/// 物品創建協議
public protocol ItemCreating {
    /// 從模板創建物品實例
    /// - Parameters:
    ///   - template: 物品模板
    ///   - affixPool: 詞條池
    /// - Returns: 創建的物品實例
    func createItem(from template: ItemTemplate, affixPool: AffixPool) -> Item?
}
