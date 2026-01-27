---
name: pages-testing
description: PAGEs 測試標準。MUST load when planning, designing, writing, reviewing, or debugging tests. Covers test naming, Given-When-Then structure, mocking, coverage requirements. 任何涉及測試規劃、撰寫、審查的任務都必須載入此 skill。
---

# PAGEs Testing Standards

```yaml
# ============================================
# Testing Standards Configuration
# ============================================
#
# 此檔案定義 CMProductionPAGE 專案的測試標準
# 所有 agents (ios-developer, ios-code-reviewer 等) 必須遵循此規範
#
# 版本: 1.0.0
# 最後更新: 2025-11-03
# ============================================

version: "1.0.0"
project: "CMProductionPAGE"

# ============================================
# 測試命名規範
# ============================================
test_naming:
  format: "testMethodNameWhenConditionThenExpectedResult"
  style: "camelCase"

  description: |
    測試方法命名必須清楚描述:
    1. 測試的方法名稱 (MethodName)
    2. 測試條件 (WhenCondition)
    3. 預期結果 (ThenExpectedResult)

  components:
    method_name:
      description: "被測試的方法或功能名稱"
      style: "UpperCamelCase for method name part"
      examples: ["Execute", "FetchData", "CalculateTotal"]

    condition:
      description: "測試的特定條件或情境"
      prefix: "When"
      examples: ["WhenValidSymbol", "WhenNetworkFails", "WhenDataIsEmpty"]

    expected_result:
      description: "預期的測試結果"
      prefix: "Then"
      examples: ["ThenReturnPrice", "ThenThrowError", "ThenReturnEmptyArray"]

  forbidden_styles:
    snake_case:
      reason: "Swift 使用 camelCase 命名規範"
      examples:
        - "test_execute_when_valid_symbol"  # FORBIDDEN

    chinese_characters:
      reason: "測試方法名稱必須使用英文"
      examples:
        - "testExecute有效符號"              # FORBIDDEN

    non_descriptive:
      reason: "測試名稱必須清楚描述測試意圖"
      examples:
        - "testGetPrice"                    # FORBIDDEN (不夠具體)
        - "test1"                           # FORBIDDEN

  examples:
    correct:
      - name: "testExecuteWhenValidSymbolThenReturnPrice"
        description: "測試 execute 方法在有效 symbol 時返回價格"
      - name: "testExecuteWhenInvalidSymbolThenThrowError"
        description: "測試 execute 方法在無效 symbol 時拋出錯誤"
      - name: "testFetchDataWhenNetworkFailsThenReturnCachedData"
        description: "測試 fetchData 在網路失敗時返回快取資料"

    incorrect:
      - name: "test_execute_when_valid_symbol"
        reason: "使用 snake_case"
      - name: "testExecute有效符號"
        reason: "包含中文字元"
      - name: "testGetPrice"
        reason: "未描述條件和預期結果"

# ============================================
# 測試結構規範
# ============================================
test_structure:
  pattern: "Given-When-Then"

  description: |
    所有測試必須遵循 Given-When-Then 結構:
    1. Given: 設定測試前置條件和上下文
    2. When: 執行被測試的行為
    3. Then: 驗證預期結果

  sections:
    given:
      description: "設定測試前置條件"
      format: "// Given: 中文簡短描述此階段的內容"
      responsibilities:
        - "建立測試所需的物件"
        - "設定 mock/stub 行為"
        - "準備測試資料"

    when:
      description: "執行被測試的行為"
      format: "// When: 中文簡短描述執行的操作"
      responsibilities:
        - "呼叫被測試的方法"
        - "觸發特定事件"

    then:
      description: "驗證預期結果"
      format: "// Then: 中文簡短描述驗證的內容"
      responsibilities:
        - "使用 XCTAssert 系列方法驗證結果"
        - "檢查方法呼叫次數"
        - "驗證狀態變化"

  complete_example: |
    // 測試當股票代碼有效時應成功返回股價
    func testExecuteWhenValidSymbolThenReturnPrice() {
        // Given: 建立 mock repository 並設定測試資料
        let mockRepository = MockStockRepository()
        mockRepository.stubbedPrice = 150.5
        let useCase = GetStockPriceUseCase(repository: mockRepository)
        let symbol = "2330"

        // When: 執行 use case 取得股價
        var receivedPrice: Double?
        let cancellable = useCase.execute(symbol: symbol)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { price in
                    receivedPrice = price
                }
            )

        // Then: 驗證返回的股價和呼叫次數
        XCTAssertEqual(receivedPrice, 150.5)
        XCTAssertEqual(mockRepository.getPriceCallCount, 1)
        XCTAssertEqual(mockRepository.lastQueriedSymbol, symbol)
    }

  comments:
    test_method_description:
      requirement: "SUGGESTED"
      format: "在測試方法上方使用 // 雙斜線註解"
      example: "// 測試當股票代碼有效時應成功返回股價"

    section_markers:
      requirement: "CRITICAL"
      format: "// Given: 中文描述, // When: 中文描述, // Then: 中文描述"
      examples:
        - "// Given: 建立 mock repository 並設定測試資料"
        - "// When: 執行 use case 取得股價"
        - "// Then: 驗證返回的股價和呼叫次數"

# ============================================
# 測試覆蓋率要求
# ============================================
test_coverage:
  required_for:
    usecases:
      pattern: "**/*UseCase*.swift"
      coverage_target: "80%+"
      rationale: "UseCases 包含核心業務邏輯"

    repositories:
      pattern: "**/*Repository*.swift"
      coverage_target: "80%+"

    viewmodels:
      pattern: "**/*ViewModel*.swift"
      coverage_target: "70%+"

    managers:
      pattern: "**/*Manager*.swift"
      coverage_target: "80%+"

  excluded_from_unit_tests:
    view_controllers:
      pattern: "**/*VC.swift"
      reason: "UI 層檔案"
      alternative: "使用 UI tests"

    view_components:
      pattern: "**/*ViewComponent*.swift"
      reason: "UI 層檔案"

    views:
      pattern: "**/*View.swift"
      reason: "純 UI 檔案"

# ============================================
# 測試工具和框架
# ============================================
testing_tools:
  unit_testing:
    framework: "XCTest"

  mocking:
    approach: "Protocol-based mocking"
    description: "使用 protocol 定義介面,建立 mock implementations"

    example: |
      // Protocol
      protocol StockRepository {
          func getPrice(for symbol: String) -> AnyPublisher<Double, Error>
      }

      // Mock implementation
      class MockStockRepository: StockRepository {
          var stubbedPrice: Double = 0
          var getPriceCallCount = 0
          var lastQueriedSymbol: String?

          func getPrice(for symbol: String) -> AnyPublisher<Double, Error> {
              getPriceCallCount += 1
              lastQueriedSymbol = symbol
              return Just(stubbedPrice)
                  .setFailureType(to: Error.self)
                  .eraseToAnyPublisher()
          }
      }

  combine_testing:
    approach: "使用 sink 訂閱並驗證結果"

# ============================================
# 測試命令
# ============================================
test_commands:
  run_all_tests:
    command: "xcodebuild test -workspace CMProductionLego.xcworkspace -scheme CMProductionLego -destination 'platform=iOS Simulator,name=iPhone 16 Pro'"

  run_with_coverage:
    command: "xcodebuild test -workspace CMProductionLego.xcworkspace -scheme CMProductionLego -enableCodeCoverage YES -destination 'platform=iOS Simulator,name=iPhone 16 Pro'"

  test_device:
    device: "iPhone 16 Pro"
    rationale: "使用統一的測試裝置確保一致性"

# ============================================
# 違規處理
# ============================================
violation_handling:
  critical:
    severity: "CRITICAL"
    action: "MUST be fixed before merge"
    examples:
      - "測試命名使用 snake_case"
      - "測試命名包含中文字元"
      - "UseCase/Repository/Manager 缺少單元測試"
      - "測試不遵循 Given-When-Then 結構"

  warning:
    severity: "WARNING"
    action: "SHOULD be improved"
    examples:
      - "測試命名不夠清楚描述意圖"
      - "測試覆蓋率低於目標"

  suggestion:
    severity: "SUGGESTION"
    examples:
      - "測試方法缺少中文說明註解"
      - "Given-When-Then 註解缺少中文描述"

# ============================================
# 最佳實踐
# ============================================
best_practices:
  naming:
    - "使用 testMethodNameWhenConditionThenExpectedResult 格式"
    - "使用 camelCase 命名"
    - "避免 snake_case 和中文字元"

  structure:
    - "遵循 Given-When-Then 結構"
    - "每個測試只驗證一個行為"
    - "保持測試簡潔明瞭"

  independence:
    - "測試之間必須獨立"
    - "不依賴測試執行順序"
    - "每個測試設定自己的前置條件"

  mocking:
    - "使用 protocol-based mocking"
    - "Mock 記錄呼叫次數和參數"
    - "Stub 返回可預測的測試資料"

  coverage:
    - "優先測試業務邏輯層 (UseCase, Manager)"
    - "測試錯誤處理路徑"
    - "測試邊界條件"
```
