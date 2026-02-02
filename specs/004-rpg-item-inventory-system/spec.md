# Feature Specification: RPG 道具/物品欄/背包系統

**Feature Branch**: `004-rpg-item-inventory-system`
**Created**: 2026-02-01
**Status**: Draft
**Input**: User description: "RPG 遊戲的裝備道具系統，包含物品 ID 系統、模板設計、數值系統、屬性系統、詞條系統、套裝系統"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 建立物品實例 (Priority: P1)

玩家獲得新裝備時，系統從物品模板建立一個獨特的物品實例。每個實例都有唯一的 Instance ID，並根據模板定義的稀有度隨機生成對應數量的副詞條。

**Why this priority**: 物品實例建立是整個系統的基礎，沒有物品實例就無法進行任何其他操作（穿戴、背包管理、數值計算等）。

**Independent Test**: 可透過建立多個物品實例來驗證，確認每個實例都有唯一 ID，且副詞條數量符合稀有度規範。

**Acceptance Scenarios**:

1. **Given** 一個「普通」稀有度的頭盔模板, **When** 系統建立物品實例, **Then** 實例應有唯一 UUID 且副詞條數為 0
2. **Given** 一個「傳說」稀有度的腰帶模板, **When** 系統建立物品實例, **Then** 實例應有唯一 UUID 且副詞條數為 4
3. **Given** 同一個模板連續建立兩個實例, **When** 比較兩者的 Instance ID, **Then** 兩者 ID 必須不同

---

### User Story 2 - 裝備穿戴與卸下 (Priority: P1)

玩家可以將背包中的裝備穿戴到角色對應的裝備欄位（頭盔、身體、手套、鞋子、腰帶），也可以卸下已穿戴的裝備回到背包。

**Why this priority**: 裝備穿戴是 RPG 遊戲的核心互動，玩家需要透過穿戴裝備來提升角色能力。

**Independent Test**: 可透過嘗試穿戴/卸下不同類型的裝備來驗證，確認欄位限制正確執行。

**Acceptance Scenarios**:

1. **Given** 一件頭盔在背包中且頭盔欄位為空, **When** 玩家穿戴該頭盔, **Then** 頭盔移至角色頭盔欄位，背包中移除該物品
2. **Given** 一件手套在背包中, **When** 玩家嘗試將手套穿戴到頭盔欄位, **Then** 系統拒絕操作並提示欄位不符
3. **Given** 角色頭盔欄位已有裝備, **When** 玩家穿戴新頭盔, **Then** 舊頭盔回到背包，新頭盔穿戴到頭盔欄位
4. **Given** 玩家等級為 10，裝備需求等級為 15, **When** 玩家嘗試穿戴該裝備, **Then** 系統拒絕操作並提示等級不足

---

### User Story 3 - 角色數值計算 (Priority: P1)

系統計算角色穿戴所有裝備後的總數值，包括基礎數值、主詞條、副詞條的加成，以及百分比加成的正確計算。

**Why this priority**: 數值計算直接影響遊戲玩法，玩家需要看到裝備對角色能力的實際影響。

**Independent Test**: 可透過穿戴/卸下裝備並驗證角色總數值的變化來測試。

**Acceptance Scenarios**:

1. **Given** 角色基礎攻擊力為 100，穿戴一件 +25 攻擊力的裝備, **When** 計算總攻擊力, **Then** 結果為 125
2. **Given** 角色基礎生命值為 1000，穿戴一件 +10% 最大生命的裝備, **When** 計算總生命值, **Then** 結果為 1100
3. **Given** 穿戴多件裝備（含固定值與百分比加成）, **When** 計算總數值, **Then** 先加總固定值，再套用百分比加成

---

### User Story 4 - 背包管理 (Priority: P2)

玩家可以在背包中管理物品，包括查看物品清單、物品詳情，以及在背包容量限制下新增/移除物品。

**Why this priority**: 背包是物品儲存的基礎設施，但優先於進階功能（詞條洗練、套裝效果）。

**Independent Test**: 可透過新增/移除物品並驗證背包狀態來測試。

**Acceptance Scenarios**:

1. **Given** 背包容量為 50，目前有 49 件物品, **When** 新增一件物品, **Then** 物品成功加入，背包顯示 50/50
2. **Given** 背包已滿（50/50）, **When** 嘗試新增新物品, **Then** 系統拒絕並提示背包已滿
3. **Given** 背包中有某物品, **When** 查看該物品詳情, **Then** 顯示完整資訊（名稱、描述、數值、詞條）

---

### User Story 5 - 詞條系統運作 (Priority: P2)

裝備的主詞條數值會隨裝備等級提升而增加，副詞條依據詞條池與權重隨機生成，並可使用 Bitmask 快速查詢詞條組合。

**Why this priority**: 詞條系統是裝備差異化的核心機制，增加遊戲深度。

**Independent Test**: 可透過裝備升級與詞條查詢來驗證系統運作。

**Acceptance Scenarios**:

1. **Given** 一件 1 級裝備的主詞條為 HP +5%, **When** 升級到 5 級, **Then** 主詞條數值增加（如 HP +10%）
2. **Given** 詞條池定義了各詞條權重, **When** 生成大量副詞條樣本, **Then** 詞條分布應接近定義的權重比例
3. **Given** 裝備有暴擊與攻擊詞條（Bitmask = 0b0101）, **When** 查詢是否同時擁有暴擊和攻擊, **Then** 回傳 true
4. **Given** 裝備僅有暴擊詞條, **When** 查詢是否同時擁有暴擊和防禦, **Then** 回傳 false

---

### User Story 6 - 套裝效果觸發 (Priority: P3)

當玩家穿戴同一套裝的多件裝備時，系統自動計算並觸發對應的套裝效果（2 件套效果、4 件套效果）。

**Why this priority**: 套裝效果是進階遊戲機制，需要基礎裝備系統完成後才能實現。

**Independent Test**: 可透過穿戴不同數量的同套裝備來驗證套裝效果觸發。

**Acceptance Scenarios**:

1. **Given** 穿戴 2 件「昔日宗室之儀」套裝, **When** 計算套裝效果, **Then** 觸發 2 件套效果（元素爆發傷害 +20%）
2. **Given** 穿戴 4 件同套裝, **When** 計算套裝效果, **Then** 同時觸發 2 件套與 4 件套效果
3. **Given** 穿戴 2 件 A 套裝 + 2 件 B 套裝, **When** 計算套裝效果, **Then** 同時觸發 A 的 2 件套與 B 的 2 件套效果
4. **Given** 穿戴 3 件同套裝, **When** 計算套裝效果, **Then** 僅觸發 2 件套效果（未達 4 件套門檻）

---

### User Story 7 - 資料持久化 (Priority: P3)

系統支援從 JSON 載入物品模板與詞條池，以及物品實例的序列化/反序列化，以便儲存與讀取遊戲進度。

**Why this priority**: 資料持久化是遊戲存檔功能的基礎，但屬於輔助功能。

**Independent Test**: 可透過序列化物品、重新載入後比對資料完整性來驗證。

**Acceptance Scenarios**:

1. **Given** JSON 格式的物品模板檔案, **When** 系統載入模板, **Then** 成功建立可用的模板物件
2. **Given** 一個完整的物品實例, **When** 序列化為 JSON, **Then** 產生包含所有屬性的有效 JSON
3. **Given** 物品實例的 JSON 資料, **When** 反序列化, **Then** 還原的物品與原物品完全相同

---

### Edge Cases

- 當背包已滿且玩家卸下裝備時，系統應如何處理？（假設：拒絕卸下並提示背包已滿）
- 當裝備升級時副詞條是否增加？（依據文件：副詞條數量固定，僅主詞條數值成長）
- 當同時穿戴超過 4 件同套裝時，是否有額外效果？（依據文件：最高為 4 件套效果）
- 詞條生成時若權重為 0 的詞條是否會出現？（假設：權重 0 表示不會出現）
- UUID 衝突的處理？（假設：使用標準 UUID v4，衝突機率極低，不需特殊處理）

## Requirements *(mandatory)*

### Functional Requirements

**物品 ID 系統**
- **FR-001**: 系統 MUST 為每個物品實例生成唯一的 Instance ID（使用 UUID v4 格式）
- **FR-002**: 系統 MUST 支援 Template ID 來定義物品種類（格式如 `helmet_iron_001`）
- **FR-003**: 系統 MUST 允許從同一模板建立多個獨立實例

**物品模板**
- **FR-004**: 物品模板 MUST 包含以下必填欄位：templateId、name、description、slot、rarity、levelRequirement、baseStats、attributes
- **FR-005**: 物品模板 MAY 包含選填欄位：iconAsset、modelAsset、setId

**裝備欄位**
- **FR-006**: 系統 MUST 支援 5 個裝備欄位：helmet、body、gloves、boots、belt
- **FR-007**: 系統 MUST 驗證物品只能裝備到對應的欄位
- **FR-008**: 系統 MUST 驗證玩家等級符合裝備需求等級才能穿戴

**數值系統**
- **FR-009**: 系統 MUST 支援以下數值類型：attack、defense、maxHP、maxMP、critRate、critDamage、speed
- **FR-010**: 系統 MUST 使用公式計算最終數值：最終數值 = 角色基礎值 + 所有裝備數值總和
- **FR-011**: 系統 MUST 正確處理百分比加成（先加總固定值，再套用百分比）

**稀有度系統**
- **FR-012**: 系統 MUST 支援 5 種稀有度：common（0 詞條）、uncommon（1 詞條）、rare（2 詞條）、epic（3 詞條）、legendary（4 詞條）

**詞條系統**
- **FR-013**: 每件裝備 MUST 有一個主詞條，數值隨裝備等級提升
- **FR-014**: 副詞條數量 MUST 依據稀有度決定（參照 FR-012）
- **FR-015**: 副詞條 MUST 從詞條池依權重隨機生成
- **FR-016**: 系統 MUST 使用 Bitmask（OptionSet）實現詞條類型快速查詢
- **FR-017**: 系統 MUST 支援以下詞條類型：crit、energyRecharge、attack、defense、hp、elementalMastery、elementalDamage、healingBonus

**屬性系統**
- **FR-018**: 系統 MUST 支援數值加成型屬性（固定值或百分比）
- **FR-019**: 系統 MUST 支援元素附加型屬性（fire、ice、lightning、poison）
- **FR-020**: 系統 MUST 支援特殊效果型屬性（lifesteal、reflect、thorns）

**套裝系統**
- **FR-021**: 系統 MUST 支援套裝定義，包含 setId、name、pieces 清單、bonuses
- **FR-022**: 系統 MUST 在穿戴足夠件數時自動觸發套裝效果
- **FR-023**: 系統 MUST 支援 2 件套與 4 件套效果
- **FR-024**: 系統 MUST 支援套裝效果類型：stat_bonus、team_buff、conditional、elemental_reaction

**背包系統**
- **FR-025**: 系統 MUST 支援背包容量限制（預設 50 格）
- **FR-026**: 系統 MUST 在背包已滿時拒絕新增物品
- **FR-027**: 系統 MUST 支援物品的新增、移除、查詢操作

**資料持久化**
- **FR-028**: 系統 MUST 支援從 JSON 載入物品模板與詞條池
- **FR-029**: 系統 MUST 支援物品實例的序列化為 JSON
- **FR-030**: 系統 MUST 支援從 JSON 反序列化還原物品實例

### Key Entities

- **ItemTemplate（物品模板）**: 定義物品的種類與基本屬性，包含 templateId、name、description、slot、rarity、levelRequirement、baseStats、attributes
- **Item（物品實例）**: 實際存在的物品，包含 instanceId（UUID）、templateId、level、mainAffix、subAffixes、affixMask
- **Affix（詞條）**: 裝備上的屬性加成，包含 type、value、isPercentage
- **AffixType（詞條類型）**: 使用 Bitmask 表示的詞條分類，用於快速查詢
- **EquipmentSet（套裝）**: 套裝定義，包含 setId、name、pieces、bonuses
- **SetBonus（套裝效果）**: 套裝觸發的效果，包含 requiredPieces、effect、description
- **Stats（數值）**: 角色或裝備的能力數值集合
- **Avatar（角色）**: 玩家角色，包含基礎數值、裝備欄、背包
- **EquipmentSlots（裝備欄）**: 角色已穿戴的 5 個裝備位置
- **Inventory（背包）**: 未穿戴物品的儲存容器，有容量限制

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 系統可在單一操作內完成物品實例建立，玩家感受即時回應
- **SC-002**: 裝備穿戴/卸下操作即時反映在角色數值上，玩家可立即看到變化
- **SC-003**: 100% 的物品實例 ID 保證唯一，不會發生 ID 衝突
- **SC-004**: 詞條生成分布在統計上符合定義的權重比例（1000 次樣本誤差 < 5%）
- **SC-005**: Bitmask 詞條查詢可在常數時間內完成，支援快速篩選物品
- **SC-006**: 套裝效果在穿戴/卸下裝備後自動正確計算，無需手動觸發
- **SC-007**: 物品序列化後重新載入，100% 保持資料完整性
- **SC-008**: 背包操作（新增、移除、查詢）皆能即時完成，支援流暢的物品管理體驗

## Assumptions

1. **UUID 唯一性**: 使用標準 UUID v4 演算法，衝突機率極低（約 2^-122），不需額外的唯一性檢查機制
2. **背包容量**: 預設為 50 格，此數值可在未來調整但目前作為固定值
3. **數值計算順序**: 先加總所有固定值加成，再套用百分比加成
4. **主詞條成長**: 主詞條數值隨等級線性成長，成長公式為系統內部決定
5. **副詞條不變**: 副詞條在物品建立時隨機生成後固定，升級不會改變副詞條
6. **背包滿時卸下**: 當背包已滿時，無法卸下裝備（避免物品丟失）
7. **套裝件數上限**: 套裝效果最高支援 4 件套，超過 4 件不會有額外效果
8. **權重為 0**: 詞條池中權重為 0 的詞條不會被選中
