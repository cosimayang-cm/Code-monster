import Foundation

/// 物品工廠（從模板建立物品實例）
public class ItemFactory: ItemCreating {
    private let affixGenerator: AffixGenerating

    public init(affixGenerator: AffixGenerating) {
        self.affixGenerator = affixGenerator
    }

    public func createItem(from template: ItemTemplate, affixPool: AffixPool) -> Item? {
        // 生成主詞條
        guard let mainAffix = affixGenerator.generateMainAffix(from: affixPool.mainAffixPool) else {
            return nil
        }

        // 根據稀有度生成副詞條
        let subAffixCount = template.rarity.subAffixCount
        let subAffixes = affixGenerator.generateSubAffixes(
            from: affixPool.subAffixPool,
            count: subAffixCount,
            excluding: mainAffix.type
        )

        // 創建物品實例
        return Item(template: template, mainAffix: mainAffix, subAffixes: subAffixes)
    }
}
