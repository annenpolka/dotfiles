# CLAUDE.md

## draftsnap

BEFORE ANYTHING ELSE: はじめに`draftsnap prompt`コマンドを実行し、指示を理解して作業や対話を記録してください。

## codex MCP

### What is Codex MCP

Codex MCPは、Claude Code内から別のCodexエージェントを起動できるMCPツールです。複雑なタスクや独立した作業を、専用のエージェントに委譲することで、メインセッションの文脈を保ちながら並行作業が可能になります。

### When to Use

以下の場合にcodex MCPを使用します:

- **大規模なコードレビュー**: read-only sandboxで安全に実行
- **独立した機能実装**: workspace-write sandboxで隔離して実装
- **プロトタイプ作成**: ExecPlanのprototyping milestoneで検証
- **並列タスク実行**: 複数のエージェントセッション（codex MCPやTask tool）を同時起動して効率化

### Basic Commands

**新規セッション開始**:

```bash
mcp__codex-mcp__codex with:
  prompt: "your task description"
  approval-policy: "never"
  sandbox: "workspace-write"
```

**セッション継続**:

```bash
mcp__codex-mcp__codex-reply with:
  conversationId: "<returned-conversation-id>"
  prompt: "next instruction"
```

### Session Management & Independence

**重要: セッション間の独立性**

- 各`mcp__codex-mcp__codex`呼び出しは**完全に新しい独立したセッション**を開始します
- 前のcodexセッションのコンテキスト、会話履歴、状態は**一切引き継がれません**
- セッションを継続するには必ず`mcp__codex-mcp__codex-reply`を使用し、`conversationId`を指定する必要があります
- 新規セッション開始時は、必要な全てのコンテキストをpromptに含める必要があります

**セッション継続の例**:

```bash
# 最初のセッション
mcp__codex-mcp__codex with:
  prompt: "Implement feature X in src/feature.rs"
  approval-policy: "never"
  sandbox: "workspace-write"
# → conversationId: "abc123" が返される

# 同じセッションに追加指示を送る
mcp__codex-mcp__codex-reply with:
  conversationId: "abc123"
  prompt: "Add error handling to the implementation"
# ✅ 前の実装を認識している

# 新しいセッションを開始（前のセッションとは無関係）
mcp__codex-mcp__codex with:
  prompt: "Review feature X"
  approval-policy: "never"
  sandbox: "read-only"
# ❌ 前のセッションの実装は知らない
```

### Parameters

#### approval-policy (重要)

**原則: `never`を使用してください（Claude Code側から承認操作できないため）**

- `never`: シェルコマンドを自動実行
- `untrusted`: 信頼できないコマンドのみ承認が必要
- `on-failure`: 失敗時のみ承認が必要
- `on-request`: リクエスト時に承認が必要

#### sandbox

- `read-only`: 読み取り専用（コードレビュー、調査に使用）
- `workspace-write`: ワークスペース内への書き込み可能（機能実装に使用）
- `danger-full-access`: フルアクセス（慎重に使用）

#### その他のオプション

- `cwd`: 作業ディレクトリを指定（相対パスはサーバープロセスのcwdから解決）
- `model`: モデルを指定（例: "o3", "o4-mini"）
- `profile`: config.tomlからプロファイルを指定
- `base-instructions`: デフォルト指示の代わりに使用する指示セット
- `include-plan-tool`: プランツールを含めるかどうか

### Usage Examples

#### パターン1: セキュリティレビュー

```bash
mcp__codex-mcp__codex with:
  prompt: "Review the authentication code in src/auth/ for security vulnerabilities. Focus on SQL injection, XSS, and authentication bypass risks."
  approval-policy: "never"
  sandbox: "read-only"
  cwd: "./backend"
```

#### パターン2: TDD実装

```bash
mcp__codex-mcp__codex with:
  prompt: "Implement user registration endpoint following TDD approach. Write failing tests first, then minimal implementation, then refactor."
  approval-policy: "never"
  sandbox: "workspace-write"
  cwd: "./backend"
```

#### パターン3: ExecPlan Prototyping Milestone

```bash
# ExecPlanのprototyping milestoneでライブラリの検証
mcp__codex-mcp__codex with:
  prompt: "Create a proof-of-concept for JWT validation using jsonwebtoken crate. Validate that it supports RS256 and can parse our token format. Save prototype in scratch/prototypes/jwt-poc/"
  approval-policy: "never"
  sandbox: "workspace-write"
  cwd: "./scratch"
```

#### パターン4: 並列タスク実行

```bash
# 複数の独立したタスクを並列実行
# Session 1: フロントエンド実装
mcp__codex-mcp__codex with:
  prompt: "Implement user profile page component"
  approval-policy: "never"
  sandbox: "workspace-write"
  cwd: "./frontend"

# Session 2: バックエンドAPI実装（並行して）
mcp__codex-mcp__codex with:
  prompt: "Implement GET /api/user/:id endpoint"
  approval-policy: "never"
  sandbox: "workspace-write"
  cwd: "./backend"
```

### Integration with ExecPlan/draftsnap

**ExecPlanとの統合**:

- Prototyping milestonesでライブラリや技術の検証（エージェント（codex MCPやTask tool）またはメインセッションで実装）
- 各milestoneをエージェント（codex MCPやTask tool）またはメインセッションで実装
- Decision Logに実装の結果や判断を記録

**draftsnapとの統合**:

- scratch/内での実験結果（エージェントまたはメインセッションでの実装）をdraftsnapで記録
- プロトタイプのイテレーションをsnapshotで管理
- 成功したプロトタイプを本実装に昇格する前に記録

### Rules

✅ **DO**:

- 原則としてapproval-policy: "never"を使用
- 独立した作業単位ごとにセッションを分ける
- 並列実行可能なタスクは複数セッションで同時実行
- ExecPlanのprototyping milestoneで積極的に活用

❌ **DON'T**:

- approval-policy: "danger-full-access"は避ける
- 長すぎるタスクを1セッションで完結させない
- メインセッションで十分なタスクをcodexに委譲しない

## TDD Approach

Follow t_wada's TDD practices with the Red-Green-Refactor cycle:

1. **Red**: Write a failing test first
2. **Green**: Write minimal code to make the test pass
3. **Refactor**: Improve code quality while keeping tests green

テスト駆動開発の定義は以下です。

1. 網羅したいテストシナリオのリスト（テストリスト）を書く
2. テストリストの中から「ひとつだけ」選び出し、実際に、具体的で、実行可能なテストコードに翻訳し、テストが失敗することを確認する
3.プロダクトコードを変更し、いま書いたテスト（と、それまでに書いたすべてのテスト）を成功させる（その過程で気づいたことはテストリストに追加する）
4. 必要に応じてリファクタリングを行い、実装の設計を改善する
5. テストリストが空になるまでステップ2に戻って繰り返す

## Codex Execution Plans (ExecPlans)

This document describes the requirements for an execution plan ("ExecPlan"), a design document that a coding agent can follow to deliver a working feature or system change. Treat the reader as a complete beginner to this repository: they have only the current working tree and the single ExecPlan file you provide. There is no memory of prior plans and no external context.

### How to use ExecPlans and PLANS.md

When authoring an executable specification (ExecPlan), follow PLANS.md _to the letter_. If it is not in your context, refresh your memory by reading the entire PLANS.md file. Be thorough in reading (and re-reading) source material to produce an accurate specification. When creating a spec, start from the skeleton and flesh it out as you do your research.

When implementing an executable specification (ExecPlan), do not prompt the user for "next steps"; simply proceed to the next milestone. Keep all sections up to date, add or split entries in the list at every stopping point to affirmatively state the progress made and next steps. Resolve ambiguities autonomously, and commit frequently.

When discussing an executable specification (ExecPlan), record decisions in a log in the spec for posterity; it should be unambiguously clear why any change to the specification was made. ExecPlans are living documents, and it should always be possible to restart from _only_ the ExecPlan and no other work.

When researching a design with challenging requirements or significant unknowns, use milestones to implement proof of concepts, "toy implementations", etc., that allow validating whether the user's proposal is feasible. Read the source code of libraries by finding or acquiring them, research deeply, and include prototypes to guide a fuller implementation.

### Requirements

NON-NEGOTIABLE REQUIREMENTS:

- Every ExecPlan must be fully self-contained. Self-contained means that in its current form it contains all knowledge and instructions needed for a novice to succeed.
- Every ExecPlan is a living document. Contributors are required to revise it as progress is made, as discoveries occur, and as design decisions are finalized. Each revision must remain fully self-contained.
- Every ExecPlan must enable a complete novice to implement the feature end-to-end without prior knowledge of this repo.
- Every ExecPlan must produce a demonstrably working behavior, not merely code changes to "meet a definition".
- Every ExecPlan must define every term of art in plain language or do not use it.

Purpose and intent come first. Begin by explaining, in a few sentences, why the work matters from a user's perspective: what someone can do after this change that they could not do before, and how to see it working. Then guide the reader through the exact steps to achieve that outcome, including what to edit, what to run, and what they should observe.

The agent executing your plan can list files, read files, search, run the project, and run tests. It does not know any prior context and cannot infer what you meant from earlier milestones. Repeat any assumption you rely on. Do not point to external blogs or docs; if knowledge is required, embed it in the plan itself in your own words. If an ExecPlan builds upon a prior ExecPlan and that file is checked in, incorporate it by reference. If it is not, you must include all relevant context from that plan.

### Formatting

本ガイドに従って作成・更新されるすべての ExecPlan と、その実装・運用・議論に関する文章は 日本語 で記述すること。平易な日本語を用い、専門用語は初出時に必ず定義すること（英語の用語が必要な場合は、和訳＋英語原語を併記してよい）。

Format and envelope are simple and strict. Each ExecPlan must be one single fenced code block labeled as `md` that begins and ends with triple backticks. Do not nest additional triple-backtick code fences inside; when you need to show commands, transcripts, diffs, or code, present them as indented blocks within that single fence. Use indentation for clarity rather than code fences inside an ExecPlan to avoid prematurely closing the ExecPlan's code fence. Use two newlines after every heading, use # and ## and so on, and correct syntax for ordered and unordered lists.

When writing an ExecPlan to a Markdown (.md) file where the content of the file _is only_ the single ExecPlan, you should omit the triple backticks.

Write in plain prose. Prefer sentences over lists. Avoid checklists, tables, and long enumerations unless brevity would obscure meaning. Checklists are permitted only in the `Progress` section, where they are mandatory. Narrative sections must remain prose-first.

### Guidelines

Self-containment and plain language are paramount. If you introduce a phrase that is not ordinary English ("daemon", "middleware", "RPC gateway", "filter graph"), define it immediately and remind the reader how it manifests in this repository (for example, by naming the files or commands where it appears). Do not say "as defined previously" or "according to the architecture doc." Include the needed explanation here, even if you repeat yourself.

Avoid common failure modes. Do not rely on undefined jargon. Do not describe "the letter of a feature" so narrowly that the resulting code compiles but does nothing meaningful. Do not outsource key decisions to the reader. When ambiguity exists, resolve it in the plan itself and explain why you chose that path. Err on the side of over-explaining user-visible effects and under-specifying incidental implementation details.

Anchor the plan with observable outcomes. State what the user can do after implementation, the commands to run, and the outputs they should see. Acceptance should be phrased as behavior a human can verify ("after starting the server, navigating to [http://localhost:8080/health](http://localhost:8080/health) returns HTTP 200 with body OK") rather than internal attributes ("added a HealthCheck struct"). If a change is internal, explain how its impact can still be demonstrated (for example, by running tests that fail before and pass after, and by showing a scenario that uses the new behavior).

Specify repository context explicitly. Name files with full repository-relative paths, name functions and modules precisely, and describe where new files should be created. If touching multiple areas, include a short orientation paragraph that explains how those parts fit together so a novice can navigate confidently. When running commands, show the working directory and exact command line. When outcomes depend on environment, state the assumptions and provide alternatives when reasonable.

Be idempotent and safe. Write the steps so they can be run multiple times without causing damage or drift. If a step can fail halfway, include how to retry or adapt. If a migration or destructive operation is necessary, spell out backups or safe fallbacks. Prefer additive, testable changes that can be validated as you go.

Validation is not optional. Include instructions to run tests, to start the system if applicable, and to observe it doing something useful. Describe comprehensive testing for any new features or capabilities. Include expected outputs and error messages so a novice can tell success from failure. Where possible, show how to prove that the change is effective beyond compilation (for example, through a small end-to-end scenario, a CLI invocation, or an HTTP request/response transcript). State the exact test commands appropriate to the project’s toolchain and how to interpret their results.

Capture evidence. When your steps produce terminal output, short diffs, or logs, include them inside the single fenced block as indented examples. Keep them concise and focused on what proves success. If you need to include a patch, prefer file-scoped diffs or small excerpts that a reader can recreate by following your instructions rather than pasting large blobs.

### Milestones

Milestones are narrative, not bureaucracy. If you break the work into milestones, introduce each with a brief paragraph that describes the scope, what will exist at the end of the milestone that did not exist before, the commands to run, and the acceptance you expect to observe. Keep it readable as a story: goal, work, result, proof. Progress and milestones are distinct: milestones tell the story, progress tracks granular work. Both must exist. Never abbreviate a milestone merely for the sake of brevity, do not leave out details that could be crucial to a future implementation.

Each milestone must be independently verifiable and incrementally implement the overall goal of the execution plan.

### Living plans and design decisions

- ExecPlans are living documents. As you make key design decisions, update the plan to record both the decision and the thinking behind it. Record all decisions in the `Decision Log` section.
- ExecPlans must contain and maintain a `Progress` section, a `Surprises & Discoveries` section, a `Decision Log`, and an `Outcomes & Retrospective` section. These are not optional.
- When you discover optimizer behavior, performance tradeoffs, unexpected bugs, or inverse/unapply semantics that shaped your approach, capture those observations in the `Surprises & Discoveries` section with short evidence snippets (test output is ideal).
- If you change course mid-implementation, document why in the `Decision Log` and reflect the implications in `Progress`. Plans are guides for the next contributor as much as checklists for you.
- At completion of a major task or the full plan, write an `Outcomes & Retrospective` entry summarizing what was achieved, what remains, and lessons learned.

### Prototyping milestones and parallel implementations

It is acceptable—-and often encouraged—-to include explicit prototyping milestones when they de-risk a larger change. Examples: adding a low-level operator to a dependency to validate feasibility, or exploring two composition orders while measuring optimizer effects. Keep prototypes additive and testable. Clearly label the scope as “prototyping”; describe how to run and observe results; and state the criteria for promoting or discarding the prototype.

Prefer additive code changes followed by subtractions that keep tests passing. Parallel implementations (e.g., keeping an adapter alongside an older path during migration) are fine when they reduce risk or enable tests to continue passing during a large migration. Describe how to validate both paths and how to retire one safely with tests. When working with multiple new libraries or feature areas, consider creating spikes that evaluate the feasibility of these features _independently_ of one another, proving that the external library performs as expected and implements the features we need in isolation.

### Skeleton of a Good ExecPlan

```md
# <Short, action-oriented description>

This ExecPlan is a living document. The sections `Progress`, `Surprises & Discoveries`, `Decision Log`, and `Outcomes & Retrospective` must be kept up to date as work proceeds.

If PLANS.md file is checked into the repo, reference the path to that file here from the repository root and note that this document must be maintained in accordance with PLANS.md.

## Purpose / Big Picture

Explain in a few sentences what someone gains after this change and how they can see it working. State the user-visible behavior you will enable.

## Progress

Use a list with checkboxes to summarize granular steps. Every stopping point must be documented here, even if it requires splitting a partially completed task into two (“done” vs. “remaining”). This section must always reflect the actual current state of the work.

- [x] (2025-10-01 13:00Z) Example completed step.
- [ ] Example incomplete step.
- [ ] Example partially completed step (completed: X; remaining: Y).

Use timestamps to measure rates of progress.

## Surprises & Discoveries

Document unexpected behaviors, bugs, optimizations, or insights discovered during implementation. Provide concise evidence.

- Observation: …
  Evidence: …

## Decision Log

Record every decision made while working on the plan in the format:

- Decision: …
  Rationale: …
  Date/Author: …

## Outcomes & Retrospective

Summarize outcomes, gaps, and lessons learned at major milestones or at completion. Compare the result against the original purpose.

## Context and Orientation

Describe the current state relevant to this task as if the reader knows nothing. Name the key files and modules by full path. Define any non-obvious term you will use. Do not refer to prior plans.

## Plan of Work

Describe, in prose, the sequence of edits and additions. For each edit, name the file and location (function, module) and what to insert or change. Keep it concrete and minimal.

## Concrete Steps

State the exact commands to run and where to run them (working directory). When a command generates output, show a short expected transcript so the reader can compare. This section must be updated as work proceeds.

## Validation and Acceptance

Describe how to start or exercise the system and what to observe. Phrase acceptance as behavior, with specific inputs and outputs. If tests are involved, say "run <project’s test command> and expect <N> passed; the new test <name> fails before the change and passes after>".

## Idempotence and Recovery

If steps can be repeated safely, say so. If a step is risky, provide a safe retry or rollback path. Keep the environment clean after completion.

## Artifacts and Notes

Include the most important transcripts, diffs, or snippets as indented examples. Keep them concise and focused on what proves success.

## Interfaces and Dependencies

Be prescriptive. Name the libraries, modules, and services to use and why. Specify the types, traits/interfaces, and function signatures that must exist at the end of the milestone. Prefer stable names and paths such as `crate::module::function` or `package.submodule.Interface`. E.g.:

In crates/foo/planner.rs, define:

    pub trait Planner {
        fn plan(&self, observed: &Observed) -> Vec<Action>;
    }
```

If you follow the guidance above, a single, stateless agent -- or a human novice -- can read your ExecPlan from top to bottom and produce a working, observable result. That is the bar: SELF-CONTAINED, SELF-SUFFICIENT, NOVICE-GUIDING, OUTCOME-FOCUSED.

When you revise a plan, you must ensure your changes are comprehensively reflected across all sections, including the living document sections, and you must write a note at the bottom of the plan describing the change and the reason why. ExecPlans must describe not just the what but the why for almost everything.

## Issue Tracking with bd (beads)

**IMPORTANT**: Projects may use **bd (beads)** for issue tracking. Do NOT use markdown TODOs, task lists, or other tracking methods in projects that have beads configured.

**NOTE**: Beadsは**完全ローカルモード**で使用されます。`.beads/`ディレクトリはgitignoreされており、コミット対象外です。

### Why bd?

- Dependency-aware: Track blockers and relationships between issues
- Local-first: ローカルで動作し、gitには影響しません
- Agent-optimized: JSON output, ready work detection, discovered-from links
- Prevents duplicate tracking systems and confusion

### Quick Start

**Check for ready work:**
```bash
bd ready --json
```

**Create new issues:**
```bash
bd create "Issue title" -t bug|feature|task -p 0-4 --json
bd create "Issue title" -p 1 --deps discovered-from:bd-123 --json
```

**Claim and update:**
```bash
bd update bd-42 --status in_progress --json
bd update bd-42 --priority 1 --json
```

**Complete work:**
```bash
bd close bd-42 --reason "Completed" --json
```

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

### Priorities

- `0` - Critical (security, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Workflow for AI Agents

1. **Check ready work**: `bd ready` shows unblocked issues
2. **Claim your task**: `bd update <id> --status in_progress`
3. **Work on it**: Implement, test, document
4. **Discover new work?** Create linked issue:
   - `bd create "Found bug" -p 1 --deps discovered-from:<parent-id>`
5. **Complete**: `bd close <id> --reason "Done"`

### Local-Only Operation

Beadsは完全にローカルで動作します：

- `.beads/`ディレクトリはgitignoreされています
- コミット時に`.beads/issues.jsonl`を含める必要はありません
- git操作は通常通り行えます（beadsは影響しません）
- データはこのマシンでのみ保持されます

### Initial Setup (for Agents)

Beadsがまだ初期化されていない場合:

```bash
# 1. Initialize beads
bd init --skip-merge-driver --quiet

# 2. Add to .git/info/exclude
echo ".beads/" >> .git/info/exclude

# 3. Verify .beads/ is ignored
git status | grep -q ".beads" && echo "WARNING: .beads/ is tracked!" || echo "OK: .beads/ is ignored"
```

### Important Rules

- ✅ Use bd for ALL task tracking (if project has .beads/ directory)
- ✅ Always use `--json` flag for programmatic use
- ✅ Link discovered work with `discovered-from` dependencies
- ✅ Check `bd ready` before asking "what should I work on?"
- ✅ Remember: `.beads/` is local-only, not committed to git
- ❌ Do NOT create markdown TODO lists in projects with beads
- ❌ Do NOT use external issue trackers in projects with beads
- ❌ Do NOT duplicate tracking systems
- ❌ Do NOT try to commit `.beads/` files to git

### Limitations of Local-Only Mode

- ❌ Data is not synced across machines
- ❌ Cannot share issues with team members
- ❌ Data will be lost if machine is changed (manual backup required)
- ✅ However, projects are designed for single-machine, single-agent use

### Troubleshooting

If `.beads/` accidentally gets added to git:

```bash
git rm -r --cached .beads/
echo ".beads/" >> .git/info/exclude
git status
```

