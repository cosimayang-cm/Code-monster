# Contract: ItemFactory

**Module**: Services
**Version**: 1.0
**Date**: 2026-02-01

---

## Overview

ItemFactory 負責從 ItemTemplate 建立 Item 實例，整合 AffixGenerator 生成詞條。

---

## Protocol Definition

```swift
protocol ItemCreating {
    /// 從模板建立物品實例
    /// - Parameters:
    ///   - template: 物品模板
    ///   - affixPool: 該欄位的詞條池
    /// - Returns: 新建立的物品實例
    func createItem(from template: ItemTemplate, using affixPool: AffixPool) -> Item

    /// 批量建立物品
    /// - Parameters:
    ///   - template: 物品模板
    ///   - affixPool: 該欄位的詞條池
    ///   - count: 建立數量
    /// - Returns: 物品實例陣列
    func createItems(from template: ItemTemplate, using affixPool: AffixPool, count: Int) -> [Item]
}
```

---

## Dependencies

```swift
class ItemFactory: ItemCreating {
    private let affixGenerator: AffixGenerating

    init(affixGenerator: AffixGenerating) {
        self.affixGenerator = affixGenerator
    }
}
```

---

## Method Specifications

### createItem(from:using:)

**Preconditions**:
1. `template` 是有效的 ItemTemplate
2. `affixPool.slot == template.slot`

**Postconditions**:
1. 回傳新的 Item 實例
2. `item.instanceId` 是唯一的 UUID
3. `item.templateId == template.templateId`
4. `item.level == 1`
5. `item.mainAffix` 從 affixPool.mainAffixPool 隨機生成
6. `item.subAffixes.count == template.rarity.subAffixCount`
7. `item.affixMask` 正確反映所有詞條類型

**Pseudo Code**:
```swift
func createItem(from template: ItemTemplate, using affixPool: AffixPool) -> Item {
    // Step 1: 生成主詞條
    let mainAffix = affixGenerator.generateMainAffix(from: affixPool.mainAffixPool)

    // Step 2: 計算副詞條數量
    let subAffixCount = template.rarity.subAffixCount

    // Step 3: 生成副詞條（排除主詞條類型）
    let subAffixes = affixGenerator.generateSubAffixes(
        from: affixPool.subAffixPool,
        count: subAffixCount,
        excluding: mainAffix.type
    )

    // Step 4: 建立物品實例
    return Item(
        template: template,
        mainAffix: mainAffix,
        subAffixes: subAffixes
    )
}
```

---

### createItems(from:using:count:)

**Pseudo Code**:
```swift
func createItems(from template: ItemTemplate, using affixPool: AffixPool, count: Int) -> [Item] {
    return (0..<count).map { _ in
        createItem(from: template, using: affixPool)
    }
}
```

---

## Test Cases

| Test Case | Given | When | Then |
|-----------|-------|------|------|
| testCreateItemWhenCommonRarityThenZeroSubAffixes | common 稀有度模板 | createItem | subAffixes.count == 0 |
| testCreateItemWhenLegendaryRarityThenFourSubAffixes | legendary 稀有度模板 | createItem | subAffixes.count == 4 |
| testCreateItemWhenCalledTwiceThenDifferentUUIDs | 同一模板 | createItem × 2 | instanceId 不同 |
| testCreateItemWhenCreatedThenLevelIsOne | 任意模板 | createItem | level == 1 |
| testCreateItemWhenCreatedThenAffixMaskCorrect | 主詞條 .hp、副詞條 [.crit, .attack] | createItem | affixMask 包含三者 |
| testCreateItemsWhenCountFiveThenFiveItems | count = 5 | createItems | 回傳 5 個物品 |
| testCreateItemsWhenCountZeroThenEmptyArray | count = 0 | createItems | 回傳空陣列 |
