#!/bin/bash
# ------------------------------------------------------------
# Alfred Launcher: Battle.net via GE-Proton 9-11 (Flatpak-aware)
# ------------------------------------------------------------
# Launches Battle.net silently in the background with full logs
# and auto-detects the correct Proton-GE location for Flatpak.

# === CONFIGURATION ===
APP_ID=2579007386
# Flatpak Steam compatdata dir
COMPAT_DIR="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/compatdata/$APP_ID"
WINEPREFIX="$COMPAT_DIR/pfx"
BATTLE_NET_EXE="$WINEPREFIX/drive_c/Program Files (x86)/Battle.net/Battle.net.exe"
LOGFILE="$HOME/sanctiforge/logs/battlenet_launch.log"

# === LOCATE PROTON-GE 9-11 ===
if [ -d "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/compatibilitytools.d/GE-Proton9-11" ]; then
  PROTON_DIR="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/compatibilitytools.d/GE-Proton9-11"
elif [ -d "$HOME/.steam/root/compatibilitytools.d/GE-Proton9-11" ]; then
  PROTON_DIR="$HOME/.steam/root/compatibilitytools.d/GE-Proton9-11"
else
  echo "[ERROR] GE-Proton9-11 not found in expected paths." >&2
  exit 1
fi
PROTON_BIN="$PROTON_DIR/files/bin/wine64"

# === LOGGER ===
log() {
  echo "[$(date -u +'%Y-%m-%dT%H:%M:%SZ')] $1" | tee -a "$LOGFILE"
}

# === PRE-LAUNCH ===
mkdir -p "$(dirname "$LOGFILE")"
: > "$LOGFILE"   # truncate log each run
log "---------- Battle.net launch ----------"
log "Proton bin : $PROTON_BIN"
log "Prefix     : $WINEPREFIX"
log "Executable : $BATTLE_NET_EXE"

# Sanity checks
if [ ! -x "$PROTON_BIN" ]; then log "ERROR: Proton binary not executable"; exit 1; fi
if [ ! -d "$WINEPREFIX" ]; then log "ERROR: Wine prefix missing"; exit 1; fi
if [ ! -f "$BATTLE_NET_EXE" ]; then log "ERROR: Battle.net.exe missing"; exit 1; fi

# Prevent duplicate
if pgrep -f "Battle.net.exe" >/dev/null; then log "INFO: Battle.net already running"; exit 0; fi

# === ENV ===
export WINEPREFIX
export DXVK_ASYNC=0
export PROTON_NO_ESYNC=0
export PROTON_ENABLE_NVAPI=1
export PROTON_HIDE_NVIDIA_GPU=0

# === LAUNCH ===
log "Launching Battle.net in background…"
nohup "$PROTON_BIN" "$BATTLE_NET_EXE" >> "$LOGFILE" 2>&1 & disown
sleep 2
if pgrep -f "Battle.net.exe" >/dev/null; then
    log "SUCCESS: Battle.net running."
    exit 0
else
    log "FAILURE: Battle.net failed to start. Check above log output."
    exit 1
fi
