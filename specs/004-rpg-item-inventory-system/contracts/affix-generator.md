# Contract: AffixGenerator

**Module**: Services
**Version**: 1.0
**Date**: 2026-02-01

---

## Overview

AffixGenerator 負責根據詞條池的權重定義，隨機生成裝備的主詞條與副詞條。

---

## Protocol Definition

```swift
protocol AffixGenerating {
    /// 生成主詞條
    /// - Parameters:
    ///   - pool: 主詞條池
    /// - Returns: 生成的主詞條
    func generateMainAffix(from pool: [WeightedAffix]) -> Affix

    /// 生成副詞條
    /// - Parameters:
    ///   - pool: 副詞條池
    ///   - count: 要生成的數量
    ///   - excluding: 要排除的詞條類型（避免重複）
    /// - Returns: 生成的副詞條陣列
    func generateSubAffixes(from pool: [WeightedAffix], count: Int, excluding: AffixType) -> [Affix]

    /// 使用指定的隨機數產生器（用於測試）
    func setRandomGenerator(_ generator: RandomNumberGenerator)
}
```

---

## Data Types

### WeightedAffix

```swift
struct WeightedAffix: Codable {
    let type: AffixType       // 詞條類型
    let weight: Int           // 權重（0 表示不會出現）
    let minValue: Double      // 最小數值
    let maxValue: Double      // 最大數值
    let isPercentage: Bool    // 是否為百分比
}
```

### AffixPool

```swift
struct AffixPool: Codable {
    let slot: EquipmentSlot
    let mainAffixPool: [WeightedAffix]
    let subAffixPool: [WeightedAffix]

    // 過濾權重為 0 的詞條
    var validMainAffixes: [WeightedAffix] {
        mainAffixPool.filter { $0.weight > 0 }
    }

    var validSubAffixes: [WeightedAffix] {
        subAffixPool.filter { $0.weight > 0 }
    }
}
```

---

## Algorithm: Weighted Random Selection

```swift
func selectByWeight(from pool: [WeightedAffix]) -> WeightedAffix {
    let totalWeight = pool.reduce(0) { $0 + $1.weight }
    guard totalWeight > 0 else {
        fatalError("Pool has no valid entries")
    }

    var random = Int.random(in: 0..<totalWeight)

    for affix in pool {
        random -= affix.weight
        if random < 0 {
            return affix
        }
    }

    return pool.last!  // Fallback (should never reach)
}
```

### Probability Calculation

```
P(選中某詞條) = 該詞條權重 / Σ(所有詞條權重)
```

**Example**:
```
Pool: [HP:30, Attack:30, Defense:20, CritRate:10, CritDamage:10]
Total Weight = 100

P(HP) = 30/100 = 30%
P(Attack) = 30/100 = 30%
P(Defense) = 20/100 = 20%
P(CritRate) = 10/100 = 10%
P(CritDamage) = 10/100 = 10%
```

---

## Method Specifications

### generateMainAffix(from:)

**Preconditions**:
1. `pool` 至少有一個 weight > 0 的詞條

**Postconditions**:
1. 回傳一個有效的 Affix
2. 詞條類型來自 pool
3. 數值在 minValue ~ maxValue 範圍內

**Pseudo Code**:
```swift
func generateMainAffix(from pool: [WeightedAffix]) -> Affix {
    let validPool = pool.filter { $0.weight > 0 }
    guard !validPool.isEmpty else {
        fatalError("Main affix pool is empty")
    }

    let selected = selectByWeight(from: validPool)

    let value = Double.random(in: selected.minValue...selected.maxValue)

    return Affix(
        type: selected.type,
        value: value.rounded(toPlaces: 1),  // 四捨五入到小數第一位
        isPercentage: selected.isPercentage
    )
}
```

---

### generateSubAffixes(from:count:excluding:)

**Preconditions**:
1. `pool` 至少有 `count` 個不同的詞條類型（排除 excluding 後）
2. `count` >= 0

**Postconditions**:
1. 回傳 `count` 個不重複的 Affix
2. 所有詞條類型不在 `excluding` 中
3. 詞條類型互不相同

**Pseudo Code**:
```swift
func generateSubAffixes(from pool: [WeightedAffix], count: Int, excluding: AffixType) -> [Affix] {
    guard count > 0 else { return [] }

    var result: [Affix] = []
    var usedTypes: AffixType = excluding

    // 過濾可用的詞條池
    var availablePool = pool.filter { affix in
        affix.weight > 0 && !usedTypes.contains(affix.type)
    }

    for _ in 0..<count {
        guard !availablePool.isEmpty else { break }

        // 依權重選擇
        let selected = selectByWeight(from: availablePool)

        // 生成數值
        let value = Double.random(in: selected.minValue...selected.maxValue)
        let affix = Affix(
            type: selected.type,
            value: value.rounded(toPlaces: 1),
            isPercentage: selected.isPercentage
        )

        result.append(affix)

        // 標記已使用，從可用池移除
        usedTypes.insert(selected.type)
        availablePool.removeAll { $0.type == selected.type }
    }

    return result
}
```

---

## Testability

### Mock Random Generator

```swift
// 用於測試的可控隨機數產生器
class MockRandomGenerator: RandomNumberGenerator {
    private var values: [UInt64]
    private var index = 0

    init(values: [UInt64]) {
        self.values = values
    }

    func next() -> UInt64 {
        let value = values[index % values.count]
        index += 1
        return value
    }
}

// 使用方式
let mockRandom = MockRandomGenerator(values: [0])  // 總是選第一個
generator.setRandomGenerator(mockRandom)
```

---

## Test Cases

| Test Case | Given | When | Then |
|-----------|-------|------|------|
| testGenerateMainAffixWhenValidPoolThenSuccess | 有效的主詞條池 | generateMainAffix | 回傳符合權重分布的詞條 |
| testGenerateMainAffixWhenEmptyPoolThenFatalError | 空的詞條池 | generateMainAffix | fatalError |
| testGenerateSubAffixesWhenCountZeroThenEmptyArray | count = 0 | generateSubAffixes | 回傳空陣列 |
| testGenerateSubAffixesWhenExcludingThenFiltered | 排除 .crit | generateSubAffixes | 結果不含 .crit |
| testGenerateSubAffixesWhenCountFourThenAllUnique | count = 4 | generateSubAffixes | 4 個不重複的詞條 |
| testWeightDistributionWhenLargeSampleThenMatchesWeight | 權重 [30,30,20,10,10] | 生成 1000 次 | 分布接近權重比例 (誤差<5%) |
| testValueRangeWhenGeneratedThenWithinMinMax | min=5, max=10 | generateMainAffix | 5 <= value <= 10 |
| testMockRandomWhenFixedValueThenPredictable | MockRandom(0) | generateMainAffix | 總是選第一個詞條 |

---

## Statistical Validation

驗證權重分布的測試方法：

```swift
func testWeightDistribution() {
    let pool: [WeightedAffix] = [
        WeightedAffix(type: .hp, weight: 30, ...),
        WeightedAffix(type: .attack, weight: 30, ...),
        WeightedAffix(type: .defense, weight: 20, ...),
        WeightedAffix(type: .crit, weight: 10, ...),
        WeightedAffix(type: .critDamage, weight: 10, ...)
    ]

    var counts: [AffixType: Int] = [:]
    let sampleSize = 10000

    for _ in 0..<sampleSize {
        let affix = generator.generateMainAffix(from: pool)
        counts[affix.type, default: 0] += 1
    }

    // 驗證分布（允許 5% 誤差）
    let expectedHp = 0.30
    let actualHp = Double(counts[.hp]!) / Double(sampleSize)
    XCTAssertEqual(actualHp, expectedHp, accuracy: 0.05)

    // ... 其他詞條類型
}
```
