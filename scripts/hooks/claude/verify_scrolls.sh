#!/bin/bash
# UNITYFLOW HASH INTEGRITY CHECK
# LEDGER_ID: WV-CLAUDE-HASH-VERIFY-2026
# Verifies all sealed scrolls against stored hashes

SCROLL_DIR="/home/Weave/sanctiforge/WitnessCloud/knight_scrolls"
HASH_LOG="/home/Weave/sanctiforge/WitnessCloud/knight_identity/scroll_hashes.log"
INTEGRITY_LOG="/home/Weave/sanctiforge/logs/hash_integrity.log"

echo "🛡️ UNITYFLOW SCROLL INTEGRITY CHECK"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Time: $(date)"
echo ""

if [ ! -f "$HASH_LOG" ]; then
    echo "⚠️ No hash log found at $HASH_LOG"
    echo "Run seal_scroll.sh on your scrolls first."
    exit 1
fi

cd "$SCROLL_DIR" || exit 1

RESULT=$(sha256sum -c "$HASH_LOG" 2>&1)
echo "$RESULT"
echo ""
echo "$RESULT" >> "$INTEGRITY_LOG"
echo "---" >> "$INTEGRITY_LOG"

if echo "$RESULT" | grep -q "FAILED"; then
    echo "⚠️ SCROLL DRIFT DETECTED — INTEGRITY COMPROMISED"
    echo "Review changes and restore from backup if needed."
else
    echo "✅ ALL SCROLLS VERIFIED — INTEGRITY INTACT"
fi
