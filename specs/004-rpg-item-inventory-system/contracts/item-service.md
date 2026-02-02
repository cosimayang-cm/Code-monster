# Contract: ItemService

**Module**: Services
**Version**: 1.0
**Date**: 2026-02-01

---

## Overview

ItemService 負責處理物品的穿戴、卸下、以及物品在背包與裝備欄之間的移動。

---

## Protocol Definition

```swift
protocol ItemServicing {
    /// 穿戴物品
    /// - Parameters:
    ///   - item: 要穿戴的物品
    ///   - avatar: 目標角色
    /// - Returns: 操作結果
    func equip(_ item: Item, on avatar: Avatar) -> EquipResult

    /// 卸下裝備
    /// - Parameters:
    ///   - slot: 要卸下的欄位
    ///   - avatar: 目標角色
    /// - Returns: 操作結果
    func unequip(slot: EquipmentSlot, from avatar: Avatar) -> UnequipResult

    /// 交換裝備（背包物品與已穿戴物品交換）
    /// - Parameters:
    ///   - item: 背包中的物品
    ///   - slot: 要交換的欄位
    ///   - avatar: 目標角色
    /// - Returns: 操作結果
    func swap(_ item: Item, with slot: EquipmentSlot, on avatar: Avatar) -> SwapResult
}
```

---

## Result Types

### EquipResult

```swift
enum EquipResult {
    case success(replacedItem: Item?)
    case failure(EquipError)
}

enum EquipError: Error {
    case slotMismatch(expected: EquipmentSlot, actual: EquipmentSlot)
    case levelTooLow(required: Int, actual: Int)
    case itemNotInInventory
}
```

### UnequipResult

```swift
enum UnequipResult {
    case success(item: Item)
    case failure(UnequipError)
}

enum UnequipError: Error {
    case slotEmpty
    case inventoryFull
}
```

### SwapResult

```swift
enum SwapResult {
    case success(unequippedItem: Item)
    case failure(SwapError)
}

enum SwapError: Error {
    case slotMismatch
    case levelTooLow(required: Int, actual: Int)
    case itemNotInInventory
}
```

---

## Method Specifications

### equip(_:on:)

**Preconditions**:
1. `item` 存在於 `avatar.inventory`
2. `item.slot` 與目標欄位相符
3. `avatar.level >= item.template.levelRequirement`

**Postconditions**:
1. `item` 從 `avatar.inventory` 移除
2. `item` 加入 `avatar.equipment` 對應欄位
3. 若原欄位有裝備，該裝備移至 `avatar.inventory`

**Pseudo Code**:
```swift
func equip(_ item: Item, on avatar: Avatar) -> EquipResult {
    // 驗證物品在背包中
    guard avatar.inventory.contains(item) else {
        return .failure(.itemNotInInventory)
    }

    // 驗證等級需求
    let required = item.template.levelRequirement
    guard avatar.level >= required else {
        return .failure(.levelTooLow(required: required, actual: avatar.level))
    }

    // 從背包移除
    avatar.inventory.remove(item)

    // 裝備物品（可能替換現有裝備）
    let replacedItem = avatar.equipment.equip(item)

    // 若有替換的裝備，放回背包
    if let replaced = replacedItem {
        avatar.inventory.add(replaced)
    }

    return .success(replacedItem: replacedItem)
}
```

---

### unequip(slot:from:)

**Preconditions**:
1. `avatar.equipment[slot]` 不為 nil
2. `avatar.inventory` 未滿

**Postconditions**:
1. 裝備從 `avatar.equipment` 移除
2. 裝備加入 `avatar.inventory`

**Pseudo Code**:
```swift
func unequip(slot: EquipmentSlot, from avatar: Avatar) -> UnequipResult {
    // 驗證欄位有裝備
    guard let item = avatar.equipment.getItem(at: slot) else {
        return .failure(.slotEmpty)
    }

    // 驗證背包有空間
    guard !avatar.inventory.isFull else {
        return .failure(.inventoryFull)
    }

    // 卸下裝備
    avatar.equipment.unequip(slot: slot)

    // 放入背包
    avatar.inventory.add(item)

    return .success(item: item)
}
```

---

### swap(_:with:on:)

**Preconditions**:
1. `item` 存在於 `avatar.inventory`
2. `item.slot == slot`
3. `avatar.level >= item.template.levelRequirement`
4. `avatar.equipment[slot]` 不為 nil

**Postconditions**:
1. 原裝備移至 `avatar.inventory`
2. `item` 從 `avatar.inventory` 移至 `avatar.equipment`

**Pseudo Code**:
```swift
func swap(_ item: Item, with slot: EquipmentSlot, on avatar: Avatar) -> SwapResult {
    // 驗證欄位相符
    guard item.slot == slot else {
        return .failure(.slotMismatch)
    }

    // 驗證等級需求
    let required = item.template.levelRequirement
    guard avatar.level >= required else {
        return .failure(.levelTooLow(required: required, actual: avatar.level))
    }

    // 驗證物品在背包中
    guard avatar.inventory.contains(item) else {
        return .failure(.itemNotInInventory)
    }

    // 執行交換
    avatar.inventory.remove(item)
    let unequipped = avatar.equipment.equip(item)!
    avatar.inventory.add(unequipped)

    return .success(unequippedItem: unequipped)
}
```

---

## Test Cases

| Test Case | Given | When | Then |
|-----------|-------|------|------|
| testEquipWhenValidThenSuccess | 背包有頭盔、頭盔欄空 | equip(helmet) | 頭盔裝備成功 |
| testEquipWhenSlotMismatchThenFailure | 背包有手套 | equip(手套) to helmet | failure(.slotMismatch) |
| testEquipWhenLevelTooLowThenFailure | 角色 Lv5、裝備需 Lv10 | equip(item) | failure(.levelTooLow) |
| testEquipWhenReplaceThenOldItemToInventory | 頭盔欄有裝備 | equip(新頭盔) | 舊頭盔進背包 |
| testUnequipWhenInventoryFullThenFailure | 背包已滿 | unequip(.helmet) | failure(.inventoryFull) |
| testSwapWhenValidThenSuccess | 背包有新頭盔、頭盔欄有舊頭盔 | swap(新頭盔) | 新舊交換 |
