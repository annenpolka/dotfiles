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

## Codex Execution Plans (ExecPlans)

Use the `execplan-manager` skill for creating, updating, and validating ExecPlans.
This skill is automatically triggered by keywords like:
- ExecPlan / execution plan creation/update
- PLANS.md specification
- Milestone management
- Prototyping

Detailed specifications and templates are included in the skill.
