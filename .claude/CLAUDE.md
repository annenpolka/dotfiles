# CLAUDE.md

## Execution Plans (ExecPlans)

Use the `execplan-manager` skill for creating, updating, and validating ExecPlans.
This skill is automatically triggered by keywords like:

- ExecPlan / execution plan creation/update
- PLANS.md specification
- Milestone management
- Prototyping

Detailed specifications and templates are included in the skill.

## Jev Crosscheck

読んで判断している主張（委譲先の報告と差分、文書と設定・実装、主張と引用、指示書の抜け、自分の結論）は、`jev-crosscheck` skill で意味論的assertionとして大量に検査する（2026-09-17の利用者指定）。決定論的な仕組み（テスト・型検査・lint・スキーマ検査・既存スクリプト）の結果の真偽は対象外。判定は注意を絞る補助で、テスト・実行・受入の代わりにしない。外部送信はプロジェクトの規則を優先する。
