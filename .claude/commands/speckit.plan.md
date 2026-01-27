---
description: Execute the implementation planning workflow using the plan template to generate design artifacts.
version: "1.1.0"
updated: "2025-10-17"
constitution_compliance: "v1.2.0 Principle VII"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. **Setup**: Run `.specify/scripts/bash/setup-plan.sh --json` from repo root and parse JSON for FEATURE_SPEC, IMPL_PLAN, SPECS_DIR, BRANCH. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Load context**:
   - Read FEATURE_SPEC and `.specify/memory/constitution.md`
   - Load IMPL_PLAN template (already copied)
   - **Load project compliance rules** (as required by constitution.md):
     - Skills 自動載入（pages-architecture, pages-code-quality, pages-testing）
     - `CLAUDE.md` (for project configuration summary)

3. **Execute plan workflow**: Follow the structure in IMPL_PLAN template to:
   - Fill Technical Context (mark unknowns as "NEEDS CLARIFICATION")
   - Fill Constitution Check section from constitution
   - Evaluate gates (ERROR if violations unjustified)
   - Phase 0: Generate research.md (resolve all NEEDS CLARIFICATION)
   - Phase 1: Generate data-model.md, contracts/, quickstart.md
   - Phase 1: Update agent context by running the agent script
   - Re-evaluate Constitution Check post-design

4. **Stop and report**: Command ends after Phase 2 planning. Report branch, IMPL_PLAN path, and generated artifacts.

## Phases

### Phase 0: Outline & Research

1. **Extract unknowns from Technical Context** above:
   - For each NEEDS CLARIFICATION → research task
   - For each dependency → best practices task
   - For each integration → patterns task

2. **Generate and dispatch research agents**:
   ```
   For each unknown in Technical Context:
     Task: "Research {unknown} for {feature context}"
   For each technology choice:
     Task: "Find best practices for {tech} in {domain}"
   ```

3. **Consolidate findings** in `research.md` using format:
   - Decision: [what was chosen]
   - Rationale: [why chosen]
   - Alternatives considered: [what else evaluated]

**Output**: research.md with all NEEDS CLARIFICATION resolved

### Phase 1: Design & Contracts

**Prerequisites:** `research.md` complete

1. **Extract entities from feature spec** → `data-model.md`:
   - Entity name, fields, relationships
   - Validation rules from requirements
   - State transitions if applicable

2. **Generate API contracts** from functional requirements:
   - For each user action → endpoint
   - Use standard REST/GraphQL patterns
   - Output OpenAPI/GraphQL schema to `/contracts/`

3. **Agent context update**:
   - Run `.specify/scripts/bash/update-agent-context.sh claude`
   - These scripts detect which AI agent is in use
   - Update the appropriate agent-specific context file
   - Add only new technology from current plan
   - Preserve manual additions between markers

4. **Compliance Verification** (Constitution Principle VII):

   **Verify Constitution Check section in plan.md**:
   - Section exists and is complete
   - All principles (I-VIII) are addressed
   - Gates and violations are documented

   **Verify Architecture Compliance**:
   - Reference: `pages-architecture` skill
   - Validate ALL code examples in plan.md comply with:
     - v2.0 dependency injection patterns (especially StateManager injection to ViewModel)
     - Layer boundary rules (UseCase/Manager/Repository/DataSource)
     - Naming conventions (protocols, implementations, view models)
     - Data flow architecture

   **Verify Code Quality Compliance**:
   - Reference: `pages-code-quality` skill
   - Validate ALL code examples in plan.md comply with:
     - Weak self patterns ([weak self] + guard let self)
     - Logger.log() usage (NEVER print/NSLog)
     - XcodeGen workflow requirements
     - Delegate property declarations

   **Verify Testing Standards Compliance**:
   - Reference: `pages-testing` skill
   - Validate ALL test examples in plan.md comply with:
     - Test naming conventions (camelCase, testMethodNameWhenConditionThenExpectedResult)
     - Test structure patterns (Given-When-Then with Chinese descriptions)
     - Test coverage requirements

   **Verify MR Review Readiness**:
   - Reference: `ai-pages-configs/mr-review-checks.yaml` (MR 專用檢查清單)
   - Document which checks will be validated during implementation

   **ERROR if**:
   - Constitution Check section missing or incomplete
   - ANY code example violates rules defined in yaml files
   - Test examples use snake_case or Chinese naming
   - No clear mapping to compliance rules
   - Unable to load or parse yaml compliance files

   **Output**: Compliance verification report in plan.md (append to Constitution Check section)

**Output**: data-model.md, /contracts/*, quickstart.md, agent-specific file, compliance report

### Phase 1.5: Compliance Examples Generation

**Prerequisites**: Phase 1 Design & Contracts complete, yaml compliance files loaded

**Purpose**: Generate concrete code examples by extracting patterns from yaml compliance files to ensure all examples in plan.md are compliant with project standards

1. **Extract Examples from YAML Files**:
   - Parse `architecture-rules.yaml` for correct/incorrect pattern examples
   - Parse `code-quality-rules.yaml` for weak self, logging, XcodeGen examples
   - Parse `testing-standards.yaml` for test structure examples
   - Identify example code blocks in yaml files (marked with ```swift)

2. **Generate Implementation Examples Section in plan.md**:
   - Create "Implementation Examples" section after "Constitution Check"
   - Extract and include examples for:
     - **ViewModel** (from architecture-rules.yaml StateManager v2.0 pattern examples)
     - **ViewComponent** (from architecture-rules.yaml ViewComponent pattern examples)
     - **UseCase** (from architecture-rules.yaml UseCase pattern examples)
     - **Manager** (from architecture-rules.yaml Manager pattern examples)
     - **Repository** (from architecture-rules.yaml Repository pattern examples)
     - **Weak Self Pattern** (from code-quality-rules.yaml weak self examples)
     - **Logger.log() Usage** (from code-quality-rules.yaml logging examples)
     - **Test Structure** (from testing-standards.yaml Given-When-Then examples)

3. **Add YAML Reference Comments**:
   - Each example MUST include comment: `# Reference: [yaml-file]:[section-name]:[line-range]`
   - Example format:
     ```swift
     // Reference: pages-architecture skill - StateManager v2.0 Pattern
     // ✅ v2.0 CORRECT: StateManager 注入到 ViewModel
     public class ExampleVM: CMViewModel {
         private let stateManager: StateManager
         ...
     }
     ```

4. **Validation**:
   - ALL examples MUST be extracted from yaml files (NOT manually written)
   - ALL examples MUST include reference comments pointing to source yaml
   - ALL examples MUST use v2.0 patterns (as defined in yaml files)
   - Examples MUST show both ✅ correct and ❌ incorrect patterns where applicable

**Output**: "Implementation Examples" section appended to plan.md with yaml-sourced examples

**CRITICAL**: All examples must be validated against yaml source before proceeding. If any example cannot be sourced from yaml files, ERROR and request yaml file update.

## Key rules

- Use absolute paths
- ERROR on gate failures or unresolved clarifications
