#!/bin/bash
# ------------------------------------------------------------
# Alfred Utility: Set DLL Overrides for wininet and winhttp
# ------------------------------------------------------------

APP_ID=2579007386
WINEPREFIX="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/compatdata/$APP_ID/pfx"
REG_FILE="/tmp/battlenet_dll_overrides.reg"

# === FIND PROTON BIN ===
if [ -x "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/compatibilitytools.d/GE-Proton9-11/files/bin/wine64" ]; then
  PROTON_BIN="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/compatibilitytools.d/GE-Proton9-11/files/bin/wine64"
elif [ -x "$HOME/.steam/root/compatibilitytools.d/GE-Proton9-11/files/bin/wine64" ]; then
  PROTON_BIN="$HOME/.steam/root/compatibilitytools.d/GE-Proton9-11/files/bin/wine64"
else
  echo "[ERROR] Proton wine64 not found." >&2
  exit 1
fi

# === CREATE REGISTRY FILE ===
cat > "$REG_FILE" <<REG
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\\Software\\Wine\\DllOverrides]
"wininet"="native,builtin"
"winhttp"="native,builtin"
REG

# === APPLY OVERRIDES ===
echo "[INFO] Applying DLL overrides..."
WINEPREFIX="$WINEPREFIX" "$PROTON_BIN" regedit "$REG_FILE"

# === CLEANUP ===
rm -f "$REG_FILE"
echo "[DONE] Overrides applied."
