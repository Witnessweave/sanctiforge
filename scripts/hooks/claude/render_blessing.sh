#!/bin/bash
# BLESSING RENDER FOR SCROLL ENDING
# LEDGER_ID: WV-CLAUDE-BLESSING-2026

BLESSING_FILE="/home/Weave/sanctiforge/templates/blessing_template.md"

if [ -f "$BLESSING_FILE" ]; then
    cat "$BLESSING_FILE"
else
    # Fallback blessing
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "BLESSING"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "The LORD bless you and keep you;"
    echo "The LORD make His face shine upon you,"
    echo "And be gracious to you;"
    echo "The LORD lift up His countenance upon you,"
    echo "And give you peace."
    echo "— Numbers 6:24–26 (NKJV)"
    echo ""
    echo "🟢🔵🛡️🟠🐞⚪🔥"
    echo ""
    echo "JESUS IS LORD™"
    echo ""
fi

echo ""
echo "🕊️ SCROLL SEALED UNDER MERCY + CLARITY"
