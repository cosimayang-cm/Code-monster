# Feature Specification: RPG 物品/背包系統

**Feature Branch**: `004-rpg-inventory-system`  
**Created**: 2026-02-01  
**Status**: Draft  
**Input**: Code Monster #4 - RPG 遊戲的道具/物品欄/背包系統

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 物品生成與唯一識別 (Priority: P1)

玩家在遊戲中獲得裝備時，系統需要從物品模板生成具有唯一識別碼的物品實例。同一個模板可以生成多個不同的實例（例如：兩頂相同的鐵頭盔，但各自有獨立的 ID 和詞條）。

**Why this priority**: 物品的唯一識別是整個系統的基礎，沒有這個功能，其他所有功能都無法運作。

**Independent Test**: 可透過從同一模板生成多個物品實例，驗證每個實例的 UUID 唯一性。

**Acceptance Scenarios**:

1. **Given** 一個物品模板 "helmet_iron_001", **When** 生成物品實例, **Then** 物品擁有 UUID v4 格式的唯一 instanceId
2. **Given** 同一個模板, **When** 生成兩個物品實例, **Then** 兩個實例的 instanceId 不同，但 templateId 相同
3. **Given** 物品模板定義了基礎屬性, **When** 生成實例, **Then** 實例繼承模板的所有屬性

---

### User Story 2 - 裝備穿戴與卸下 (Priority: P1)

玩家可以將物品穿戴到角色的裝備欄位，每個欄位只能裝備對應類型的物品。穿戴時會檢查等級需求，卸下時物品會回到背包。

**Why this priority**: 裝備系統是 RPG 遊戲的核心互動，直接影響玩家體驗。

**Independent Test**: 可透過裝備一件頭盔到頭盔欄位，驗證裝備欄位限制和等級檢查功能。

**Acceptance Scenarios**:

1. **Given** 角色等級 50，物品等級需求 40, **When** 嘗試裝備, **Then** 裝備成功
2. **Given** 角色等級 5，物品等級需求 40, **When** 嘗試裝備, **Then** 裝備失敗並提示等級不足
3. **Given** 頭盔類型物品, **When** 嘗試裝備到身體欄位, **Then** 裝備失敗（欄位不符）
4. **Given** 已裝備一件頭盔, **When** 裝備另一件頭盔, **Then** 舊頭盔被替換並放入背包
5. **Given** 已裝備物品, **When** 卸下裝備, **Then** 物品移動到背包

---

### User Story 3 - 數值計算系統 (Priority: P1)

角色的最終數值由基礎值加上所有裝備提供的數值組成。裝備數值包含基礎數值、主詞條、副詞條、特殊屬性和套裝效果。

**Why this priority**: 數值系統是 RPG 遊戲的核心機制，影響戰鬥和遊戲平衡。

**Independent Test**: 可透過穿戴單件裝備後比較角色的數值變化來驗證。

**Acceptance Scenarios**:

1. **Given** 角色基礎攻擊力 100，裝備提供攻擊力 +20, **When** 計算最終數值, **Then** 最終攻擊力為 120
2. **Given** 裝備有百分比加成 +10% 攻擊力, **When** 基礎攻擊力 100, **Then** 加成後為 100 + 10 = 110
3. **Given** 主詞條數值會隨等級成長, **When** 物品等級從 1 提升到 10, **Then** 主詞條數值增加

---

### User Story 4 - 詞條系統與 Bitmask 查詢 (Priority: P2)

每件裝備擁有一個主詞條和多個副詞條（數量由稀有度決定）。使用 Bitmask 技術可以快速查詢物品是否擁有特定詞條組合。

**Why this priority**: 詞條系統增加裝備的隨機性和策略深度，是進階玩法的基礎。

**Independent Test**: 可透過檢查傳說裝備是否擁有 4 條副詞條，以及 Bitmask 查詢是否正確來驗證。

**Acceptance Scenarios**:

1. **Given** 普通稀有度物品, **When** 生成副詞條, **Then** 副詞條數量為 0
2. **Given** 傳說稀有度物品, **When** 生成副詞條, **Then** 副詞條數量為 4
3. **Given** 物品有暴擊詞條, **When** 查詢 `hasAffix(.crit)`, **Then** 返回 true
4. **Given** 物品有暴擊和攻擊詞條, **When** 查詢 `hasAllAffixes([.crit, .attack])`, **Then** 返回 true
5. **Given** 物品只有暴擊詞條, **When** 查詢 `hasAnyAffix([.crit, .defense])`, **Then** 返回 true

---

### User Story 5 - 套裝效果系統 (Priority: P2)

穿戴同一套裝的多件裝備時，會觸發套裝效果。例如穿戴 2 件觸發 2 件套效果，穿戴 4 件額外觸發 4 件套效果。

**Why this priority**: 套裝系統增加裝備搭配的策略性，提升遊戲深度。

**Independent Test**: 可透過穿戴同套裝 2 件裝備驗證 2 件套效果是否觸發。

**Acceptance Scenarios**:

1. **Given** 穿戴同套裝 2 件, **When** 計算套裝效果, **Then** 2 件套效果啟用
2. **Given** 穿戴同套裝 4 件, **When** 計算套裝效果, **Then** 2 件套和 4 件套效果都啟用
3. **Given** 穿戴 2 件 A 套裝 + 2 件 B 套裝, **When** 計算套裝效果, **Then** 兩個套裝的 2 件套效果都啟用
4. **Given** 套裝效果是攻擊力 +18%, **When** 基礎攻擊力 100, **Then** 套裝提供 18 點攻擊力加成

---

### User Story 6 - 背包管理 (Priority: P2)

玩家擁有一個有容量限制的背包，可以存放、取出、篩選物品。當背包滿時無法再加入物品。

**Why this priority**: 背包管理是基礎的物品管理功能。

**Independent Test**: 可透過在容量為 3 的背包加入 4 件物品來驗證容量限制。

**Acceptance Scenarios**:

1. **Given** 背包容量 100, **When** 加入第 101 件物品, **Then** 操作失敗並提示背包已滿
2. **Given** 背包中有多種裝備, **When** 依稀有度篩選, **Then** 只顯示指定稀有度的物品
3. **Given** 背包中有多件裝備, **When** 依詞條類型篩選, **Then** 只顯示擁有該詞條的物品

---

### User Story 7 - 詞條隨機生成與洗詞條 (Priority: P3)

詞條依據詞條池的權重隨機生成。玩家可以花費資源「洗詞條」，重新隨機生成一條副詞條。

**Why this priority**: 洗詞條是進階的付費/消耗功能。

**Independent Test**: 可透過多次生成詞條並統計分布來驗證權重系統。

**Acceptance Scenarios**:

1. **Given** 詞條池中 HP 權重 30、暴擊權重 10, **When** 大量生成詞條, **Then** HP 出現頻率約為暴擊的 3 倍
2. **Given** 物品有 4 條副詞條, **When** 洗第 1 條詞條, **Then** 第 1 條被新詞條替換，其他不變
3. **Given** 洗詞條時, **When** 生成新詞條, **Then** 排除物品已有的詞條類型（避免重複）

---

### User Story 8 - JSON 序列化與資料持久化 (Priority: P3)

物品模板和物品實例都可以序列化為 JSON 格式，支援從 JSON 載入和保存。

**Why this priority**: 資料持久化是儲存和讀取遊戲進度的基礎。

**Independent Test**: 可透過將物品序列化後再反序列化，驗證資料完整性。

**Acceptance Scenarios**:

1. **Given** 物品實例, **When** 序列化為 JSON, **Then** JSON 包含所有必要欄位
2. **Given** 有效的 JSON 字串, **When** 反序列化為物品, **Then** 物品屬性正確還原
3. **Given** 物品模板 JSON 檔案, **When** 載入, **Then** 可用於生成物品實例

---

### Edge Cases

- 當背包已滿且卸下裝備時，如何處理？（應阻止卸下操作）
- 當物品等級已達最大值時，嘗試升級的行為？（應忽略或提示）
- 當詞條池中沒有可用詞條時（都被排除）如何處理？（應返回 nil 或使用備用池）
- 當套裝只有部分裝備定義時，如何計算套裝件數？（只計算實際存在的裝備）

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: 系統 MUST 使用 UUID v4 為每個物品實例生成唯一識別碼
- **FR-002**: 系統 MUST 支援 5 個裝備欄位：頭盔、身體、手套、鞋子、腰帶
- **FR-003**: 系統 MUST 支援 5 種稀有度：普通、優良、稀有、史詩、傳說
- **FR-004**: 系統 MUST 支援 7 種基礎數值：攻擊、防禦、最大生命、最大魔力、暴擊率、暴擊傷害、速度
- **FR-005**: 系統 MUST 在裝備時檢查角色等級是否滿足物品等級需求
- **FR-006**: 系統 MUST 根據稀有度決定副詞條數量（普通 0、優良 1、稀有 2、史詩 3、傳說 4）
- **FR-007**: 系統 MUST 使用 Bitmask (OptionSet) 實現詞條快速查詢
- **FR-008**: 系統 MUST 支援套裝效果的自動計算（2件套、4件套等）
- **FR-009**: 系統 MUST 支援背包容量限制
- **FR-010**: 系統 MUST 支援物品的 JSON 序列化與反序列化
- **FR-011**: 系統 MUST 支援詞條的權重隨機生成
- **FR-012**: 系統 MUST 支援主詞條數值隨物品等級成長

### Key Entities

- **ItemTemplate**: 物品模板，定義物品的藍圖（templateId, name, slot, rarity, baseStats 等）
- **Item**: 物品實例，從模板生成的實際物品（instanceId, templateId, level, mainAffix, subAffixes 等）
- **AffixType**: 詞條類型，使用 Bitmask 實現（crit, attack, defense, hp 等）
- **Affix**: 詞條，包含類型、數值、是否百分比
- **EquipmentSet**: 套裝定義，包含套裝 ID、名稱、包含的物品、套裝效果
- **SetBonus**: 套裝效果，包含所需件數、效果類型、數值
- **Stats**: 數值集合，包含 7 種基礎屬性
- **Avatar**: 角色，整合裝備欄、背包、數值計算
- **EquipmentSlots**: 裝備欄，管理 5 個裝備格
- **Inventory**: 背包，管理未穿戴的物品

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 從同一模板生成 1000 個物品實例，UUID 唯一率 100%
- **SC-002**: 裝備欄位檢查準確率 100%（不允許錯誤欄位裝備）
- **SC-003**: 等級需求檢查準確率 100%
- **SC-004**: 數值計算誤差 < 0.001（浮點數精度）
- **SC-005**: 詞條 Bitmask 查詢時間複雜度 O(1)
- **SC-006**: 套裝效果計算在穿戴/卸下裝備時自動更新
- **SC-007**: 背包操作（新增、移除、篩選）時間複雜度 O(n) 或更優
- **SC-008**: JSON 序列化/反序列化後資料完整性 100%
- **SC-009**: 副詞條數量與稀有度對應正確率 100%
- **SC-010**: 權重隨機生成的分布在統計上符合預期（卡方檢驗 p > 0.05）
