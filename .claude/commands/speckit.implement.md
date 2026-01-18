---
description: Execute the implementation plan by processing and executing all tasks defined in tasks.md
version: "1.1.0"
updated: "2025-10-17"
constitution_compliance: "v1.2.0 Principle VIII"
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Outline

1. Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` from repo root and parse FEATURE_DIR and AVAILABLE_DOCS list. All paths must be absolute. For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Check checklists status** (if FEATURE_DIR/checklists/ exists):
   - Scan all checklist files in the checklists/ directory
   - For each checklist, count:
     * Total items: All lines matching `- [ ]` or `- [X]` or `- [x]`
     * Completed items: Lines matching `- [X]` or `- [x]`
     * Incomplete items: Lines matching `- [ ]`
   - Create a status table:
     ```
     | Checklist | Total | Completed | Incomplete | Status |
     |-----------|-------|-----------|------------|--------|
     | ux.md     | 12    | 12        | 0          | ✓ PASS |
     | test.md   | 8     | 5         | 3          | ✗ FAIL |
     | security.md | 6   | 6         | 0          | ✓ PASS |
     ```
   - Calculate overall status:
     * **PASS**: All checklists have 0 incomplete items
     * **FAIL**: One or more checklists have incomplete items
   
   - **If any checklist is incomplete**:
     * Display the table with incomplete item counts
     * **STOP** and ask: "Some checklists are incomplete. Do you want to proceed with implementation anyway? (yes/no)"
     * Wait for user response before continuing
     * If user says "no" or "wait" or "stop", halt execution
     * If user says "yes" or "proceed" or "continue", proceed to step 3
   
   - **If all checklists are complete**:
     * Display the table showing all checklists passed
     * Automatically proceed to step 3

3. Load and analyze the implementation context:
   - **REQUIRED**: Read tasks.md for the complete task list and execution plan
   - **REQUIRED**: Read plan.md for tech stack, architecture, and file structure
   - **IF EXISTS**: Read data-model.md for entities and relationships
   - **IF EXISTS**: Read contracts/ for API specifications and test requirements
   - **IF EXISTS**: Read research.md for technical decisions and constraints
   - **IF EXISTS**: Read quickstart.md for integration scenarios

4. **Project Setup Verification**:
   - **REQUIRED**: Create/verify ignore files based on actual project setup:
   
   **Detection & Creation Logic**:
   - Check if the following command succeeds to determine if the repository is a git repo (create/verify .gitignore if so):

     ```sh
     git rev-parse --git-dir 2>/dev/null
     ```
   - Check if Dockerfile* exists or Docker in plan.md → create/verify .dockerignore
   - Check if .eslintrc* or eslint.config.* exists → create/verify .eslintignore
   - Check if .prettierrc* exists → create/verify .prettierignore
   - Check if .npmrc or package.json exists → create/verify .npmignore (if publishing)
   - Check if terraform files (*.tf) exist → create/verify .terraformignore
   - Check if .helmignore needed (helm charts present) → create/verify .helmignore
   
   **If ignore file already exists**: Verify it contains essential patterns, append missing critical patterns only
   **If ignore file missing**: Create with full pattern set for detected technology
   
   **Common Patterns by Technology** (from plan.md tech stack):
   - **Node.js/JavaScript**: `node_modules/`, `dist/`, `build/`, `*.log`, `.env*`
   - **Python**: `__pycache__/`, `*.pyc`, `.venv/`, `venv/`, `dist/`, `*.egg-info/`
   - **Java**: `target/`, `*.class`, `*.jar`, `.gradle/`, `build/`
   - **C#/.NET**: `bin/`, `obj/`, `*.user`, `*.suo`, `packages/`
   - **Go**: `*.exe`, `*.test`, `vendor/`, `*.out`
   - **Ruby**: `.bundle/`, `log/`, `tmp/`, `*.gem`, `vendor/bundle/`
   - **PHP**: `vendor/`, `*.log`, `*.cache`, `*.env`
   - **Rust**: `target/`, `debug/`, `release/`, `*.rs.bk`, `*.rlib`, `*.prof*`, `.idea/`, `*.log`, `.env*`
   - **Kotlin**: `build/`, `out/`, `.gradle/`, `.idea/`, `*.class`, `*.jar`, `*.iml`, `*.log`, `.env*`
   - **C++**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.so`, `*.a`, `*.exe`, `*.dll`, `.idea/`, `*.log`, `.env*`
   - **C**: `build/`, `bin/`, `obj/`, `out/`, `*.o`, `*.a`, `*.so`, `*.exe`, `Makefile`, `config.log`, `.idea/`, `*.log`, `.env*`
   - **Universal**: `.DS_Store`, `Thumbs.db`, `*.tmp`, `*.swp`, `.vscode/`, `.idea/`
   
   **Tool-Specific Patterns**:
   - **Docker**: `node_modules/`, `.git/`, `Dockerfile*`, `.dockerignore`, `*.log*`, `.env*`, `coverage/`
   - **ESLint**: `node_modules/`, `dist/`, `build/`, `coverage/`, `*.min.js`
   - **Prettier**: `node_modules/`, `dist/`, `build/`, `coverage/`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
   - **Terraform**: `.terraform/`, `*.tfstate*`, `*.tfvars`, `.terraform.lock.hcl`

5. Parse tasks.md structure and extract:
   - **Task phases**: Setup, Tests, Core, Integration, Polish
   - **Task dependencies**: Sequential vs parallel execution rules
   - **Task details**: ID, description, file paths, parallel markers [P]
   - **Execution flow**: Order and dependency requirements

6. **Agent Delegation (MANDATORY per Constitution Principle VIII)**:

   **CRITICAL**: This command MUST delegate ALL implementation work to the ios-developer agent. Manual code modifications are FORBIDDEN.

   - **Use Task tool with mandatory parameters**:
     ```
     Task(
       subagent_type='ios-developer',
       description='Implement [feature-name] following tasks.md',
       prompt='Execute implementation of [feature] with the following context:

       **Task Plan**: [Summary from tasks.md - phases, dependencies, priorities]
       **Technical Stack**: [From plan.md - iOS version, Swift version, dependencies]
       **Architecture**: [From plan.md - PAGEs Framework layer structure]
       **Data Models**: [From data-model.md - entities, relationships, validation rules]
       **API Contracts**: [From contracts/ - endpoint definitions, request/response schemas]
       **Technical Decisions**: [From research.md - key decisions and rationales]

       **Agent Requirements**:
       1. Follow TDD workflow strictly:
          - Write tests FIRST for each task
          - Verify tests FAIL before implementation
          - Implement feature to make tests PASS
          - Refactor while keeping tests green

       2. Execute compliance checks after EVERY code change:
          - Run: cd CMProductionLego && xcodegen generate
          - Run: swiftlint lint
          - Run: plutil -lint CMProductionLego/CMProductionLego.xcodeproj/project.pbxproj
          - Verify: xcodebuild build -workspace CMProductionLego.xcworkspace -scheme CMProductionLego

       3. Maintain consistency with plan.md:
          - Follow exact layer structure (ViewModel → UseCase → Repository → DataSource)
          - Use specified naming conventions
          - Implement dependency injection as designed

       4. Report progress for each completed task:
          - Task ID and description
          - Test results (pass/fail counts)
          - Compliance check status
          - Mark task as [X] in tasks.md

       5. HALT on any compliance failure:
          - Report violation details
          - Do not proceed to next task
          - Await manual intervention

       Execute all tasks from tasks.md in dependency order, following phase structure.'
     )
     ```

   - **STOP immediately if**:
     - Agent delegation is skipped
     - Manual implementation is attempted
     - User tries to bypass ios-developer agent

   - **Report**: "Delegating to ios-developer agent per Constitution Principle VIII..."

7. **Agent Monitoring** (while ios-developer agent executes):
   - Monitor agent progress reports
   - Track task completion status
   - Collect compliance validation results
   - Note any errors or blockers reported by agent

8. **Post-Delegation Validation** (after ios-developer agent completes):
   - Verify all tasks in tasks.md are marked [X]
   - Review agent's compliance check reports
   - Confirm tests pass and coverage meets requirements
   - Validate implementation matches plan.md specifications

9. Implementation execution rules (NOTE: These are executed BY the ios-developer agent):
   - **Setup first**: Initialize project structure, dependencies, configuration
   - **Tests before code**: If you need to write tests for contracts, entities, and integration scenarios
   - **Core development**: Implement models, services, CLI commands, endpoints
   - **Integration work**: Database connections, middleware, logging, external services
   - **Polish and validation**: Unit tests, performance optimization, documentation

10. Progress tracking and error handling (executed BY the ios-developer agent):
   - Report progress after each completed task
   - Halt execution if any non-parallel task fails
   - For parallel tasks [P], continue with successful tasks, report failed ones
   - Provide clear error messages with context for debugging
   - Suggest next steps if implementation cannot proceed
   - **IMPORTANT** For completed tasks, make sure to mark the task off as [X] in the tasks file.

11. Completion validation (executed BY the ios-developer agent):
   - Verify all required tasks are completed
   - Check that implemented features match the original specification
   - Validate that tests pass and coverage meets requirements
   - Confirm the implementation follows the technical plan
   - Report final status with summary of completed work

Note: This command assumes a complete task breakdown exists in tasks.md. If tasks are incomplete or missing, suggest running `/tasks` first to regenerate the task list.
