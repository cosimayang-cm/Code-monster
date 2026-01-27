---
name: create-mr
description: 建立 GitLab Merge Request。支援 fix/feat/feat+fix 三種 template，可自動從 Jira 取得標題或依據修改內容生成 changelog。
user_invocable: true
usage: /create-mr <template> [--title "changelog標題"] [--jira "jira連結"]
arguments:
  template:
    required: true
    type: string
    enum: [fix, feat, feat+fix]
    description: MR template 類型
  title:
    required: false
    type: string
    description: Changelog 標題。未提供時會從 Jira 單取得，若無 Jira 則依修改內容生成
  jira:
    required: false
    type: string
    description: Jira 連結。未提供時 changelog 省略 Jira 連結並依修改內容總結標題
---

# Create GitLab MR Skill

建立 GitLab Merge Request 的自動化工具。

## 使用方式

```bash
# 基本使用（fix template，自動生成 changelog）
/create-mr fix

# 指定 Jira 連結（自動從 Jira 取得標題）
/create-mr fix --jira "https://cmoneyteam.atlassian.net/browse/AUTHOR-12345"

# 指定 changelog 標題
/create-mr feat --title "`元件名稱` 新增某某功能"

# 完整參數
/create-mr feat+fix --title "`元件名稱` 功能描述" --jira "https://cmoneyteam.atlassian.net/browse/AUTHOR-12345"
```

## Template 類型

| Template | 用途 | CHANGELOG 格式範例 |
|----------|------|-------------------|
| `fix` | 修復 Bug | `- 修正 \`元件名稱\` 問題描述 [Jira連結]` |
| `feat` | 新功能 | `- \`元件名稱\` 新增功能描述 [Jira連結]` |
| `feat+fix` | 功能 + 修復 | 包含 Feat 和 Fix 兩個區塊 |

## 執行流程

```yaml
workflow:
  step_1_parse_arguments:
    action: "解析使用者輸入的參數"
    extract:
      - template: "fix / feat / feat+fix"
      - title: "可選的 changelog 標題"
      - jira: "可選的 Jira 連結"

  step_2_determine_changelog_title:
    conditions:
      - if: "有提供 --title 參數"
        then: "直接使用提供的標題"
      - if: "有提供 --jira 參數但沒有 --title"
        then: "使用 Atlassian MCP 工具從 Jira 取得 issue 標題"
      - if: "兩者都沒有提供"
        then: "分析 git diff 和 commit 內容，總結修改項目作為標題"

  step_3_analyze_changes:
    action: "分析當前分支的變更內容"
    commands:
      - "git status"
      - "git diff $(git merge-base HEAD master)..HEAD --stat"
      - "git log $(git merge-base HEAD master)..HEAD --oneline"
    output: "變更摘要，用於填充 MR 描述"

  step_4_generate_mr_description:
    action: "根據 template 類型生成 MR 描述"
    templates:
      fix:
        sections:
          - "CHANGELOG"
          - "Issue（問題描述）"
          - "Root Cause（根本原因）"
          - "Solution（解決方案）"
      feat:
        sections:
          - "CHANGELOG"
          - "Requirement（需求）"
          - "Implementation（實作方式）"
      feat+fix:
        sections:
          - "Feat CHANGELOG"
          - "Requirement"
          - "Implementation"
          - "Fix CHANGELOG"
          - "Issue"
          - "Root Cause"
          - "Solution"

  step_5_create_mr:
    action: "使用 GitLab MCP 建立 MR"
    tool: "mcp__gitlab-mcp__create_merge_request"
    parameters:
      title: "從 changelog 標題生成"
      description: "步驟 4 生成的完整 MR 描述"
      source_branch: "當前分支"
      target_branch: "master"
      draft: false
```

## CHANGELOG 格式規範

```yaml
changelog_format:
  # 元件名稱用反引號包裹
  component_name: "`元件名稱`"

  # Jira 連結格式（選填，沒有則省略）
  jira_link:
    with_link: "[https://cmoneyteam.atlassian.net/browse/AUTHOR-XXXXX]"
    without_link: "省略不填"

  # Fix 範例
  fix_examples:
    - "- 修正 `Bar_Line_圖表` 閃退 [https://cmoneyteam.atlassian.net/browse/AUTHOR-14728]"
    - "- 修正 `Bar_Line_圖表` 閃退"  # 無 Jira 連結

  # Feat 範例
  feat_examples:
    - "- `單一圖片` 新增跳轉功能 [https://cmoneyteam.atlassian.net/browse/AUTHOR-14728]"
    - "- `單一圖片` 新增跳轉功能"  # 無 Jira 連結
```

## 無 Jira 連結時的標題生成規則

當沒有提供 Jira 連結且沒有指定 changelog 標題時：

```yaml
auto_title_generation:
  method: "分析 git diff 和 commit messages"

  for_fix:
    analyze:
      - "檢查修改的檔案名稱和路徑"
      - "識別修改涉及的元件/模組"
      - "從 commit message 提取問題描述"
    format: "修正 `{元件名稱}` {問題描述}"

  for_feat:
    analyze:
      - "檢查新增的檔案和功能"
      - "識別功能所屬的元件/模組"
      - "從 commit message 提取功能描述"
    format: "`{元件名稱}` 新增{功能描述}"
```

## 實際執行範例

### 範例 1：有 Jira 連結

```bash
/create-mr fix --jira "https://cmoneyteam.atlassian.net/browse/AUTHOR-14728"
```

執行結果：
1. 從 Jira API 取得 issue 標題：「Bar_Line_圖表元件閃退」
2. 生成 CHANGELOG：`- 修正 \`Bar_Line_圖表\` 閃退 [https://cmoneyteam.atlassian.net/browse/AUTHOR-14728]`
3. 分析 git diff 填充 Issue、Root Cause、Solution
4. 建立 MR

### 範例 2：無 Jira 連結

```bash
/create-mr fix
```

執行結果：
1. 執行 `git diff` 分析變更
2. 發現修改了 `StockPriceViewModel.swift`
3. 從 commit message 提取：「修正價格更新時 UI 未刷新問題」
4. 生成 CHANGELOG：`- 修正 \`股價元件\` 價格更新時 UI 未刷新`（無 Jira 連結則省略）
5. 建立 MR

## MR Title 命名規範

```yaml
mr_title_format:
  fix: "[Fix] {簡短問題描述}"
  feat: "[Feat] {簡短功能描述}"
  feat+fix: "[Feat+Fix] {主要變更描述}"

  examples:
    - "[Fix] 修正股價元件閃退問題"
    - "[Feat] 新增圖片跳轉功能"
    - "[Feat+Fix] 新增跳轉功能並修正閃退"
```

## 錯誤處理

```yaml
error_handling:
  no_changes:
    condition: "git status 顯示沒有變更"
    action: "提示使用者先 commit 變更"

  invalid_jira_link:
    condition: "Jira 連結格式錯誤或無法存取"
    action: "提示錯誤並詢問是否省略 Jira 連結"

  branch_not_from_master:
    condition: "當前分支不是從 master 分出"
    action: "警告並詢問目標分支"
```

## 相關工具

- `mcp__gitlab-mcp__create_merge_request`: 建立 MR
- `mcp__gitlab-mcp__get_merge_request`: 取得 MR 資訊
- Atlassian MCP: 取得 Jira issue 資訊
