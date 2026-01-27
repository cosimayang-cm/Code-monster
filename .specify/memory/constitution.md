# CMProductionPAGE Constitution

## 配置架構 (Configuration Architecture)

**此 constitution.md 是 speckit 命令的治理文件，核心規範請參閱以下來源**：

### Primary References
- **CLAUDE.md** - 專案概述、Agent 配置、快速參考
- **Skills** - 詳細規範（Single Source of Truth，由 Claude Code 自動載入）
  - `pages-architecture` - 架構規則、依賴注入、StateManager
  - `pages-code-quality` - weak self、Logger、XcodeGen
  - `pages-testing` - 測試命名、Given-When-Then

### Agent 執行
**所有開發請求必須透過 Agent 系統自動觸發**。
詳細的 Agent 配置、Keywords、執行順序請參閱 `CLAUDE.md agents section`。

### XcodeGen 工作流程
**所有檔案操作後必須執行 xcodegen generate**。
詳細命令請參閱 `CLAUDE.md commands.xcodegen` 或 `pages-code-quality` skill。

### Project Intelligence Scan Workflow

**MANDATORY for /speckit.plan command execution**

**Purpose**: Before planning implementation, understand existing project structure, reusable components, and architecture patterns to avoid duplication and ensure proper integration.

#### Scan Scope

**Documentation**:
- README.md - Project overview and architecture description
- CLAUDE.md - Development standards and practices
- CMProductionLego/project.yml - Project structure configuration
- Any docs/ or documentation directories

**Architecture Modules**:
```yaml
managers:        "Page/Application/Manager/"
datacenters:     "Page/Application/DataCenter/"
usecases:        "Page/Core/Domain/UseCases/"
repositories:    "Page/Core/Data/RepositoriesImpl/"
datasources:     "Page/Core/Data/DataSourcesImpl/"
mappers:         "Page/Core/Data/Mapper/"
viewcomponents:  "Page/ComponentCenter/Components/"
factories:       "Page/ComponentCenter/ComponentFactory/"
statemanager:    "Page/StateManager/"
```

**Blueprints & Examples**:
- DemoCMProductionLego/DefaultBlueprints/ - Existing feature implementations

**Dependencies**:
- Podfile - Third-party dependencies
- Pods/ (overview) - Installed packages

#### Scan Execution

**Method**: Use Task(subagent_type='Explore', thoroughness='very thorough')

**Agent Prompt Template**:
```
Scan the CMProductionLego project and generate an intelligent summary covering:

1. Existing Features Summary
   - Identify major feature areas by analyzing Managers, UseCases, and ViewComponents
   - Group related components by business domain

2. Reusable Components Analysis
   - List all Managers with their injected UseCases
   - List all UseCases with their Repository dependencies
   - List all Repositories with their DataSource dependencies
   - Identify which components can be reused for [NEW_FEATURE_DESCRIPTION]

3. Architecture Patterns
   - Document observed dependency injection patterns
   - Document StateManager usage patterns
   - Document ComponentFactory creation patterns

4. Integration Recommendations
   - Based on [NEW_FEATURE_DESCRIPTION], suggest:
     * Which existing components can be reused
     * Where new components should be created
     * How to integrate with existing architecture

Scan paths:
- Documentation: README.md, CLAUDE.md, project.yml
- All modules: Page/Application/, Page/Core/, Page/ComponentCenter/, Page/StateManager/
- Blueprints: DemoCMProductionLego/DefaultBlueprints/
```

#### Output Format

**Location**: `plan.md` - Add "Project Intelligence" section after "Summary"

**Required Sections**:

```markdown
## Project Intelligence

### Existing Features Summary

**[Feature Domain 1]**: [Brief description of implemented features]
- Manager: [Existing Manager name(s)]
- UseCases: [List of related UseCases]
- ViewComponents: [Related ViewComponents]
- Key Functionality: [What it does]

**[Feature Domain 2]**: ...

### Reusable Components Matrix

| Component Type | Name | Location | Purpose | Can Be Reused For |
|---------------|------|----------|---------|-------------------|
| Manager | XxxManager | Page/Application/Manager/XxxManagerImpl.swift | [Purpose] | [Suggested reuse scenarios] |
| UseCase | XxxUseCase | Page/Core/Domain/UseCases/XxxUseCaseImpl.swift | [Purpose] | [Suggested reuse scenarios] |
| Repository | XxxRepository | Page/Core/Data/RepositoriesImpl/XxxRepositoryImpl.swift | [Purpose] | [Suggested reuse scenarios] |
| DataSource | XxxDataSource | Page/Core/Data/DataSourcesImpl/XxxDataSourceImpl.swift | [Purpose] | [Suggested reuse scenarios] |

### Architecture Patterns Observed

**Dependency Injection Patterns**:
- [Pattern 1]: [Description with example]
- [Pattern 2]: [Description with example]

**StateManager Usage**:
- [How ViewComponents currently use StateManager]
- [Broadcast patterns observed]

**ComponentFactory Pattern**:
- [How ViewComponents are created]
- [Dependency injection flow]

**Naming Conventions**:
- Manager: [Observed pattern]
- UseCase: [Observed pattern]
- Repository: [Observed pattern]

### Integration Recommendations

**For [NEW_FEATURE_NAME]**:

**Reuse Existing Components**:
- [Component 1]: [Why and how to reuse]
- [Component 2]: [Why and how to reuse]

**Create New Components**:
- [New Component 1]: [Why needed, where to place]
- [New Component 2]: [Why needed, where to place]

**Integration Points**:
- [How new feature integrates with existing Manager layer]
- [How new feature integrates with existing StateManager]
- [How new feature uses existing Repositories/DataSources]

**Potential Conflicts**:
- [Any potential conflicts with existing architecture]
- [Suggested resolution approaches]
```

#### Execution Workflow

**Phase -1: Project Intelligence Scan** (Execute BEFORE Phase 0)

1. **Trigger Explore Agent**:
   ```
   Task(
     subagent_type="Explore",
     description="Scan project for intelligence",
     prompt="[Use Agent Prompt Template above with NEW_FEATURE_DESCRIPTION filled in]"
   )
   ```

2. **Process Agent Results**:
   - Parse agent output
   - Validate all required sections are present
   - Ensure Reusable Components Matrix is populated

3. **Write to plan.md**:
   - Insert "Project Intelligence" section after "Summary"
   - Format tables correctly
   - Include all analysis results

4. **Validation**:
   - MUST identify at least 3 reusable components OR
   - MUST justify why no reusable components exist
   - MUST provide integration recommendations

5. **Error Handling**:
   - If scan fails: STOP and report error
   - If insufficient data: Request manual review
   - If conflicts detected: Highlight in Integration Recommendations

**CRITICAL**: Phase 0 (Outline & Research) cannot begin until Project Intelligence section is complete and validated.

## Compliance & Quality Gates

### Mandatory Compliance Checks

**MUST perform after EVERY code change**:

1. **Architecture Compliance**:
   - Verify code follows PAGEs Framework architecture rules
   - Validate dependency injection rules are correctly implemented
   - Confirm naming conventions are consistently followed

2. **Layer Boundary Validation**:
   - UseCase MUST inject EITHER Repository OR UseCases (never both)
   - Repository MUST inject single DataSource only
   - DataSource directly interacts with external services
   - ViewModel MUST inject StateManager and provide methods for ViewComponent (v2.0)
   - ViewComponent MUST NOT directly inject StateManager (v2.0)

3. **Testing Standards**:
   - Test method names MUST follow testMethodNameWhenConditionThenExpectedResult
   - Test structure MUST use Given-When-Then pattern
   - NEVER use snake_case or Chinese naming

4. **Project Structure Verification**:
   - Run 'xcodegen generate' after adding/moving/deleting files
   - Ensure file paths match the sources configuration in project.yml
   - Verify generated .xcodeproj builds successfully
   - Ensure files are properly included in the correct build targets

5. **Auto-Correction Workflow**:
   - IMMEDIATELY fix any non-compliant code
   - Re-run full compliance checks after fixes
   - Continue until ALL checks pass

6. **Project Intelligence Scan Verification** (for /speckit.plan only):
   - Verify plan.md contains "Project Intelligence" section
   - Validate "Existing Features Summary" is populated with at least one feature domain
   - Validate "Reusable Components Matrix" contains at least 3 components OR justification for none
   - Validate "Architecture Patterns Observed" documents DI, StateManager, and ComponentFactory patterns
   - Validate "Integration Recommendations" provides specific guidance for the new feature
   - Ensure Phase -1 completed successfully before Phase 0 begins

7. **Task Generation Verification** (for /speckit.tasks only):
   - Verify tasks.md contains "Component Reuse Analysis" section (if Project Intelligence exists in plan.md)
   - Validate ALL component tasks are tagged with [REUSE] or [NEW]
   - Validate component tasks follow format: `- [ ] [TaskID] [P?] [Story?] [REUSE/NEW] Description with file path`
   - Validate Phase 2: Component Integration exists if reusable components found
   - Validate reusable components are wired BEFORE new components are created within each User Story phase
   - Validate "Task Count Optimization" summary is present with reduction metrics
   - Validate no duplicate component creation tasks (check for components marked [REUSE] that also have [NEW] creation tasks)
   - Ensure task count is optimized based on Project Intelligence recommendations

### Compliance Validation Commands

```bash
## Build and Test
cd CMProductionLego
pod install
xcodebuild build -workspace CMProductionLego.xcworkspace -scheme CMProductionLego
xcodebuild test -workspace CMProductionLego.xcworkspace -scheme CMProductionLego -enableCodeCoverage YES -destination 'platform=iOS Simulator,name=iPhone 16 Pro'

## Code Quality
swiftlint lint

## Project Structure
xcodebuild -list -project CMProductionLego/CMProductionLego.xcodeproj

## XcodeGen
cd CMProductionLego && xcodegen generate
cd CMProductionLego && xcodegen generate --use-cache
```

### Non-Compliance Consequences

**Architecture Violations**:
- Code MUST be redesigned and reimplemented
- Cannot proceed until compliance is achieved

**Dependency Injection Violations**:
- Code CANNOT be merged to main branch
- Requires complete refactoring

**Test Naming Violations**:
- Methods MUST be renamed to comply with standards
- Build will not be approved

**Project Structure Violations**:
- Errors may cause build failures
- MUST be fixed immediately before any other work

**Agent Execution Violations**:
- Manual work discarded
- Must restart with proper agent

**Project Intelligence Scan Violations** (for /speckit.plan):
- Cannot proceed to Phase 0 until scan is complete
- Missing "Project Intelligence" section: plan.md is incomplete and invalid
- Insufficient reusable components analysis: Must identify at least 3 OR justify why none exist
- Missing integration recommendations: Cannot proceed without clear integration guidance
- Scan failure: STOP execution and report error to user

**Task Generation Violations** (for /speckit.tasks):
- Missing Component Reuse Analysis: tasks.md is incomplete when Project Intelligence exists
- Component tasks without [REUSE]/[NEW] tags: Tasks are ambiguous and cannot be executed
- Duplicate component creation: Efficiency violation, wasting development time
- Missing Phase 2 Component Integration when reusable components exist: Poor architecture integration
- New components created before reusing existing ones: Violates optimization principles
- Task count not optimized: Unnecessary work, project delays
- All violations MUST be corrected before tasks.md can be used for implementation

## Governance

### Constitution Authority

**CLAUDE.md 是本專案唯一且最高權威的開發規範來源**。

所有 speckit 命令（/speckit.specify, /speckit.plan, /speckit.tasks, /speckit.implement）必須遵循此 Constitution 以及 CLAUDE.md 中定義的所有規則。

### Amendment Process

**修改 Constitution 的流程**:
1. 提案必須在 CLAUDE.md 中先更新
2. 需要文件化修改原因與影響範圍
3. 需要提供遷移計畫（如適用）
4. 所有相關 Agent 配置必須同步更新

### Enforcement

**All code reviews must verify compliance**:
- Architecture patterns
- Dependency injection rules
- Testing standards
- Agent execution protocols
- XcodeGen workflow adherence

**Any complexity must be justified**:
- Document architectural decisions
- Explain deviations from standards (with approval)
- Provide migration path for legacy code

### Living Document

此 Constitution 與 CLAUDE.md 同步演進。CLAUDE.md 的任何更新會自動成為此 Constitution 的一部分。

**Version**: 2.0.1 | **Ratified**: 2025-10-21 | **Last Amended**: 2025-11-19 | **Authority**: CLAUDE.md

## Version History

### v2.0.1 (2025-11-19)
**配置同步修正**：
- 修正 Agent 配置路徑引用（從 .claude/configs/ 改為 ai-pages-configs/）
- 統一 Agent 名稱（ios-bdd-developer → ios-developer）
- 同步 Keywords 清單與 CLAUDE.md（新增 project.yml, xcodegen, SwiftUI, UIKit, 單元測試）
- 統一 testing-standards.yaml test_method_description severity 為 SUGGESTED

### v2.0.0 (2025-11-03)
**重大架構變更**：
- StateManager 注入位置從 ViewComponent 改為 ViewModel
- ViewComponent 透過 ViewModel 方法存取 StateManager
- 新增 weak self pattern 規範: `[weak self] + guard let self else { return }` 且不使用 self 前綴
- 新增共用配置檔案系統 (ai-pages-configs/)
- 強制 XcodeGen 自動執行於所有檔案操作後
- 更新依賴注入規則以符合 v2.0 架構

**向後不相容變更**：
- ViewComponent 直接注入 StateManager 的模式已廢棄 (v1.0 deprecated)
- ViewModel 現在必須注入 StateManager (v2.0 required)

### v1.0.0 (2025-10-21)
- 初始版本
- StateManager 注入到 ViewComponent (已廢棄)
