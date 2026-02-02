# Research: RPG 道具/物品欄/背包系統

**Feature**: 004-rpg-item-inventory-system
**Date**: 2026-02-01
**Status**: Complete

## Research Summary

此研究文件記錄 RPG 道具系統設計的技術決策與最佳實踐。

---

## R1: Bitmask 在遊戲開發中的應用

### Decision
使用 Swift `OptionSet` 實現詞條類型的 Bitmask 表示法。

### Rationale
1. **O(1) 查詢效率**：位運算比陣列遍歷快
2. **記憶體效率**：單一 UInt32 可表示 32 種詞條
3. **組合查詢**：支援 AND/OR/XOR 快速篩選
4. **Swift 原生支援**：OptionSet 提供型別安全的位運算

### Alternatives Considered

| 方案 | 優點 | 缺點 | 結論 |
|------|------|------|------|
| Set<AffixType> | 語意清晰 | O(n) 查詢、記憶體較大 | 不採用 |
| [Bool] 陣列 | 簡單直觀 | 索引管理困難、擴展性差 | 不採用 |
| OptionSet | O(1)、型別安全 | 學習曲線稍高 | **採用** |

### Implementation Notes

```swift
// 使用位移確保唯一性
static let crit = AffixType(rawValue: 1 << 0)  // bit 0
static let attack = AffixType(rawValue: 1 << 2)  // bit 2

// 查詢範例
let hasAllCritAndAttack = affixMask.contains([.crit, .attack])
let hasAnyCritOrDefense = !affixMask.isDisjoint(with: [.crit, .defense])
```

---

## R2: UUID 生成策略

### Decision
使用 UUID v4（隨機）作為物品實例 ID。

### Rationale
1. **唯一性保證**：衝突機率約 2^-122，實務上可忽略
2. **無需中央伺服器**：本地即可生成
3. **Swift 原生支援**：`UUID()` 即可生成

### Alternatives Considered

| 方案 | 優點 | 缺點 | 結論 |
|------|------|------|------|
| 自增 ID | 簡單、有序 | 需要中央管理、多實例衝突 | 不採用 |
| UUID v1 (時間+MAC) | 有序 | 隱私問題、MAC 依賴 | 不採用 |
| UUID v4 (隨機) | 簡單、無依賴 | 無序 | **採用** |
| Snowflake ID | 有序、高效 | 複雜度高、需要配置 | 過度設計 |

### Implementation Notes

```swift
struct Item {
    let instanceId: UUID = UUID()  // 自動生成 UUID v4
}
```

---

## R3: 數值計算公式設計

### Decision
採用「固定值先加，百分比後乘」的計算順序。

### Formula
```
最終數值 = (基礎值 + Σ固定加成) × (1 + Σ百分比加成)
```

### Rationale
1. **業界慣例**：大多數 RPG 遊戲採用此公式
2. **數值平衡**：避免百分比先乘導致數值爆炸
3. **可預測性**：玩家容易理解計算邏輯

### Example Calculation

```
基礎攻擊力 = 100
裝備 A: +30 攻擊力（固定）
裝備 B: +10% 攻擊力（百分比）
裝備 C: +20 攻擊力（固定）
裝備 D: +5% 攻擊力（百分比）

計算步驟：
1. 固定加成總和 = 30 + 20 = 50
2. 百分比加成總和 = 10% + 5% = 15%
3. 最終攻擊力 = (100 + 50) × (1 + 0.15) = 150 × 1.15 = 172.5
```

### Alternatives Considered

| 方案 | 公式 | 問題 | 結論 |
|------|------|------|------|
| 順序套用 | ((base+A)×B+C)×D | 順序影響結果、難以平衡 | 不採用 |
| 百分比先乘 | base×(1+%)+(固定) | 百分比價值降低 | 不採用 |
| 分離計算 | **採用** | 清晰、可預測 | **採用** |

---

## R4: 權重隨機演算法

### Decision
使用累積權重法（Cumulative Distribution）選擇詞條。

### Rationale
1. **時間複雜度**：O(n) 單次選擇，n 為詞條池大小
2. **空間複雜度**：O(1) 額外空間
3. **正確性**：數學上保證符合權重分布

### Algorithm

```swift
func selectByWeight<T>(from pool: [(item: T, weight: Int)]) -> T {
    let totalWeight = pool.reduce(0) { $0 + $1.weight }
    var random = Int.random(in: 0..<totalWeight)

    for (item, weight) in pool {
        random -= weight
        if random < 0 {
            return item
        }
    }
    return pool.last!.item  // fallback
}
```

### Validation

對於權重池 `[A:30, B:20, C:10]`（總權重 60）：
- A 的機率 = 30/60 = 50%
- B 的機率 = 20/60 = 33.3%
- C 的機率 = 10/60 = 16.7%

---

## R5: 套裝效果觸發機制

### Decision
使用 Dictionary 計數 + 門檻判定。

### Rationale
1. **效率**：O(n) 遍歷裝備，n 最多 5
2. **靈活性**：支援任意件套效果（2件、4件、6件...）
3. **可維護性**：套裝定義與判定邏輯分離

### Algorithm

```swift
func getActiveSetBonuses(equippedItems: [Item]) -> [SetBonus] {
    // Step 1: 計數各套裝已穿戴件數
    var setCounts: [SetId: Int] = [:]
    for item in equippedItems {
        if let setId = item.setId {
            setCounts[setId, default: 0] += 1
        }
    }

    // Step 2: 判定觸發的套裝效果
    var activeBonuses: [SetBonus] = []
    for (setId, count) in setCounts {
        let setDefinition = SetRegistry.get(setId)
        for bonus in setDefinition.bonuses {
            if count >= bonus.requiredPieces {
                activeBonuses.append(bonus)
            }
        }
    }

    return activeBonuses
}
```

---

## R6: 協議導向設計（Protocol-Oriented Design）

### Decision
使用 Protocol 定義核心介面，支援測試注入。

### Rationale
1. **可測試性**：Mock 注入方便單元測試
2. **擴展性**：新增屬性類型無需修改現有程式碼
3. **Swift 最佳實踐**：POP 是 Swift 推薦的設計模式

### Key Protocols

```swift
// 詞條生成器協議
protocol AffixGenerating {
    func generate(from pool: AffixPool, count: Int) -> [Affix]
}

// 數值計算器協議
protocol StatsCalculating {
    func calculate(base: Stats, equipment: [Item]) -> Stats
}

// 套裝效果計算器協議
protocol SetBonusCalculating {
    func calculate(equippedItems: [Item]) -> [SetBonus]
}

// 物品序列化協議
protocol ItemSerializing {
    func encode(_ item: Item) throws -> Data
    func decode(_ data: Data) throws -> Item
}
```

---

## R7: JSON Schema 設計

### Decision
使用 Swift Codable 自動處理 JSON 序列化。

### Item Template JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["templateId", "name", "description", "slot", "rarity", "levelRequirement", "baseStats"],
  "properties": {
    "templateId": { "type": "string", "pattern": "^[a-z_]+_\\d{3}$" },
    "name": { "type": "string" },
    "description": { "type": "string" },
    "slot": { "enum": ["helmet", "body", "gloves", "boots", "belt"] },
    "rarity": { "enum": ["common", "uncommon", "rare", "epic", "legendary"] },
    "levelRequirement": { "type": "integer", "minimum": 1 },
    "baseStats": {
      "type": "object",
      "additionalProperties": { "type": "number" }
    },
    "attributes": { "type": "array" },
    "setId": { "type": "string" },
    "iconAsset": { "type": "string" },
    "modelAsset": { "type": "string" }
  }
}
```

### Item Instance JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["instanceId", "templateId", "level", "mainAffix", "subAffixes", "affixMask"],
  "properties": {
    "instanceId": { "type": "string", "format": "uuid" },
    "templateId": { "type": "string" },
    "level": { "type": "integer", "minimum": 1 },
    "mainAffix": { "$ref": "#/definitions/affix" },
    "subAffixes": {
      "type": "array",
      "items": { "$ref": "#/definitions/affix" },
      "maxItems": 4
    },
    "affixMask": { "type": "integer" }
  },
  "definitions": {
    "affix": {
      "type": "object",
      "properties": {
        "type": { "type": "string" },
        "value": { "type": "number" },
        "isPercentage": { "type": "boolean" }
      }
    }
  }
}
```

---

## Open Questions (Resolved)

| 問題 | 決策 | 理由 |
|------|------|------|
| 主詞條成長公式？ | 線性成長 `value = base × (1 + 0.1 × level)` | 簡單、可預測 |
| 副詞條可否重複？ | 不可重複（同類型詞條只能有一條） | 增加詞條多樣性 |
| 背包滿時獲得新物品？ | 拒絕獲得並提示 | 避免物品丟失 |
| 浮點精度處理？ | 顯示時四捨五入到小數點後一位 | 簡化實作 |

---

## References

1. [Swift OptionSet Documentation](https://developer.apple.com/documentation/swift/optionset)
2. [UUID RFC 4122](https://tools.ietf.org/html/rfc4122)
3. [Weighted Random Selection Algorithm](https://en.wikipedia.org/wiki/Fitness_proportionate_selection)
4. [Protocol-Oriented Programming in Swift (WWDC 2015)](https://developer.apple.com/videos/play/wwdc2015/408/)
