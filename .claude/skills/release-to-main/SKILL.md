---
name: release-to-main
description: |
  mainブランチからリリースブランチを作成し、devをマージしてmainにPRを出すスキル。
  コンフリクトが発生した場合は全てdev側（theirs）を優先してマージする。
  Use when: (1) User says "release", "リリース", "mainにPR",
  (2) User wants to merge dev into main with a release branch.
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git fetch:*), Bash(git pull:*), Bash(git checkout:*), Bash(git merge:*), Bash(git push:*), Bash(gh pr create:*)
---

# Release to Main

mainブランチからリリースブランチを作成し、devをマージしてmainブランチへのPRを作成するワークフロー。

## Overview

```
main → release/YYYY-MM-DD ← merge dev → PR to main
```

**コンフリクト解決方針**: 全てdev側（theirs）を優先

## Workflow

### Step 1: 事前確認

```bash
# 現在のブランチとステータスを確認
git status
git branch --show-current

# リモートの最新を取得
git fetch origin
```

**確認事項:**
- ワーキングディレクトリがクリーンであること
- mainブランチに切り替え可能なこと

### Step 2: mainブランチを最新化

```bash
git checkout main
git pull origin main
```

### Step 3: リリースブランチを作成（重複チェック付き）

日付ベースのブランチ名を使用。既存ブランチがある場合は自動で連番を付与:

```bash
# ベースとなる日付
TODAY=$(date +%Y-%m-%d)
BASE_BRANCH="release/$TODAY"

# 既存ブランチをチェックして次の番号を決定
get_next_release_branch() {
  local base="$1"
  local today="$2"

  # ローカルとリモートの両方をチェック
  local existing=$(git branch -a --list "*release/$today*" | sed 's/.*release\//release\//' | sort -u)

  if [ -z "$existing" ]; then
    # 既存ブランチなし → ベース名を使用
    echo "$base"
  elif ! echo "$existing" | grep -q "^release/$today$"; then
    # release/YYYY-MM-DD が存在しない → ベース名を使用
    echo "$base"
  else
    # 連番を探す
    local n=2
    while echo "$existing" | grep -q "^release/$today-$n$"; do
      n=$((n + 1))
    done
    echo "release/$today-$n"
  fi
}

RELEASE_BRANCH=$(get_next_release_branch "$BASE_BRANCH" "$TODAY")
echo "Creating branch: $RELEASE_BRANCH"
git checkout -b "$RELEASE_BRANCH"
```

**命名規則:**
- 初回: `release/2025-01-15`
- 2回目: `release/2025-01-15-2`
- 3回目: `release/2025-01-15-3`
- ...以降連番

### Step 4: devの内容をマージ（コンフリクトはdev優先）

```bash
# devをマージ（コンフリクト時はtheirs=dev側を優先）
git merge origin/dev --strategy-option theirs --no-edit
```

**`--strategy-option theirs`の意味:**
- `theirs`はマージ対象（incoming）のブランチを指す
- この時点でリリースブランチ（=mainベース）にdevをマージするので、theirs=devが優先される

### Step 5: リモートにプッシュ

```bash
git push -u origin "$RELEASE_BRANCH"
```

### Step 6: PRを作成

```bash
gh pr create \
  --base main \
  --head "$RELEASE_BRANCH" \
  --title "Release $(date +%Y-%m-%d)" \
  --body "$(cat <<'EOF'
## Summary

- mainブランチベースのリリースブランチにdevをマージ
- コンフリクトはdev側を優先して解決済み

## Changes

devブランチでの変更内容がmainにマージされます。

---
Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

### Step 7: 完了確認

```bash
# PR URLを表示
gh pr view --web
```

## Quick Reference

**フルコマンド（コピペ用）:**

```bash
# 1. 準備
git fetch origin
git checkout main
git pull origin main

# 2. リリースブランチ作成（重複チェック付き）
TODAY=$(date +%Y-%m-%d)
BASE_BRANCH="release/$TODAY"
existing=$(git branch -a --list "*release/$TODAY*" | sed 's/.*release\//release\//' | sort -u)
if [ -z "$existing" ] || ! echo "$existing" | grep -q "^release/$TODAY$"; then
  RELEASE_BRANCH="$BASE_BRANCH"
else
  n=2; while echo "$existing" | grep -q "^release/$TODAY-$n$"; do n=$((n+1)); done
  RELEASE_BRANCH="release/$TODAY-$n"
fi
echo "Creating: $RELEASE_BRANCH"
git checkout -b "$RELEASE_BRANCH"

# 3. devマージ（dev優先）
git merge origin/dev --strategy-option theirs --no-edit

# 4. プッシュ
git push -u origin "$RELEASE_BRANCH"

# 5. PR作成
gh pr create --base main --head "$RELEASE_BRANCH" --title "Release $(date +%Y-%m-%d)" --body "devからmainへのリリース"
```

## Troubleshooting

### ブランチの重複チェックが正しく動作しない場合

リモートブランチの情報が古い可能性があります:

```bash
# リモート情報を最新化
git fetch origin --prune

# 既存のrelease/ブランチを確認
git branch -a | grep release/
```

### マージコンフリクトが自動解決できない場合

`--strategy-option theirs`で自動解決されるはずだが、それでも問題がある場合:

```bash
# マージを中止
git merge --abort

# 手動でtheirs戦略を使用（dev側で完全に上書き）
git merge -X theirs origin/dev
```

### PRが作成できない場合

```bash
# gh CLIの認証確認
gh auth status

# 手動でPR作成ページを開く
gh pr create --web
```

## Notes

- このスキルはdevがメイン開発ブランチであることを前提としています
- リリースブランチはmainから作成され、devの変更がマージされます
- リリースブランチは一時的なもので、PR マージ後は削除可能です
- 重要な変更がある場合はPRの説明を詳細に書くことを推奨します
