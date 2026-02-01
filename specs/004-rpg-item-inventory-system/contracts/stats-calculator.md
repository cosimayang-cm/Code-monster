# Contract: StatsCalculator

**Module**: Services
**Version**: 1.0
**Date**: 2026-02-01

---

## Overview

StatsCalculator 負責計算角色的最終數值，包含基礎數值、裝備加成、詞條加成、套裝效果。

---

## Protocol Definition

```swift
protocol StatsCalculating {
    /// 計算角色最終數值
    /// - Parameter avatar: 目標角色
    /// - Returns: 計算後的總數值
    func calculateTotalStats(for avatar: Avatar) -> Stats

    /// 計算單件裝備的數值貢獻
    /// - Parameter item: 目標裝備
    /// - Returns: 該裝備的數值加成
    func calculateItemStats(_ item: Item) -> ItemStatsBreakdown

    /// 計算套裝效果
    /// - Parameter items: 已穿戴的裝備列表
    /// - Returns: 啟動的套裝效果列表
    func calculateSetBonuses(from items: [Item]) -> [ActiveSetBonus]
}
```

---

## Data Types

### ItemStatsBreakdown

```swift
struct ItemStatsBreakdown {
    let baseStats: Stats        // 裝備基礎數值
    let mainAffixStats: Stats   // 主詞條加成
    let subAffixStats: Stats    // 副詞條加成
    let totalFlat: Stats        // 固定值總計
    let totalPercent: Stats     // 百分比總計

    var total: Stats {
        // 先加固定值，再乘百分比
        // 注意：此處簡化處理，實際需按數值類型分別計算
        totalFlat  // 實際公式更複雜
    }
}
```

### ActiveSetBonus

```swift
struct ActiveSetBonus {
    let set: EquipmentSet
    let activePieces: Int
    let bonuses: [SetBonus]
}
```

---

## Calculation Formula

### 最終數值計算

```
最終數值 = (基礎值 + Σ固定加成) × (1 + Σ百分比加成)
```

**計算步驟**:
1. 收集角色基礎數值
2. 加總所有裝備的基礎數值（固定值）
3. 加總所有主詞條數值（區分固定/百分比）
4. 加總所有副詞條數值（區分固定/百分比）
5. 計算套裝效果加成
6. 合併所有固定值
7. 合併所有百分比
8. 套用公式

### 主詞條數值成長

```swift
func calculateMainAffixValue(base: Double, level: Int) -> Double {
    return base * (1.0 + 0.1 * Double(level - 1))
}

// 範例：
// 基礎值 = 5.0%，Level 1 → 5.0%
// 基礎值 = 5.0%，Level 5 → 5.0% × 1.4 = 7.0%
// 基礎值 = 5.0%，Level 10 → 5.0% × 1.9 = 9.5%
// 基礎值 = 5.0%，Level 20 → 5.0% × 2.9 = 14.5%
```

---

## Method Specifications

### calculateTotalStats(for:)

**Pseudo Code**:
```swift
func calculateTotalStats(for avatar: Avatar) -> Stats {
    // Step 1: 收集所有數值來源
    var flatBonuses = Stats()
    var percentBonuses = Stats()

    // Step 2: 加總裝備基礎數值
    for item in avatar.equipment.allEquipped {
        flatBonuses = flatBonuses + item.template.baseStats
    }

    // Step 3: 加總主詞條
    for item in avatar.equipment.allEquipped {
        let mainAffixValue = calculateMainAffixValue(
            base: item.mainAffix.value,
            level: item.level
        )
        applyAffix(type: item.mainAffix.type,
                   value: mainAffixValue,
                   isPercentage: item.mainAffix.isPercentage,
                   flatBonuses: &flatBonuses,
                   percentBonuses: &percentBonuses)
    }

    // Step 4: 加總副詞條
    for item in avatar.equipment.allEquipped {
        for affix in item.subAffixes {
            applyAffix(type: affix.type,
                       value: affix.value,
                       isPercentage: affix.isPercentage,
                       flatBonuses: &flatBonuses,
                       percentBonuses: &percentBonuses)
        }
    }

    // Step 5: 計算套裝效果
    let setBonuses = calculateSetBonuses(from: avatar.equipment.allEquipped)
    for activeSet in setBonuses {
        for bonus in activeSet.bonuses {
            applySetBonus(bonus, flatBonuses: &flatBonuses, percentBonuses: &percentBonuses)
        }
    }

    // Step 6: 計算最終數值
    let baseWithFlat = avatar.baseStats + flatBonuses
    return applyPercentBonuses(base: baseWithFlat, percent: percentBonuses)
}

private func applyPercentBonuses(base: Stats, percent: Stats) -> Stats {
    Stats(
        attack: base.attack * (1 + percent.attack / 100),
        defense: base.defense * (1 + percent.defense / 100),
        maxHP: base.maxHP * (1 + percent.maxHP / 100),
        maxMP: base.maxMP * (1 + percent.maxMP / 100),
        critRate: base.critRate + percent.critRate / 100,  // critRate 直接加
        critDamage: base.critDamage + percent.critDamage / 100,
        speed: base.speed * (1 + percent.speed / 100)
    )
}
```

---

### calculateSetBonuses(from:)

**Pseudo Code**:
```swift
func calculateSetBonuses(from items: [Item]) -> [ActiveSetBonus] {
    // Step 1: 計算各套裝已穿戴件數
    var setCounts: [String: Int] = [:]
    for item in items {
        if let setId = item.setId {
            setCounts[setId, default: 0] += 1
        }
    }

    // Step 2: 判定啟動的套裝效果
    var activeBonuses: [ActiveSetBonus] = []

    for (setId, count) in setCounts {
        guard let set = SetRegistry.get(setId) else { continue }

        let activeSetBonuses = set.bonuses.filter { $0.requiredPieces <= count }

        if !activeSetBonuses.isEmpty {
            activeBonuses.append(ActiveSetBonus(
                set: set,
                activePieces: count,
                bonuses: activeSetBonuses
            ))
        }
    }

    return activeBonuses
}
```

---

## Test Cases

| Test Case | Given | When | Then |
|-----------|-------|------|------|
| testCalculateStatsWhenNoEquipmentThenBaseOnly | 角色無裝備 | calculateTotalStats | 回傳基礎數值 |
| testCalculateStatsWhenFlatBonusThenAdded | 裝備 +30 攻擊 | calculateTotalStats | 攻擊 = base + 30 |
| testCalculateStatsWhenPercentBonusThenMultiplied | 裝備 +10% 攻擊 | calculateTotalStats | 攻擊 = base × 1.1 |
| testCalculateStatsWhenMixedBonusesThenCorrectOrder | 固定 +50、百分比 +10% | calculateTotalStats | (base+50) × 1.1 |
| testCalculateMainAffixWhenLevel10ThenGrowth | 主詞條 5%、Level 10 | calculateMainAffixValue | 9.5% |
| testSetBonusWhenTwoPiecesThenActivated | 穿戴 2 件同套裝 | calculateSetBonuses | 2 件套效果啟動 |
| testSetBonusWhenFourPiecesThenBothActivated | 穿戴 4 件同套裝 | calculateSetBonuses | 2 件套 + 4 件套都啟動 |
| testSetBonusWhenMixedSetsThenBothCalculated | 2 件 A 套 + 2 件 B 套 | calculateSetBonuses | A 的 2 件套 + B 的 2 件套 |
