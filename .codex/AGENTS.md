# AGENTS.md

IMPORTANT: Do not write overly defensive code. Always prefer simplicity over pathological complexity.

## commit message policy

コミットメッセージには必ず以下のように、Codexによって生成されたことを示す署名を含めてください。

```
Generated with Codex
Co-authored-by: Codex
```

## draftsnap

BEFORE ANYTHING ELSE: セッションのはじめに`draftsnap prompt`コマンドを実行し、指示を理解して作業や対話を記録してください。

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

## Continuity Ledger (compaction-safe)

Maintain a single Continuity Ledger for this workspace in `scratch/CONTINUITY.md`. The ledger is the canonical session briefing designed to survive context compaction; do not rely on earlier chat text unless it’s reflected in the ledger.

### How it works

- At the start of every assistant turn: read `CONTINUITY.md`, update it to reflect the latest goal/constraints/decisions/state, then proceed with the work.
- Update `CONTINUITY.md` again whenever any of these change: goal, constraints/assumptions, key decisions, progress state (Done/Now/Next), or important tool outcomes.
- Keep it short and stable: facts only, no transcripts. Prefer bullets. Mark uncertainty as `UNCONFIRMED` (never guess).
- If you notice missing recall or a compaction/summary event: refresh/rebuild the ledger from visible context, mark gaps `UNCONFIRMED`, ask up to 1–3 targeted questions, then continue.

### `functions.update_plan` vs the Ledger

- `functions.update_plan` is for short-term execution scaffolding while you work (a small 3–7 step plan with pending/in_progress/completed).
- `CONTINUITY.md` is for long-running continuity across compaction (the “what/why/current state”), not a step-by-step task list.
- Keep them consistent: when the plan or state changes, update the ledger at the intent/progress level (not every micro-step).

### In replies

- Begin with a brief “Ledger Snapshot” (Goal + Now/Next + Open Questions). Print the full ledger only when it materially changes or when the user asks.

### `CONTINUITY.md` format (keep headings)

- Goal (incl. success criteria):
- Constraints/Assumptions:
- Key decisions:
- State:
- Done:
- Now:
- Next:
- Open questions (UNCONFIRMED if needed):
- Working set (files/ids/commands):
