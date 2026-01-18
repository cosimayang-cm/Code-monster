---
name: pages-code-quality
description: PAGEs 代碼品質規範。Use when writing closures with weak self, handling memory management, using Logger.log, or working with XcodeGen file operations.
---

# PAGEs Code Quality Rules

```yaml
# ============================================
# Code Quality Rules Configuration
# ============================================
#
# 此檔案定義 CMProductionPAGE 專案的代碼品質規範
# 所有 agents (ios-developer, ios-code-reviewer 等) 必須遵循此規範
#
# 版本: 1.0.0
# 最後更新: 2025-11-03
# ============================================

version: "1.0.0"
project: "CMProductionPAGE"

# ============================================
# 記憶體管理規範
# ============================================
memory_management:

  # Weak Self 規範
  weak_self:
    enforcement: "required"
    required: true
    severity: "critical"
    pattern: "[weak self]"
    unwrapping_method: "guard let self else { return }"

    description: |
      在閉包中使用 [weak self] 避免 retain cycle (CRITICAL)
      使用 guard let self else { return } 進行解包 (CRITICAL)

    after_guard_let:
      self_prefix_required: false
      enforcement: "recommended"
      severity: "suggestion"
      rule: "guard let self 後,在相同閉包內完全不使用 self. 前綴"

    examples:
      correct: |
        // ✅ 正確:使用 [weak self] 和 guard let self
        .sink { [weak self] data in
            guard let self else { return }
            updateUI(data)              // ✅ 不使用 self. 前綴
            processData(data)           // ✅ 不使用 self. 前綴
            viewModel.refresh()         // ✅ 不使用 self. 前綴
        }

      incorrect_self_prefix: |
        // ❌ 錯誤:guard let self 後仍使用 self. 前綴
        .sink { [weak self] data in
            guard let self else { return }
            self.updateUI(data)         // ❌ 不必要的 self 前綴
        }

      incorrect_no_weak_self: |
        // ❌ 錯誤:閉包中未使用 [weak self]
        .sink { data in
            self.updateUI(data)         // ❌ 可能造成 retain cycle
        }

      incorrect_optional_chaining: |
        // ❌ 錯誤:使用 optional chaining 代替 guard let
        .sink { [weak self] data in
            self?.updateUI(data)        // ❌ 應使用 guard let self
        }

    edge_cases:
      nested_closures: |
        // 巢狀閉包:內層閉包需要再次捕獲 weak self
        .sink { [weak self] data in
            guard let self else { return }
            processData(data)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let self else { return }
                updateUI(data)
            }
        }

      naming_conflict: |
        // 命名衝突時才使用 self 前綴
        let data = result.data  // 區域變數 data
        self.data = data        // ✅ 命名衝突時使用 self 區分

  # Delegate Weak Reference
  delegate_weak:
    required: true
    swiftlint_rule: "weak_delegate"
    severity: "error"
    description: "Delegate properties must be declared as weak"

    examples:
      correct: "weak var delegate: StockViewDelegate?"
      incorrect: "var delegate: StockViewDelegate?  // May cause retain cycle"

# ============================================
# Logging 規範
# ============================================
logging:
  required_method: "Logger.log()"
  forbidden_methods:
    - "print()"
    - "NSLog()"
    - "debugPrint()"

  rationale: |
    使用專案中的 Logger (基於 Apple OSLog) 提供統一的日誌介面:
    1. 基於 Apple 官方 OSLog,支援系統整合和效能優化
    2. 支援日誌等級控制
    3. 只在 DEBUG 模式下輸出
    4. 提供日誌分類 (normal, state, networking)

  language:
    required: "繁體中文 (Traditional Chinese)"
    enforcement: "suggested"
    rules:
      - "日誌訊息必須使用繁體中文"
      - "變數名稱、類別名稱保持英文"
      - "技術術語可保留英文 (如 API, WebSocket, JSON)"

  prefix_guidelines:
    bracket_prefix:
      format: "[前綴名稱]"
      examples:
        - "[股票管理] 正在獲取股票價格"
        - "[WebSocket] 連線已建立"

    emoji_prefix:
      format: "emoji [前綴名稱]"
      recommended_emojis:
        - "✅ - 成功/完成"
        - "⚠️ - 警告"
        - "❌ - 錯誤/失敗"
        - "📡 - 網路請求"
      examples:
        - "✅ [AppsFlyerManager] Identity 設定成功"
        - "⚠️ [API] 請求失敗: \\(error)"

  log_levels:
    types:
      - "OSLogType.debug: 開發調試資訊 (預設)"
      - "OSLogType.error: 錯誤訊息"
      - "OSLogType.fault: 嚴重錯誤"

    log_categories:
      - "Logger.normal: 一般日誌 (預設)"
      - "Logger.state: 狀態相關日誌"
      - "Logger.networking: 網路請求相關日誌"

  examples:
    correct_simple: |
      Logger.log("正在獲取股票價格: \\(symbol)")
      Logger.log("[股票管理] 使用者選擇股票: \\(stockName)")

    correct_with_log_type: |
      Logger.log(logType: .error, message: "⚠️ [API] 請求失敗: \\(error)")

    incorrect: |
      print("正在獲取股票價格")  // FORBIDDEN
      NSLog("某些訊息")          // FORBIDDEN

# ============================================
# 專案檔案管理
# ============================================
project_management:

  xcodegen:
    tool: "XcodeGen"
    config_file: "CMProductionLego/project.yml"

    single_source_of_truth:
      file: "project.yml"
      rule: "NEVER manually edit .xcodeproj or project.pbxproj files"

    file_operations_workflow:
      rule: "所有檔案操作後必須自動執行 xcodegen generate"

      after_add_file:
        steps:
          - "Add file to appropriate directory"
          - "Auto-execute: cd CMProductionLego && xcodegen generate"
          - "Verify: plutil -lint CMProductionLego/CMProductionLego.xcodeproj/project.pbxproj"
          - "Verify build succeeds"

      after_delete_file:
        steps:
          - "Delete file from sources directory"
          - "Auto-execute: cd CMProductionLego && xcodegen generate"
          - "Verify build succeeds"

      after_move_file:
        steps:
          - "Move file to new location"
          - "Auto-execute: cd CMProductionLego && xcodegen generate"
          - "Verify build succeeds"

    commands:
      generate: "cd CMProductionLego && xcodegen generate"
      validate: "plutil -lint CMProductionLego/CMProductionLego.xcodeproj/project.pbxproj"

    forbidden_operations:
      - "Manually edit .xcodeproj"
      - "Manually edit project.pbxproj"
      - "直接在 Xcode 中新增檔案"

# ============================================
# Swift 編碼規範
# ============================================
swift_coding_standards:

  naming:
    classes_structs_enums:
      style: "UpperCamelCase"
      examples: ["StockPriceViewModel", "UserProfileData"]

    functions_variables_constants:
      style: "lowerCamelCase"
      examples: ["fetchStockPrice()", "isLoading"]

    protocols:
      style: "UpperCamelCase"
      examples: ["StockRepository", "StockRepositoryProtocol"]

  swiftlint:
    config_file: "CMProductionLego/.swiftlint.yml"
    required_rules:
      - "weak_delegate"
      - "trailing_closure"
    usage:
      lint: "swiftlint lint"
      autocorrect: "swiftlint --fix"

# ============================================
# 錯誤處理
# ============================================
error_handling:
  async_operations:
    preferred: "Combine Publishers with error handling"
    example: |
      func fetchData() -> AnyPublisher<Data, Error> {
          return dataSource.fetch()
              .mapError { error in
                  Logger.log(logType: .error, message: "⚠️ [資料來源] 獲取資料失敗: \\(error)")
                  return AppError.networkError(error)
              }
              .eraseToAnyPublisher()
      }

  logging_errors:
    rule: "Always log errors before propagating or handling"

# ============================================
# 違規處理
# ============================================
violation_handling:
  critical:
    severity: "CRITICAL"
    action: "MUST be fixed immediately"
    examples:
      - "閉包中未使用 [weak self] 造成 retain cycle"
      - "使用 print() 代替 Logger.log()"
      - "檔案操作後未執行 xcodegen generate"
      - "手動編輯 .xcodeproj 或 project.pbxproj"

  warning:
    severity: "WARNING"
    action: "SHOULD be fixed for code quality"
    examples:
      - "guard let self 後使用不必要的 self 前綴"
      - "delegate 未宣告為 weak"
      - "缺少錯誤 logging"

# ============================================
# 最佳實踐
# ============================================
best_practices:
  memory_management:
    - "所有閉包都使用 [weak self]"
    - "使用 guard let self else { return } 進行解包"
    - "guard let self 後省略 self 前綴"
    - "Delegate properties 宣告為 weak"

  logging:
    - "統一使用 Logger.log()"
    - "適當設定 log level"
    - "重要操作和錯誤都要 log"

  project_management:
    - "檔案操作後自動執行 xcodegen generate"
    - "修改 project.yml 而非 .xcodeproj"
    - "確保 build 成功"
```
