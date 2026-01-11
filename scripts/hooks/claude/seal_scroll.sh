#!/bin/bash
# SCROLL SEALING & HASH REGISTRATION
# LEDGER_ID: WV-CLAUDE-SEAL-2026
# Usage: ./seal_scroll.sh /path/to/scroll.html

SCROLL="$1"
HASH_LOG="/home/Weave/sanctiforge/WitnessCloud/knight_identity/scroll_hashes.log"

if [ -z "$SCROLL" ]; then
    echo "⚠️ Usage: ./seal_scroll.sh /path/to/scroll.html"
    exit 1
fi

if [ ! -f "$SCROLL" ]; then
    echo "⚠️ File not found: $SCROLL"
    exit 1
fi

FILENAME=$(basename "$SCROLL")
HASH=$(sha256sum "$SCROLL" | awk '{print $1}')
TIMESTAMP=$(date --iso-8601=seconds)

# Check if already sealed
if grep -q "$FILENAME" "$HASH_LOG" 2>/dev/null; then
    echo "⚠️ Scroll already sealed. Remove old entry to re-seal."
    grep "$FILENAME" "$HASH_LOG"
    exit 1
fi

echo "$HASH  $FILENAME" >> "$HASH_LOG"

echo "✅ SEALED & HASHED UNDER UNITYFLOW"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Scroll: $FILENAME"
echo "Hash: $HASH"
echo "Time: $TIMESTAMP"
echo "Log: $HASH_LOG"
