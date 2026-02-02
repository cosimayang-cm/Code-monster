# Technical Research: RPG 物品/背包系統

**Feature**: 004-rpg-inventory-system
**Date**: 2026-02-01

## Research Questions

### RQ-001: Bitmask vs Array 詞條查詢效能

**Question**: 使用 Bitmask 相比 Array 查詢詞條的效能差異？

**Findings**:

| 操作 | Bitmask (OptionSet) | Array |
|------|---------------------|-------|
| 單一詞條檢查 | O(1) - 位元運算 | O(n) - 線性搜尋 |
| 多詞條同時檢查 | O(1) - 位元 AND | O(n*m) - 巢狀迴圈 |
| 任一詞條檢查 | O(1) - 位元 AND + 比較 | O(n*m) |
| 插入詞條 | O(1) - 位元 OR | O(1) - append |
| 移除詞條 | O(1) - 位元 XOR | O(n) - 搜尋後移除 |

**Decision**: 使用 `OptionSet` 實作 `AffixType`，可支援最多 32 種詞條類型（UInt32）。

---

### RQ-002: UUID 版本選擇

**Question**: 物品實例 ID 應使用哪種 UUID 版本？

**Findings**:

| UUID 版本 | 特性 | 適用場景 |
|-----------|------|----------|
| v1 | 時間戳 + MAC 位址 | 需要時間排序 |
| v4 | 隨機生成 | 通用唯一識別 |
| v5 | 命名空間 + 名稱的 SHA-1 | 可重現的 ID |

**Decision**: 使用 **UUID v4**（Swift 的 `UUID()` 預設）。物品實例不需要時間排序，隨機 UUID 足夠保證唯一性。

---

### RQ-003: 數值計算順序

**Question**: 百分比加成應該基於什麼計算？

**Findings**:

常見 RPG 遊戲的數值計算公式：

```
方案 A: 疊加式
最終值 = 基礎值 × (1 + Σ百分比加成) + Σ固定加成

方案 B: 分層式
最終值 = ((基礎值 + 裝備固定值) × (1 + 裝備百分比)) × (1 + 套裝百分比)
```

**Decision**: 採用**方案 A（疊加式）**，簡化計算邏輯，且玩家容易理解。

---

### RQ-004: 詞條等級成長公式

**Question**: 主詞條數值如何隨等級成長？

**Findings**:

參考《原神》聖遺物系統：
- 主詞條採用線性成長
- 每級增加固定數值（約為初始值的 10%）
- 0 級 → 20 級約成長 3-4 倍

**Decision**: 
```
scaledValue(at level) = baseValue + (baseValue × 0.1 × level)
```

---

### RQ-005: 副詞條生成機制

**Question**: 副詞條如何避免重複？

**Findings**:

1. **完全不重複**: 同一件裝備的副詞條類型不可重複
2. **可重複但數值疊加**: 允許多條同類型詞條
3. **允許與主詞條重複**: 主副詞條可以是同類型

**Decision**: 採用**完全不重複**機制：
- 副詞條彼此不可重複
- 副詞條不可與主詞條重複
- 使用 Bitmask 排除已有詞條

---

### RQ-006: Swift OptionSet 最佳實踐

**Question**: 如何正確實作可序列化的 OptionSet？

**Findings**:

```swift
struct AffixType: OptionSet, Codable, Hashable {
    let rawValue: UInt32
    
    // 定義單一選項
    static let crit = AffixType(rawValue: 1 << 0)
    static let attack = AffixType(rawValue: 1 << 2)
    
    // Codable 需要自訂實作（預設不支援）
    init(from decoder: Decoder) throws {
        // 支援從字串或數字解碼
    }
    
    func encode(to encoder: Encoder) throws {
        // 編碼為字串（易讀）或數字（緊湊）
    }
}
```

**Decision**: 自訂 `Codable` 實作，支援從字串 key（如 `"crit"`）解碼，編碼時也使用字串以提高可讀性。

---

## Technology Decisions

| Decision ID | Topic | Choice | Rationale |
|-------------|-------|--------|-----------|
| TD-001 | 詞條查詢 | Bitmask (OptionSet) | O(1) 時間複雜度 |
| TD-002 | 物品 ID | UUID v4 | 簡單、足夠唯一 |
| TD-003 | 數值計算 | 疊加式 | 簡單易懂 |
| TD-004 | 等級成長 | 線性 10%/級 | 符合業界慣例 |
| TD-005 | 副詞條重複 | 不允許 | 增加多樣性 |
| TD-006 | 序列化格式 | JSON (字串 key) | 可讀性優先 |

## References

- [Swift OptionSet Documentation](https://developer.apple.com/documentation/swift/optionset)
- [UUID RFC 4122](https://tools.ietf.org/html/rfc4122)
- 《原神》聖遺物系統設計分析
