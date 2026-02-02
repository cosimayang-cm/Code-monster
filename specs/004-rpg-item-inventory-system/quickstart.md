# Quick Start: RPG 道具/物品欄/背包系統

**Feature**: 004-rpg-item-inventory-system
**Date**: 2026-02-01

---

## Overview

本文件提供快速入門指南，展示如何使用 RPG 道具系統的核心功能。

---

## 1. 建立物品模板

物品模板定義物品的「種類」，可重複使用來建立多個物品實例。

```swift
// 建立一個鐵製頭盔模板
let ironHelmetTemplate = ItemTemplate(
    templateId: "helmet_iron_001",
    name: "鐵製頭盔",
    description: "普通的鐵製頭盔，提供基本防護",
    slot: .helmet,
    rarity: .uncommon,  // 優良品質，1 條副詞條
    levelRequirement: 5,
    baseStats: Stats(defense: 15, maxHP: 50),
    attributes: [],
    setId: nil,
    iconAsset: "icon_helmet_iron",
    modelAsset: nil
)
```

---

## 2. 建立物品實例

使用 ItemFactory 從模板建立實例，系統會自動生成詞條。

```swift
// 初始化詞條生成器與物品工廠
let affixGenerator = AffixGeneratorImpl()
let itemFactory = ItemFactory(affixGenerator: affixGenerator)

// 載入頭盔欄位的詞條池
let helmetAffixPool = AffixPoolLoader.load(for: .helmet)

// 建立物品實例
let myHelmet = itemFactory.createItem(
    from: ironHelmetTemplate,
    using: helmetAffixPool
)

print("物品 ID: \(myHelmet.instanceId)")
print("主詞條: \(myHelmet.mainAffix.type) +\(myHelmet.mainAffix.value)")
print("副詞條數量: \(myHelmet.subAffixes.count)")  // 1（uncommon）
```

---

## 3. 建立角色並裝備物品

```swift
// 建立角色
let avatar = Avatar(
    name: "勇者",
    level: 10,
    baseStats: Stats(attack: 100, defense: 50, maxHP: 1000)
)

// 將物品加入背包
avatar.inventory.add(myHelmet)

// 初始化物品服務
let itemService = ItemServiceImpl()

// 穿戴物品
let result = itemService.equip(myHelmet, on: avatar)

switch result {
case .success(let replacedItem):
    print("裝備成功！")
    if let old = replacedItem {
        print("舊裝備 \(old.name) 已移至背包")
    }
case .failure(let error):
    print("裝備失敗: \(error)")
}
```

---

## 4. 計算角色總數值

```swift
let statsCalculator = StatsCalculatorImpl()

// 計算最終數值
let totalStats = statsCalculator.calculateTotalStats(for: avatar)

print("最終攻擊力: \(totalStats.attack)")
print("最終防禦力: \(totalStats.defense)")
print("最終生命值: \(totalStats.maxHP)")
```

---

## 5. 使用 Bitmask 篩選物品

快速篩選背包中擁有特定詞條的物品。

```swift
// 篩選同時擁有暴擊和攻擊詞條的物品
let critAndAttackItems = avatar.inventory.filter(
    byAffixMask: [.crit, .attack],
    matchAll: true  // 必須同時擁有
)

// 篩選擁有暴擊或防禦詞條的物品
let critOrDefenseItems = avatar.inventory.filter(
    byAffixMask: [.crit, .defense],
    matchAll: false  // 擁有任一即可
)

// 直接檢查物品的詞條
if myHelmet.affixMask.contains(.hp) {
    print("這件裝備有生命詞條")
}
```

---

## 6. 套裝效果

穿戴同套裝的多件裝備時，自動觸發套裝效果。

```swift
// 假設穿戴了 2 件「昔日宗室之儀」套裝
let setBonuses = statsCalculator.calculateSetBonuses(
    from: avatar.equipment.allEquipped
)

for activeSet in setBonuses {
    print("套裝: \(activeSet.set.name)")
    print("已穿戴件數: \(activeSet.activePieces)")
    for bonus in activeSet.bonuses {
        print("  效果: \(bonus.description)")
    }
}

// 輸出範例：
// 套裝: 昔日宗室之儀
// 已穿戴件數: 2
//   效果: 元素爆發造成的傷害提升20%
```

---

## 7. 物品序列化與反序列化

儲存與載入物品資料。

```swift
let serializer = ItemSerializerImpl()

// 序列化為 JSON
let jsonData = try serializer.encode(myHelmet)
let jsonString = String(data: jsonData, encoding: .utf8)!
print(jsonString)

// 從 JSON 還原
let loadedItem = try serializer.decode(jsonData)
print("還原的物品 ID: \(loadedItem.instanceId)")
```

---

## 8. 完整範例

```swift
import Foundation

// ===== 初始化系統 =====
let affixGenerator = AffixGeneratorImpl()
let itemFactory = ItemFactory(affixGenerator: affixGenerator)
let itemService = ItemServiceImpl()
let statsCalculator = StatsCalculatorImpl()

// ===== 載入資料 =====
let templates = ItemTemplateLoader.loadAll(from: "templates.json")
let affixPools = AffixPoolLoader.loadAll(from: "affix_pools.json")

// ===== 建立角色 =====
let player = Avatar(
    name: "英雄",
    level: 20,
    baseStats: Stats(
        attack: 150,
        defense: 80,
        maxHP: 2000,
        maxMP: 500,
        critRate: 0.05,
        critDamage: 0.5,
        speed: 100
    )
)

// ===== 建立並裝備物品 =====
let helmetTemplate = templates.first { $0.templateId == "helmet_royal_001" }!
let helmetPool = affixPools.first { $0.slot == .helmet }!

// 建立傳說頭盔
let legendaryHelmet = itemFactory.createItem(from: helmetTemplate, using: helmetPool)
player.inventory.add(legendaryHelmet)

// 穿戴
itemService.equip(legendaryHelmet, on: player)

// ===== 顯示結果 =====
print("===== 角色狀態 =====")
print("名稱: \(player.name)")
print("等級: \(player.level)")

print("\n===== 裝備資訊 =====")
if let helmet = player.equipment.getItem(at: .helmet) {
    print("頭盔: \(helmet.name) (Lv.\(helmet.level))")
    print("  主詞條: \(helmet.mainAffix.type) +\(helmet.mainAffix.value)")
    print("  副詞條:")
    for affix in helmet.subAffixes {
        let suffix = affix.isPercentage ? "%" : ""
        print("    - \(affix.type): +\(affix.value)\(suffix)")
    }
}

print("\n===== 最終數值 =====")
let finalStats = statsCalculator.calculateTotalStats(for: player)
print("攻擊力: \(finalStats.attack)")
print("防禦力: \(finalStats.defense)")
print("生命值: \(finalStats.maxHP)")
print("暴擊率: \(finalStats.critRate * 100)%")
print("暴擊傷害: \(finalStats.critDamage * 100)%")

print("\n===== 套裝效果 =====")
let activeSets = statsCalculator.calculateSetBonuses(from: player.equipment.allEquipped)
if activeSets.isEmpty {
    print("無啟動的套裝效果")
} else {
    for activeSet in activeSets {
        print("\(activeSet.set.name) (\(activeSet.activePieces)件)")
        for bonus in activeSet.bonuses {
            print("  - \(bonus.description)")
        }
    }
}
```

---

## 常見問題

### Q: 如何確保物品 ID 唯一？
A: 系統使用 UUID v4 自動生成，衝突機率約為 2^-122，實務上不需擔心。

### Q: 為什麼我的副詞條數量不對？
A: 副詞條數量由稀有度決定：
- common: 0
- uncommon: 1
- rare: 2
- epic: 3
- legendary: 4

### Q: 百分比加成是怎麼計算的？
A: 先加總所有固定值，再乘以 (1 + 百分比總和)。
例如：基礎 100 + 固定 50 = 150，再乘 1.1（10% 加成）= 165

### Q: 如何測試詞條權重分布？
A: 生成大量樣本（建議 10000 次），統計各詞條出現次數，與權重比例比對，允許 5% 誤差。
