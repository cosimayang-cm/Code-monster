---
name: review-mr
description: 審查 GitLab Merge Request。執行完整的 PAGEs Framework 架構檢查，並在程式碼上發送 inline comments。
user_invocable: true
usage: /review-mr <mr_iid> [--no-inline]
arguments:
  mr_iid:
    required: true
    type: string
    description: Merge Request IID（例如 1932 或 !1932）
  no-inline:
    required: false
    type: boolean
    default: false
    description: 停用 inline comments，只發送總結報告
---

# Review MR Skill

審查 GitLab Merge Request 的自動化工具。執行 PAGEs Framework 架構合規檢查，並直接在程式碼差異上發送 inline comments。

## 使用方式

```bash
# 基本使用（包含 inline comments）
/review-mr 1932
/review-mr !1932

# 只發送總結報告（不發送 inline comments）
/review-mr 1932 --no-inline
```

## 功能特色

| 功能 | 說明 |
|------|------|
| 架構檢查 | 執行完整的 PAGEs Framework 合規檢查 |
| Inline Comments | 在 diff 上的具體行數發送違規說明 |
| 總結報告 | 發送完整的 review 報告到 MR |
| 重複審查偵測 | 自動更新已存在的 review comment |

## 執行流程

```yaml
workflow:
  step_1_parse_arguments:
    action: "解析 MR IID"
    examples:
      - input: "1932"
        result: { iid: "1932" }
      - input: "!1932"
        result: { iid: "1932" }
      - input: "1932 --no-inline"
        result: { iid: "1932", no_inline: true }

  step_2_launch_agent:
    action: "啟動 gitlab-mr-reviewer agent"
    tool: "Task(subagent_type='gitlab-mr-reviewer')"
    parameters:
      mr_iid: "解析後的 IID"
      post_inline_comments: "!no_inline"

  step_3_report_result:
    action: "回報審查結果摘要"
    includes:
      - "MR 標題和連結"
      - "發現的問題數量"
      - "Inline comments 數量"
      - "最終建議（APPROVE / REQUEST CHANGES）"
```

## Inline Comments 功能

當發現違規時，會在對應的程式碼行數上發送 comment：

```yaml
inline_comment_behavior:
  trigger: "每個 severity: critical 或 severity: warning 的違規"

  comment_format: |
    **[{CHECK_ID}]** {CHECK_NAME}

    {違規說明}

    **建議修正：**
    ```swift
    // 正確寫法
    {good_example}
    ```

  position_mapping:
    - "使用 MR diff 的 new_path / old_path"
    - "使用違規發生的行號"
    - "支援新增行（new_line）和刪除行（old_line）"

  grouping:
    - "同一檔案的多個違規會分開發送"
    - "避免單一 comment 過長"
```

## 範例輸出

執行 `/review-mr !1932` 後：

```
正在審查 MR !1932...

載入專案設定：CMProductionPAGE - PAGEs Framework
載入檢查項目：5 phases, 31 items

執行架構檢查...
  Phase 1: Architecture Compliance - 完成
  Phase 2: Code Quality - 完成
  Phase 3: Testing Standards - 完成
  Phase 4: Dependencies - 完成
  Phase 5: Maintainability - 完成

發現問題：
  - Critical: 2
  - Warnings: 3
  - Suggestions: 1

發送 Inline Comments...
  ✅ StockPriceVM.swift:42 - [ARCH-002] 依賴注入違規
  ✅ StockPriceVM.swift:78 - [QUAL-003] weak self 規範
  ✅ GetStockUseCase.swift:15 - [ARCH-001] 資料流違規
  ✅ ... (共 5 則 inline comments)

發送總結報告...
  ✅ 已更新 MR comment（第 2 次審查）

審查完成！
建議：❌ REQUEST CHANGES（有 2 個 Critical 問題需要修正）
```

## 相關設定

- 專案設定：`ai-pages-configs/project-config.yaml`
- 檢查項目：`ai-pages-configs/mr-review-checks.yaml`
- 報告模板：`.claude/templates/mr-review-report.md`

## 相關 Agent

此 Skill 使用 `gitlab-mr-reviewer` agent 執行實際的審查工作。
