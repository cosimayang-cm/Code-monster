# RPG 物品/背包系統

[![Swift 5.9+](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20macOS-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

一個完整的 RPG 遊戲物品/背包系統實作，支援物品模板、詞條系統、套裝效果等功能。

## 功能特色

- 🎮 **物品系統**: 模板驅動的物品生成，支援 5 種稀有度
- ⚔️ **詞條系統**: Bitmask 實現 O(1) 詞條查詢，支援主詞條與副詞條
- 🎒 **背包管理**: 容量管理、多維度篩選與排序
- 👤 **角色系統**: 5 個裝備欄位、等級需求檢查
- 🔮 **套裝效果**: 自動計算套裝加成，支援多重效果
- 📦 **JSON 序列化**: 完整的存檔/讀檔支援

## 快速開始

```swift
import RPGInventorySystem

// 1. 建立服務
let templateService = ItemTemplateService()
let setService = EquipmentSetService()

// 2. 載入資料
try templateService.loadTemplates(from: "item_templates")
try setService.loadSets(from: "equipment_sets")

// 3. 建立角色
let avatar = Avatar(name: "勇者", level: 50, inventoryCapacity: 100)

// 4. 建立並裝備物品
let factory = ItemFactory(templateService: templateService)
let helmet = try factory.createRandomItem(templateId: "helmet_royal_001")
try avatar.equip(helmet)

// 5. 查看數值
print("最終攻擊力: \(avatar.finalStats.attack)")
```

## 系統架構

```
┌─────────────────────────────────────────────────────────────┐
│                         Avatar                              │
│  ┌─────────────────┐  ┌──────────────────────────────────┐ │
│  │ EquipmentSlots  │  │           Inventory              │ │
│  │ [5 slots]       │  │  [capacity: N items]             │ │
│  └────────┬────────┘  └──────────────┬───────────────────┘ │
│           │                          │                      │
│           └──────────┬───────────────┘                      │
│                      ▼                                      │
│              ┌───────────────┐                              │
│              │     Item      │                              │
│              │ ┌───────────┐ │                              │
│              │ │ AffixMask │ │  ◄── O(1) Query             │
│              │ └───────────┘ │                              │
│              └───────────────┘                              │
└─────────────────────────────────────────────────────────────┘
```

## 專案結構

```
src/
├── Models/
│   ├── Stats.swift           # 數值結構
│   ├── EquipmentSlot.swift   # 裝備欄位
│   ├── Rarity.swift          # 稀有度
│   ├── AffixType.swift       # 詞條 Bitmask
│   ├── Affix.swift           # 詞條
│   ├── ItemTemplate.swift    # 物品模板
│   ├── Item.swift            # 物品實例
│   ├── EquipmentSet.swift    # 套裝
│   ├── SetBonus.swift        # 套裝效果
│   ├── Avatar.swift          # 角色
│   └── Errors.swift          # 錯誤類型
├── Containers/
│   ├── Inventory.swift       # 背包
│   └── EquipmentSlots.swift  # 裝備欄
├── Services/
│   ├── AffixPool.swift           # 詞條池
│   ├── AffixValueCalculator.swift # 數值計算
│   ├── ItemFactory.swift          # 物品工廠
│   ├── ItemTemplateService.swift  # 模板服務
│   ├── EquipmentSetService.swift  # 套裝服務
│   └── SetBonusCalculator.swift   # 套裝計算
├── Protocols/
│   └── AffixContainer.swift  # 詞條容器協定
Resources/
├── item_templates.json       # 物品模板資料
└── equipment_sets.json       # 套裝資料
tests/
└── RPGInventorySystemTests.swift
```

## 詞條系統

使用 `OptionSet` 實現的 Bitmask 詞條查詢：

```swift
// O(1) 複雜度查詢
if item.hasAffix(.crit) {
    print("這件裝備有暴擊詞條！")
}

// 多重條件查詢
if item.hasAllAffixes([.crit, .critDamage]) {
    print("暴擊雙修神器！")
}

// 篩選背包物品
let critItems = inventory.filter(hasAffix: .crit)
```

## 套裝系統

```swift
// 設定套裝計算器
let calculator = SetBonusCalculator(setService: setService)
avatar.setSetBonusCalculator(calculator)

// 裝備套裝物品
try avatar.equip(royalHelmet)
try avatar.equip(royalBody)

// 查看啟動的效果
for bonus in avatar.activeSetBonuses {
    print("\(bonus.setName) \(bonus.requiredPieces)件: \(bonus.description)")
}
// 輸出: 昔日宗室之儀 2件: 攻擊力提升18%
```

## License

MIT License
