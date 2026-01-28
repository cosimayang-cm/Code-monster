# Code Monster #4: RPG 遊戲的 道具/物品欄/背包 系統

## 題目背景

你正在開發一款 RPG 遊戲，需要設計一套**裝備道具系統**。玩家的角色（Avatar）可以穿戴各種裝備來提升能力數值。

---

## 裝備欄位定義

角色共有 **5 個裝備格**：

| 欄位 | Slot ID | 說明 |
|------|---------|------|
| 頭盔 | `helmet` | 頭部防具 |
| 身體 | `body` | 軀幹護甲 |
| 手套 | `gloves` | 手部裝備 |
| 鞋子 | `boots` | 腳部裝備 |
| 腰帶 | `belt` | 腰部配件 |

---

## 題目要求

請設計一套物品系統，需包含以下元素：

### 1. 物品 ID 系統

設計一套 **唯一識別碼規則**，讓每個物品實例都有獨一無二的 ID：

- **模板 ID (Template ID)**：定義物品的「種類」，例如 `helmet_iron_001`
- **實例 ID (Instance ID)**：每個實際存在的物品都有獨立 ID，例如 `item_a1b2c3d4`

```
思考題：
- 同一個模板可以生成多個實例（例如：兩頂相同的鐵頭盔）
- 如何設計 ID 讓系統能快速查找？
- ID 應該包含哪些資訊？
```

---

### 2. 物品模板 JSON 設計

設計一個 JSON Schema 來定義物品模板。以下為參考範例：

```json
{
  "templateId": "helmet_iron_001",
  "name": "鐵製頭盔",
  "description": "普通的鐵製頭盔，提供基本防護",
  "slot": "helmet",
  "rarity": "common",
  "levelRequirement": 5,
  "baseStats": {
    "defense": 15,
    "maxHP": 50
  },
  "attributes": [],
  "iconAsset": "icon_helmet_iron",
  "modelAsset": "model_helmet_iron"
}
```

**你需要設計的 JSON 欄位：**

| 欄位 | 型別 | 必填 | 說明 |
|------|------|------|------|
| `templateId` | String | ✓ | 模板唯一識別碼 |
| `name` | String | ✓ | 顯示名稱 |
| `description` | String | ✓ | 物品描述 |
| `slot` | Enum | ✓ | 裝備欄位 |
| `rarity` | Enum | ✓ | 稀有度 |
| `levelRequirement` | Int | ✓ | 等級需求 |
| `baseStats` | Dict | ✓ | 基礎數值 |
| `attributes` | Array | ✓ | 特殊屬性列表 |
| `iconAsset` | String | | 圖示資源名稱 |
| `modelAsset` | String | | 3D 模型資源名稱 |

---

### 3. 數值系統 (Stats)

設計角色的**基礎數值**，裝備可以增減這些數值：

| 數值 | Key | 說明 | 範例 |
|------|-----|------|------|
| 攻擊力 | `attack` | 物理攻擊傷害 | +10 |
| 防禦力 | `defense` | 物理傷害減免 | +15 |
| 最大生命 | `maxHP` | 生命值上限 | +100 |
| 最大魔力 | `maxMP` | 魔力值上限 | +50 |
| 暴擊率 | `critRate` | 暴擊機率 (0.0~1.0) | +0.05 |
| 暴擊傷害 | `critDamage` | 暴擊傷害倍率 | +0.2 |
| 速度 | `speed` | 行動速度 | +10 |

**數值計算公式：**
```
最終數值 = 角色基礎值 + Σ(所有裝備的該數值)
```

---

### 4. 屬性系統 (Attributes)

屬性是裝備上的**特殊效果**，分為以下幾類：

#### 4.1 稀有度 (Rarity)

| 稀有度 | Key | 顏色 | 屬性條數 |
|--------|-----|------|----------|
| 普通 | `common` | 白色 | 0 |
| 優良 | `uncommon` | 綠色 | 1 |
| 稀有 | `rare` | 藍色 | 2 |
| 史詩 | `epic` | 紫色 | 3 |
| 傳說 | `legendary` | 橘色 | 4 |

#### 4.2 屬性類型

**A. 數值加成型**
```json
{
  "type": "stat_bonus",
  "stat": "attack",
  "value": 25,
  "isPercentage": false
}
```

**B. 百分比加成型**
```json
{
  "type": "stat_bonus",
  "stat": "maxHP",
  "value": 10,
  "isPercentage": true
}
```

**C. 元素附加型**
```json
{
  "type": "element",
  "element": "fire",
  "value": 30
}
```
元素種類：`fire`(火), `ice`(冰), `lightning`(雷), `poison`(毒)

**D. 特殊效果型**
```json
{
  "type": "special",
  "effect": "lifesteal",
  "value": 5
}
```
特殊效果：`lifesteal`(吸血), `reflect`(反傷), `thorns`(荊棘)

---

### 5. 詞條系統 (Affixes)

詞條是裝備上的**隨機屬性**，分為主詞條與副詞條。

#### 5.1 主詞條 (Main Affix)

每件裝備都有**一個固定的主詞條**，決定該裝備的主要加成方向：

```json
{
  "mainAffix": {
    "type": "maxHP",
    "value": 14.9,
    "isPercentage": true
  }
}
```

**主詞條數值會隨裝備等級提升而增加。**

#### 5.2 副詞條 (Sub Affixes)

副詞條是**隨機生成**的額外屬性，數量由稀有度決定：

| 稀有度 | 初始副詞條數 | 最大副詞條數 |
|--------|-------------|-------------|
| 普通 | 0 | 0 |
| 優良 | 1 | 2 |
| 稀有 | 2 | 3 |
| 史詩 | 3 | 4 |
| 傳說 | 4 | 4 |

```json
{
  "subAffixes": [
    { "type": "critRate", "value": 3.5, "isPercentage": true },
    { "type": "maxHP", "value": 239, "isPercentage": false },
    { "type": "elementalMastery", "value": 16, "isPercentage": false },
    { "type": "attack", "value": 14, "isPercentage": false }
  ]
}
```

#### 5.3 詞條類型定義 (Affix Types)

使用 **Bitmask** 來表示詞條類型，方便快速查詢與組合判斷：

| Bit 位置 | Bitmask | 詞條類型 | Key |
|----------|---------|----------|-----|
| 第 0 位 | `0b0001` | 暴擊 | `crit` |
| 第 1 位 | `0b0010` | 充能 | `energyRecharge` |
| 第 2 位 | `0b0100` | 攻擊 | `attack` |
| 第 3 位 | `0b1000` | 防禦 | `defense` |
| 第 4 位 | `0b0001_0000` | 生命 | `hp` |
| 第 5 位 | `0b0010_0000` | 元素精通 | `elementalMastery` |
| 第 6 位 | `0b0100_0000` | 元素傷害 | `elementalDamage` |
| 第 7 位 | `0b1000_0000` | 治療加成 | `healingBonus` |

#### 5.4 Bitmask 操作範例

```swift
struct AffixType: OptionSet {
    let rawValue: UInt32

    static let crit           = AffixType(rawValue: 0b0000_0001)
    static let energyRecharge = AffixType(rawValue: 0b0000_0010)
    static let attack         = AffixType(rawValue: 0b0000_0100)
    static let defense        = AffixType(rawValue: 0b0000_1000)
    static let hp             = AffixType(rawValue: 0b0001_0000)
    static let elementalMastery = AffixType(rawValue: 0b0010_0000)
    static let elementalDamage  = AffixType(rawValue: 0b0100_0000)
    static let healingBonus     = AffixType(rawValue: 0b1000_0000)
}

// 使用範例
var playerAffixes: AffixType = []  // 初始無詞條

// 獲得暴擊詞條
playerAffixes.insert(.crit)        // playerAffixes = 0b0001

// 再獲得充能詞條
playerAffixes.insert(.energyRecharge)  // playerAffixes = 0b0011

// 檢測是否同時擁有暴擊和充能
let hasBoth = playerAffixes.contains([.crit, .energyRecharge])  // true

// 檢測是否擁有任一（暴擊或攻擊）
let hasAny = !playerAffixes.isDisjoint(with: [.crit, .attack])  // true
```

#### 5.5 詞條池與權重

定義哪些詞條可以出現在哪些部位，以及出現機率：

```json
{
  "affixPool": {
    "helmet": {
      "mainAffixPool": [
        { "type": "hp", "weight": 30 },
        { "type": "attack", "weight": 30 },
        { "type": "defense", "weight": 20 },
        { "type": "critRate", "weight": 10 },
        { "type": "critDamage", "weight": 10 }
      ],
      "subAffixPool": [
        { "type": "hp", "weight": 15 },
        { "type": "attack", "weight": 15 },
        { "type": "defense", "weight": 15 },
        { "type": "critRate", "weight": 10 },
        { "type": "critDamage", "weight": 10 },
        { "type": "energyRecharge", "weight": 10 },
        { "type": "elementalMastery", "weight": 25 }
      ]
    }
  }
}
```

**權重計算公式：**
```
某詞條出現機率 = 該詞條權重 / Σ(詞條池所有權重)
```

---

### 6. 套裝系統 (Set Bonuses)

穿戴同系列多件裝備時，觸發額外效果：

#### 6.1 套裝定義

```json
{
  "setId": "royal_set",
  "name": "昔日宗室之儀",
  "pieces": ["royal_flower", "royal_feather", "royal_sands", "royal_goblet", "royal_circlet"],
  "bonuses": [
    {
      "requiredPieces": 2,
      "effect": {
        "type": "stat_bonus",
        "stat": "elementalBurstDamage",
        "value": 20,
        "isPercentage": true
      },
      "description": "元素爆發造成的傷害提升20%"
    },
    {
      "requiredPieces": 4,
      "effect": {
        "type": "team_buff",
        "stat": "attack",
        "value": 20,
        "isPercentage": true,
        "duration": 12,
        "trigger": "onElementalBurst"
      },
      "description": "施放元素爆發後，隊伍中所有角色攻擊力提升20%，持續12秒"
    }
  ]
}
```

#### 6.2 套裝效果類型

| 類型 | Key | 說明 |
|------|-----|------|
| 數值加成 | `stat_bonus` | 直接增加某數值 |
| 隊伍增益 | `team_buff` | 對全隊生效的 buff |
| 條件觸發 | `conditional` | 滿足條件時觸發 |
| 元素反應 | `elemental_reaction` | 增強元素反應效果 |

---

### 7. 完整物品實例範例

```json
{
  // instanceId 使用 UUID（版本不限，建議 UUID v4）
  "instanceId": "550e8400-e29b-41d4-a716-446655440000",
  "templateId": "goblet_royal_001",
  "name": "宗室銀瓮",
  "description": "昔日宗室之儀的空之杯",
  "slot": "goblet",
  "rarity": "legendary",
  "level": 4,
  "maxLevel": 20,
  "levelRequirement": 40,
  "setId": "royal_set",

  // 主詞條（固定，數值隨等級成長）
  "mainAffix": {
    "type": "hp",
    "value": 14.9,
    "isPercentage": true
  },

  // 副詞條（隨機生成，傳說品質最多4條）
  // 使用 Bitmask 可快速查詢：affixMask = 0b0001_0101 (crit + attack + hp)
  "subAffixes": [
    { "type": "critRate", "value": 3.5, "isPercentage": true },
    { "type": "hp", "value": 239, "isPercentage": false },
    { "type": "elementalMastery", "value": 16, "isPercentage": false },
    { "type": "attack", "value": 14, "isPercentage": false }
  ],
  "affixMask": 21
}
```

---

## OOP 設計任務

請使用 **Swift** 實作以下類別/結構：

### Level 1: 基礎結構

```swift
// TODO: 實作以下型別

/// 裝備欄位
enum EquipmentSlot { }

/// 稀有度
enum Rarity { }

/// 基礎數值
struct Stats { }

/// 物品模板
struct ItemTemplate { }

/// 物品實例
class Item { }
```

### Level 2: 詞條系統

```swift
// TODO: 實作詞條系統

/// 詞條類型（使用 OptionSet 實現 Bitmask）
struct AffixType: OptionSet {
    let rawValue: UInt32

    static let crit: AffixType
    static let energyRecharge: AffixType
    static let attack: AffixType
    static let defense: AffixType
    static let hp: AffixType
    static let elementalMastery: AffixType
    // ...
}

/// 詞條
struct Affix {
    let type: AffixType
    let value: Double
    let isPercentage: Bool
}

/// 詞條生成器（根據權重隨機生成）
class AffixGenerator { }
```

### Level 3: 套裝系統

```swift
// TODO: 實作套裝系統

/// 套裝效果
struct SetBonus { }

/// 套裝定義
struct EquipmentSet { }

/// 套裝效果計算器
class SetBonusCalculator { }
```

### Level 4: 裝備欄與背包

```swift
// TODO: 實作容器系統

/// 裝備欄（已穿戴的裝備）
class EquipmentSlots { }

/// 背包（未穿戴的物品）
class Inventory { }

/// 角色
class Avatar { }
```

### Level 5: 進階功能

- [ ] 從 JSON 載入物品模板與詞條池
- [ ] 物品實例的序列化/反序列化
- [ ] 計算角色穿戴所有裝備後的總數值（含主副詞條）
- [ ] 裝備穿戴/卸下的邏輯（含欄位檢查）
- [ ] 背包容量限制
- [ ] 詞條 Bitmask 快速查詢（檢測是否擁有特定詞條組合）
- [ ] 套裝效果自動觸發與計算

---

## 測試案例

請為以下情境撰寫單元測試：

### 基礎功能測試
1. **物品建立測試**：從模板建立物品實例，驗證 UUID 唯一性
2. **數值計算測試**：穿戴裝備後，角色數值正確增加
3. **裝備限制測試**：無法在錯誤欄位裝備物品
4. **背包管理測試**：背包滿時無法再加入物品

### 詞條系統測試
5. **主詞條測試**：驗證主詞條數值隨等級正確成長
6. **副詞條生成測試**：根據稀有度生成正確數量的副詞條
7. **詞條權重測試**：詞條按權重機率正確分布
8. **Bitmask 測試**：
   - 單一詞條檢測 `contains(.crit)`
   - 多詞條同時檢測 `contains([.crit, .attack])`
   - 任一詞條檢測 `!isDisjoint(with: [.crit, .defense])`

### 套裝系統測試
9. **2件套效果測試**：穿戴2件同套裝備時觸發效果
10. **4件套效果測試**：穿戴4件時觸發更高階效果
11. **混搭套裝測試**：同時穿戴多個不同套裝的效果計算

---

## 挑戰

- **洗詞條功能**：重新隨機一條副詞條，使用 Bitmask 排除已有詞條
