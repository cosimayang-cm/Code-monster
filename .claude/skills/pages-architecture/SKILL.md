---
name: pages-architecture
description: PAGEs Framework Clean Architecture 架構規範。MUST load when planning, designing, implementing, reviewing, debugging, or troubleshooting ANY iOS feature or code issue. Covers ViewModels, UseCases, Managers, Repositories, data flow, dependency injection, StateManager, AddInfoInitializer. 任何涉及功能規劃、架構設計、代碼實作、問題排查的任務都必須載入此 skill。
triggers: ViewModel, UseCase, Manager, Repository, DataSource, 依賴注入, StateManager, AddInfoInitializer, CMAddInfo, CMHistoryStrategy, CMRealTimeStrategy, ApiConfig
---

# PAGEs Framework Architecture Rules

> **SSOT 提示**: 檔案結構規範、資料類型定義、Mapper 使用規範請參閱 `CLAUDE.md` 中的 `file_structure`、`data_types`、`mapper_usage` 區塊。

```yaml
# ============================================
# Architecture Rules Configuration
# ============================================
#
# 此檔案定義 CMProductionPAGE 專案的核心架構規則
# 所有 agents (ios-developer, ios-code-reviewer 等) 必須遵循此規範
#
# 版本: 1.1.0
# 最後更新: 2026-01-12
# ============================================

version: "1.1.0"
framework: "PAGEs Framework Clean Architecture"

# ============================================
# 資料流模式
# ============================================
data_flow:
  pattern: "ViewComponent <-> ViewModel -> UseCase/Manager -> Repository -> DataSource -> External APIs"

  description: |
    ViewComponent: UI 層,負責視圖呈現和使用者互動
    ViewModel: 業務邏輯層,連接 UI 和領域層
    UseCase: 單一領域業務邏輯封裝
    Manager: 跨領域業務邏輯協調
    Repository: 資料存取抽象層
    DataSource: 具體資料來源實作 (API, Database, SDK)

  forbidden_access:
    - "ViewModel 直接存取 Repository"
    - "ViewComponent 直接存取 UseCase"
    - "ViewModel 直接訂閱 StateManager"
    - "UseCase 直接存取 DataSource"
    - "Manager 直接存取 Repository"

# ============================================
# 依賴注入規則
# ============================================
dependency_injection:

  # ViewModel 層級
  viewmodel:
    must_inject:
      - "UseCase (單一領域邏輯)"
      - "Manager (跨領域協調)"
      - "StateManager (狀態管理) - 新增規則"

    injection_method: "Constructor-based dependency injection"

    statemanager_usage:
      pattern: "ViewModel 負責所有 StateManager 互動"
      responsibilities:
        - "代替 ViewComponent 進行 subscribe"
        - "代替 ViewComponent 進行 send"
        - "轉換 state 為 ViewComponent 可用的 data model"

      rationale: |
        StateManager 應注入到 ViewModel 而非 ViewComponent,原因:
        1. 保持 ViewComponent 輕量化,只關注 UI 呈現
        2. ViewModel 統一管理狀態邏輯,便於測試
        3. 避免 ViewComponent 直接耦合 StateManager

    forbidden:
      - "使用 PAGEs.shared.xxxManager (除了 router)"
      - "使用 StateManager.shared"
      - "直接存取 Repository"
      - "直接存取 DataSource"
      - "建立 Manager 實例"

    allowed_shared:
      - "PAGEs.shared.router (僅限導航)"

    examples:
      correct_single_domain: |
        // ✅ 單一領域邏輯 - 注入 UseCase
        public class SingleStockHeaderVM: CMViewModel {
            private let twStockCommodityUseCase: GetHeaderStockCommodityWithColumnsUseCase

            public init(parameter: SingleStockHeaderParameter,
                        twStockCommodityUseCase: GetHeaderStockCommodityWithColumnsUseCase) {
                self.twStockCommodityUseCase = twStockCommodityUseCase
            }
        }

      correct_cross_domain: |
        // ✅ 跨領域協調 - 注入 Manager
        public class ComplexStockVM: CMViewModel {
            private let stockDataManager: StockDataManager

            public init(parameter: ComplexStockParameter,
                        stockDataManager: StockDataManager) {
                self.stockDataManager = stockDataManager
            }
        }

      correct_with_statemanager: |
        # 👉 Quick Reference: 見 CLAUDE.md「v2.0 StateManager Pattern」
        #
        # 核心要點：
        # - ViewModel 注入 StateManager（非 ViewComponent）
        # - 使用 stateManager.subscribe() 訂閱狀態變化
        # - 使用 stateManager.send() 發送狀態更新
        # - 閉包中使用 [weak self] + guard let self

      incorrect_shared_access: |
        // ❌ 禁止使用 .shared
        func fetchData() {
            PAGEs.shared.stockManager.getData()  // FORBIDDEN
        }

    navigation_tools_policy:
      description: "導航工具的依賴注入和可見性規則"

      allowed_public_navigation_tools:
        - "router: PAGEsRouter?"
        - "mainTreeManager: MainTreeManager"

      rationale: |
        導航工具可以暴露為 public 的原因：
        1. 職責分離原則 - 導航是 ViewComponent/ViewController 的職責
        2. 避免 ViewModel 依賴 UIKit
        3. Clean Architecture 分層原則
        4. 可測試性

      forbidden:
        - description: "暴露業務邏輯 Manager 為 public"
        - description: "ViewModel 返回 UIViewController"
        - description: "ViewModel 執行導航邏輯"

  # ViewComponent 層級
  viewcomponent:
    must_inject:
      - "ViewModel (必需)"
      - "Style (必需)"
      - "ComponentModel (必需)"

    state_access_pattern: "透過 ViewModel 存取 StateManager (不直接注入)"

    allowed_shared:
      - "PAGEs.shared.router (僅限導航)"

    forbidden:
      - "直接注入 StateManager"
      - "使用 StateManager.shared"
      - "直接存取 UseCase"
      - "直接存取 Manager"
      - "使用 PAGEs.shared.xxxManager"
      - "保存業務狀態 (業務狀態應由 ViewModel 管理)"
      - "包含業務邏輯 (業務邏輯應放在 ViewModel)"

  # UseCase 層級
  usecase:
    must_inject: "EITHER single Repository OR multiple UseCases (never both)"
    method_signature:
      name: "execute"
      description: "所有 UseCase 必須使用 execute(...) 作為主要方法"
    state_requirement: "Stateless (無狀態)"

    forbidden:
      - "同時注入 Repository 和 UseCases"
      - "包含 instance variables (狀態)"
      - "直接存取 DataSource"
      - "使用 .shared"

  # Manager 層級
  manager:
    must_inject: "多個 UseCases"
    purpose: "協調跨領域業務邏輯"
    injection_method: "Constructor-based dependency injection"

    naming:
      protocol: "XxxManager"
      implementation: "XxxManagerImpl"

    forbidden:
      - "直接注入 Repository"
      - "直接注入 DataSource"
      - "使用 .shared 存取其他 Manager"

  # Factory 層級
  factory:
    must_inject: "無 (Factory 負責建立實例)"
    purpose: "建立 ViewComponent, ViewModel, UseCase 實例並組裝依賴關係"

    allowed_shared:
      - "PAGEs.shared.xxxManager (建立 ViewModel 時注入)"
      - "PAGEs.shared.stateManager (建立 ViewModel 時注入)"
      - "StateManager.shared (目前不在 PAGEs.shared 中,允許使用)"
      - "MainTreeManager.shared (目前不在 PAGEs.shared 中,允許使用)"

  # Repository 層級
  repository:
    must_inject: "單一 DataSource"
    async_return_type: "AnyPublisher<T, Error>"

    forbidden:
      - "注入多個 DataSources"
      - "直接存取外部 APIs"
      - "使用 .shared"

  # DataSource 層級
  datasource:
    injection: "無依賴注入,直接與外部服務互動"
    responsibility:
      - "直接與外部 APIs 互動"
      - "SDK 整合"
      - "網路請求"
      - "資料庫存取"

# ============================================
# 命名慣例
# ============================================
naming_conventions:
  protocols:
    format: "XxxProtocolName"
    examples: ["StockRepository", "StockDataSource", "StockManager"]

  implementations:
    format: "XxxProtocolNameImpl"
    examples: ["StockRepositoryImpl", "StockDataSourceImpl"]

  viewmodels:
    format: "XxxViewModel"
    examples: ["StockPriceViewModel", "PortfolioViewModel"]

  usecases:
    format: "VerbNounUseCase"
    method: "execute(...)"
    examples: ["GetStockPriceUseCase", "CalculatePortfolioValueUseCase"]

  managers:
    protocol_format: "XxxManager"
    implementation_format: "XxxManagerImpl"

# ============================================
# 層級邊界規則
# ============================================
layer_boundaries:
  presentation_layer:
    components: ["ViewComponent", "ViewModel"]
    rules:
      - "ViewComponent 只能存取 ViewModel"
      - "ViewModel 可以存取 UseCase, Manager, StateManager"
      - "禁止直接存取 Repository 或 DataSource"

  application_layer:
    components: ["Manager", "DataCenter"]
    rules:
      - "Manager 只能注入 UseCases"
      - "禁止 Manager 直接存取 Repository"

  domain_layer:
    components: ["UseCase", "VO (Value Object)"]
    rules:
      - "UseCase 可以注入 Repository 或其他 UseCases"
      - "UseCase 必須是無狀態的"

  data_layer:
    components: ["Repository", "DataSource", "DTO", "Mapper"]
    rules:
      - "Repository 只能注入 DataSource"
      - "DataSource 直接與外部服務互動"

# ============================================
# StateManager 廣播模式
# ============================================
state_management:
  pattern: "Broadcast pattern (廣播模式)"
  purpose: "跨 ViewComponent 狀態同步"
  access_pattern:
    new_rule: "透過 ViewModel 存取 (不直接注入到 ViewComponent)"

  methods:
    send:
      signature: "send(name: String, value: Any)"
      usage: "ViewModel 代替 ViewComponent 發布狀態"
    subscribe:
      signature: "subscribe(to: String, uuid: String, type: T.Type, handler: (T) -> Void)"
      usage: "ViewModel 代替 ViewComponent 訂閱狀態"

# ============================================
# AddInfoInitializer 架構規範
# ============================================
# AddInfoInitializer 是用於管理「附加資訊」初始化的模組
# 採用 Strategy Pattern 處理不同資料類型的即時/回補/快取策略
# ============================================

add_info_initializer:
  location: "Page/Core/Domain/Entities/AddInfoInitializer/"

  description: |
    AddInfoInitializer 模組負責初始化各種附加資訊的資料取得策略，
    包含即時資料、歷史回補、快取策略等。透過 Strategy Pattern
    讓新增資料類型時不需修改既有程式碼。

  # 核心 Protocol 定義
  core_protocols:
    AddInfoInitializer:
      inherits: "CMAddInfo (from CMWebSocketKit)"
      location: "Protocol/AddInfoInitializer.swift"
      purpose: "所有附加資訊初始化器的統一介面"
      required_properties:
        - "strategyKey: String - 策略識別鍵"
        - "realTimeStrategy: CMRealTimeStrategy? - 即時資料策略"
        - "historyStrategy: CMHistoryStrategy? - 回補資料策略"
        - "cacheStrategy: CMInfoDataCacheStrategy - 快取策略"

    AddInfoDataResultDTO:
      inherits: "CMInfoData (from CMWebSocketKit)"
      location: "Protocol/AddInfoDataResultDTO.swift"
      purpose: "附加資訊資料結果的統一介面"
      required_properties:
        - "target: String - 目標標的"

  # 目錄結構
  directory_structure:
    pattern: |
      AddInfoInitializer/
      ├── Protocol/                     # 核心協議定義
      │   ├── AddInfoInitializer.swift
      │   └── AddInfoDataResultDTO.swift
      ├── {DataType}/                   # 各資料類型目錄
      │   ├── ApiConfig/                # API 配置
      │   │   └── {Market}{DataType}ApiConfig.swift
      │   ├── {DataType}DTO/            # 資料傳輸物件
      │   │   ├── {DataType}DTO.swift   # Protocol
      │   │   └── {Market}{DataType}DTO.swift
      │   └── Strategy/                 # 策略實作
      │       ├── {DataType}HistoryStrategy.swift
      │       └── {DataType}RealTimeStrategy.swift
      └── {DataType}AddInfoInitializer.swift  # 主要實作

    existing_data_types:
      - "CalculationByTargets - 股票/期貨計算資料"
      - "CandlestickChart - K線圖資料"
      - "Commodity - 商品基本資料"
      - "CommoditySettlementPrice - 結算價資料"
      - "TickAverage - 均價資料"

  # 組件職責
  components:
    Initializer:
      naming: "{DataType}AddInfoInitializer"
      purpose: "組裝策略並提供統一入口"
      must_implement: "AddInfoInitializer protocol"
      example: |
        public struct CandlestickChartAddInfoInitializer<DTO: CandlesticksDTO>: AddInfoInitializer {
            public var strategyKey: String
            public var realTimeStrategy: CMRealTimeStrategy?
            public var historyStrategy: CMHistoryStrategy?
            public var cacheStrategy: CMInfoDataCacheStrategy

            public init(target: String,
                        minuteInterval: Int,
                        apiConfig: CMGetMultipleHistoryConfig,
                        market: String) {
                strategyKey = "TW\(apiConfig.dataType)_\(target)_\(minuteInterval)"
                historyStrategy = CandlestickChartHistoryStrategy<DTO>(...)
                cacheStrategy = CMInfoDataCacheStrategy(storage: .onlyMemory,
                                                        clear: .serverCommodityValidTimeByMarket(market: market))
            }
        }

    ApiConfig:
      naming: "{Market}{DataType}ApiConfig"
      purpose: "定義 API 請求的配置參數"
      must_implement: "CMGetTargetHistoryConfig 或 CMGetMultipleHistoryConfig"
      required_properties:
        - "dataType: String"
        - "columns: [String]"
        - "keyNamePath: [String]"
        - "json: String"
      example: |
        public struct TWStockCalculationHistoryApiConfig: CMGetTargetHistoryConfig {
            public var dataType: String = "StockCalculation"
            public var columns: [String] = ["標的", "即時成交價", ...]
            public var keyNamePath: [String] = ["Commodity", "CommKey"]
            public var json: String

            public init(targets: [String]) {
                let jsonString = targets.map { "\"\($0)\"" }.joined(separator: ",")
                self.json = "[\(jsonString)]"
            }
        }

    Strategy:
      naming: "{DataType}HistoryStrategy / {DataType}RealTimeStrategy"
      purpose: "實作資料取得和轉換邏輯"
      history_strategy:
        must_implement: "CMHistoryStrategy"
        required_methods:
          - "convertData(rowData:) -> [CMInfoData]"
          - "mergeData(originData:newData:) -> CMInfoData?"
      realtime_strategy:
        must_implement: "CMRealTimeStrategy"
      example: |
        public struct CalculationByTargetsHistoryStrategy<DTO: CalculationDataDTO>: CMHistoryStrategy {
            public var stepQueue: [CMHistoryStep] = [.api]
            public var apiMethod: CMHistoryApiMethod

            public func convertData(rowData: [[String]]) -> [CMInfoData] {
                return rowData.compactMap { DTO.init(columnNames: columnNames, rowData: $0) }
            }

            public func mergeData(originData: CMInfoData, newData: CMInfoData) -> CMInfoData? {
                guard let originData = originData as? DTO,
                      let newData = newData as? DTO else { return nil }
                return newData.sn > originData.sn ? newData : originData
            }
        }

    DataDTO:
      naming: "{DataType}DTO (Protocol) / {Market}{DataType}DTO (Implementation)"
      purpose: "定義資料結構"
      must_implement: "AddInfoDataResultDTO"
      common_properties:
        - "target: String"
        - "sn: Int (傳輸序號，用於 merge 判斷)"
        - "keyValueDic: [String: String]"

  # 新增資料類型流程
  adding_new_data_type:
    steps:
      - step: 1
        action: "建立 {DataType}DTO Protocol"
        location: "{DataType}/{DataType}DTO/{DataType}DTO.swift"
        note: "繼承 AddInfoDataResultDTO"
      - step: 2
        action: "建立各市場的 DTO 實作"
        location: "{DataType}/{DataType}DTO/{Market}{DataType}DTO.swift"
      - step: 3
        action: "建立 ApiConfig"
        location: "{DataType}/ApiConfig/{Market}{DataType}ApiConfig.swift"
      - step: 4
        action: "建立 Strategy"
        location: "{DataType}/Strategy/{DataType}HistoryStrategy.swift"
      - step: 5
        action: "建立 Initializer"
        location: "{DataType}AddInfoInitializer.swift 或 AddInfoByTargetsInitializer 泛型使用"

  # 禁止事項
  forbidden:
    - "在 Initializer 中直接實作資料轉換邏輯（應放在 Strategy）"
    - "在 Strategy 中硬編碼 API 配置（應使用 ApiConfig）"
    - "多個市場共用同一個 DTO 實作（各市場應有獨立 DTO）"
    - "跳過 Protocol 直接實作具體類型"

# ============================================
# 違規處理
# ============================================
violation_handling:
  critical:
    severity: "CRITICAL"
    action: "MUST be fixed immediately, code CANNOT be merged"
    examples:
      - "使用 .shared (除了 PAGEs.shared.router)"
      - "ViewModel 直接存取 Repository"
      - "ViewComponent 直接存取 UseCase"
      - "違反依賴注入規則"

  warning:
    severity: "WARNING"
    action: "SHOULD be refactored"
    examples:
      - "UseCase 包含狀態"
      - "命名不符合慣例"
```
