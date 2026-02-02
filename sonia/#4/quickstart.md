# Quickstart: RPG 道具系統

**Feature**: 003-rpg-item-system
**Date**: 2026-01-30

---

## 快速開始

### 1. 專案設定

```bash
# 進入專案目錄
cd sonia/#4

# 建立 Swift Package（如尚未建立）
swift package init --name ItemSystem --type library

# 執行測試
swift test
```

### 2. 基本使用範例

#### 創建角色與裝備

```swift
import Foundation

// 1. 建立物品模板
let helmetTemplate = ItemTemplate(
    templateId: "helmet_iron_001",
    name: "鐵製頭盔",
    description: "普通的鐵製頭盔，提供基本防護",
    slot: .helmet,
    rarity: .rare,
    levelRequirement: 5,
    baseStats: Stats(defense: 15, maxHP: 50)
)

// 2. 使用工廠生成物品實例
let affixGenerator = AffixGenerator(affixPools: defaultAffixPools)
let itemFactory = ItemFactory(
    templates: ["helmet_iron_001": helmetTemplate],
    affixGenerator: affixGenerator
)

let helmet = try itemFactory.createItem(from: "helmet_iron_001").get()

// 3. 建立角色
let avatar = Avatar(
    name: "勇者",
    level: 10,
    baseStats: Stats(attack: 100, defense: 50, maxHP: 1000)
)

// 4. 穿戴裝備
let result = avatar.equip(helmet, to: .helmet)
switch result {
case .success:
    print("裝備成功！")
    print("當前總數值: \(avatar.totalStats)")
case .failure(let error):
    print("裝備失敗: \(error)")
}
```

#### 詞條 Bitmask 查詢

```swift
// 檢查單一詞條
if helmet.hasAffix(.crit) {
    print("此裝備有暴擊詞條")
}

// 檢查是否同時擁有多個詞條
if helmet.hasAllAffixes([.crit, .attack]) {
    print("此裝備同時有暴擊和攻擊詞條")
}

// 檢查是否擁有任一詞條
if helmet.hasAnyAffix([.crit, .defense]) {
    print("此裝備有暴擊或防禦詞條其中之一")
}
```

#### 套裝效果

```swift
// 定義套裝
let royalSet = EquipmentSet(
    setId: "royal_set",
    name: "昔日宗室之儀",
    pieces: ["royal_flower", "royal_feather", "royal_sands", "royal_goblet", "royal_circlet"],
    bonuses: [
        SetBonus(requiredPieces: 2, statBonus: Stats(attack: 20), description: "攻擊力+20"),
        SetBonus(requiredPieces: 4, statBonus: Stats(critRate: 0.1), description: "暴擊率+10%")
    ]
)

// 計算套裝效果
let calculator = SetBonusCalculator(equipmentSets: ["royal_set": royalSet])
let activeBonuses = calculator.calculateBonuses(for: avatar.equipmentSlots.allEquippedItems())

for bonus in activeBonuses {
    print("觸發套裝效果: \(bonus.description)")
}
```

#### 背包管理

```swift
// 建立背包
var inventory = Inventory(capacity: 100)

// 添加物品
switch inventory.add(helmet) {
case .success:
    print("物品已加入背包")
case .failure(.inventoryFull):
    print("背包已滿")
case .failure(let error):
    print("錯誤: \(error)")
}

// 查詢物品
if let item = inventory.item(withId: helmet.instanceId) {
    print("找到物品: \(item.templateId)")
}
```

---

## TDD 開發流程

### 步驟 1: 先寫測試 (Red)

```swift
import XCTest

final class EquipmentSlotTests: XCTestCase {

    func testEquipItemWhenSlotMatchesThenItemEquipped() {
        // Given - 準備測試資料
        let slots = EquipmentSlots()
        let helmet = createTestHelmet()

        // When - 執行測試行為
        let result = slots.equip(helmet, to: .helmet)

        // Then - 驗證結果
        XCTAssertTrue(result.isSuccess)
        XCTAssertEqual(slots.item(at: .helmet)?.instanceId, helmet.instanceId)
    }

    func testEquipItemWhenSlotMismatchThenError() {
        // Given
        let slots = EquipmentSlots()
        let boots = createTestBoots()

        // When
        let result = slots.equip(boots, to: .helmet)

        // Then
        XCTAssertEqual(result.error, .slotMismatch(expected: .helmet, actual: .boots))
    }
}
```

### 步驟 2: 實作程式碼 (Green)

```swift
class EquipmentSlots: EquipmentSlotsProtocol {

    private var slots: [EquipmentSlot: Item] = [:]

    func equip(_ item: Item, to slot: EquipmentSlot) -> Result<Item?, ItemSystemError> {
        // 驗證欄位匹配
        guard item.slot == slot else {
            return .failure(.slotMismatch(expected: slot, actual: item.slot))
        }

        // 保存舊裝備
        let previousItem = slots[slot]

        // 裝備新物品
        slots[slot] = item

        return .success(previousItem)
    }
}
```

### 步驟 3: 重構 (Refactor)

確保：
- 程式碼符合 Swift 命名慣例
- 無重複程式碼
- 單一職責原則
- 所有測試仍然通過

---

## 測試命名規範

```
testMethodNameWhenConditionThenExpectedResult
```

### 範例

| 測試名稱 | 說明 |
|----------|------|
| `testEquipItemWhenSlotMatchesThenItemEquipped` | 裝備物品到正確欄位 |
| `testEquipItemWhenSlotMismatchThenSlotMismatchError` | 欄位不匹配時返回錯誤 |
| `testAddItemWhenInventoryFullThenInventoryFullError` | 背包滿時返回錯誤 |
| `testCalculateTotalStatsWhenMultipleItemsEquippedThenCorrectSum` | 多件裝備時數值正確加總 |
| `testGenerateSubAffixesWhenLegendaryThenFourAffixes` | 傳說品質生成4個副詞條 |
| `testHasAffixWhenAffixPresentThenTrue` | Bitmask 查詢找到詞條 |

---

## 常見錯誤處理

```swift
// 使用 Result 處理錯誤
let result = avatar.equip(item, to: .helmet)

switch result {
case .success:
    // 成功處理
    break
case .failure(.slotMismatch(let expected, let actual)):
    print("欄位錯誤：期望 \(expected)，實際 \(actual)")
case .failure(.levelRequirementNotMet(let required, let current)):
    print("等級不足：需要 \(required) 級，當前 \(current) 級")
case .failure(.inventoryFull):
    print("背包已滿")
case .failure(let error):
    print("其他錯誤：\(error)")
}
```

---

## 檔案結構速查

```
sonia/#4/Sources/ItemSystem/
├── Models/           # 資料模型
├── Systems/          # 業務邏輯
├── Containers/       # 容器（背包、裝備欄）
├── Avatar/           # 角色
└── Persistence/      # 持久化

sonia/#4/Tests/ItemSystemTests/
├── Models/           # 模型測試
├── Systems/          # 業務邏輯測試
├── Containers/       # 容器測試
├── Avatar/           # 角色測試
└── Persistence/      # 持久化測試
```

---

## 下一步

1. 執行 `/speckit.tasks` 生成任務清單
2. 按優先級依序實作各功能
3. 遵循 TDD：先寫測試 → 實作 → 重構
4. 確保每個任務完成後所有測試都通過
