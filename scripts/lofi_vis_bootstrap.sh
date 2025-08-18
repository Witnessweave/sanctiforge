#!/usr/bin/env bash
set -euo pipefail

log(){ printf '%s %s\n' "$(date -u -Is)" "$*" | tee -a "$HOME/sanctiforge/logs/lofi_vis.log" >/dev/null; }

# 0) Preflight
command -v node >/dev/null || { echo "Node.js not found. Install Node 18+ then re-run." >&2; exit 1; }
command -v npm  >/dev/null || { echo "npm not found. Install npm then re-run." >&2; exit 1; }

ROOT="$HOME/sanctiforge"
APPROOT="$ROOT/web"
APPDIR="$APPROOT/lofi-vis"

mkdir -p "$APPROOT" "$ROOT/logs"

log "BEGIN — Lo-Fi Visualiser bootstrap"

# 1) Create app if missing
if [ ! -d "$APPDIR" ]; then
  log "vite: creating $APPDIR"
  cd "$APPROOT"
  npm create vite@latest lofi-vis -- --template react-ts </dev/tty
else
  log "vite: project exists — $APPDIR"
fi

cd "$APPDIR"

# 2) Install dependencies
log "npm install"
npm i

# 3) Inject App.tsx (Win’96 chrome + canvas visualiser + bundled synth)
log "write: src/App.tsx"
cat > src/App.tsx <<'APP_TSX'
%s
APP_TSX

# 4) Ensure strict CSS reset is fine (optional). Keep Vite defaults.

# 5) Start dev server (foreground)
log "START — npm run dev (Ctrl+C to stop)"
npm run dev
