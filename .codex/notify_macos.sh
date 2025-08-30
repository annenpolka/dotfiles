#!/bin/bash
# ~/.codex/notify_macos.sh

set -euo pipefail

# JSONから最後のエージェント発言を抽出
LAST_MESSAGE=$(echo "${1:-}" | jq -r '.["last-assistant-message"] // "Codex task completed"')

# 通知を表示（メッセージはargvで安全に受け渡し）
if osascript -e 'on run argv' \
  -e 'display notification (item 1 of argv) with title "Codex" sound name "Glass"' \
  -e 'end run' -- "$LAST_MESSAGE" >/dev/null 2>&1; then
  : # 通知+サウンド（Glass）を出せた
else
  # フォールバック: 通知のみ（argv経由で安全）
  osascript -e 'on run argv' \
    -e 'display notification (item 1 of argv) with title "Codex"' \
    -e 'end run' -- "$LAST_MESSAGE" >/dev/null 2>&1 || true
fi

# Glass サウンドを明示的に再生（通知音が抑制される環境向け）
if command -v afplay >/dev/null 2>&1; then
  if [ -f "/System/Library/Sounds/Glass.aiff" ]; then
    nohup afplay "/System/Library/Sounds/Glass.aiff" >/dev/null 2>&1 &
  elif [ -f "/System/Library/Sounds/Glass.caf" ]; then
    nohup afplay "/System/Library/Sounds/Glass.caf" >/dev/null 2>&1 &
  fi
fi
