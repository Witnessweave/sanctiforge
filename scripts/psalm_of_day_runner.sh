#!/usr/bin/env bash
set -euo pipefail
ROOT="$HOME/sanctiforge"
LOG="$ROOT/logs/witness_audio.log"
utc_log(){ printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" >> "$LOG"; }
psalm_number_for_day(){ local dom; dom="$(date +%d | sed 's/^0*//')"; local ps=$(( ( (dom - 1) % 150 ) + 1 )); echo "$ps"; }
# ensure cmus
if ! pgrep -x cmus >/dev/null 2>&1; then
  if command -v tmux >/dev/null 2>&1; then tmux new-session -ds cmusd 'cmus'; else nohup cmus >/dev/null 2>&1 & sleep 1; fi
  utc_log "[CRON] started cmus for Psalm-of-Day"
fi
# play
PSNUM="$(psalm_number_for_day)"
cmus-remote -C "clear" >/dev/null 2>&1 || true
cmus-remote -C "add $HOME/sanctiforge/audio/psalms" >/dev/null 2>&1 || true
cmus-remote -C "search Psalm $PSNUM" >/dev/null 2>&1 || true
cmus-remote -C "play" >/dev/null 2>&1 || true
utc_log "[CRON_PLAY] Psalm-of-Day=$PSNUM"
