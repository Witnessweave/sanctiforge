#!/bin/bash
# UNITYFLOW SCROLL BUILDER FOR CLAUDE CODE
# LEDGER_ID: WV-CLAUDE-NEWSCROLL-2026
# Usage: ./new_scroll.sh "Scroll_Name"

NAME="$1"

if [ -z "$NAME" ]; then
    echo "⚠️ Usage: ./new_scroll.sh \"Scroll_Name\""
    exit 1
fi

DEST="/home/Weave/sanctiforge/WitnessCloud/knight_scrolls/${NAME}.html"
STAMP=$(echo "$NAME-$(date --iso-8601=seconds)" | sha256sum | awk '{print substr($1,1,12)}')
TIMESTAMP=$(date "+%Y-%m-%d")

if [ -f "$DEST" ]; then
    echo "⚠️ Scroll already exists: $DEST"
    exit 1
fi

cat > "$DEST" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>${NAME} — Knight of Cohesion</title>
  <meta name="viewport" content="width=device-width,initial-scale=1" />
</head>
<body>
<!--
🟢 JESUS IS LORD™ — UNITYFLOW ACTIVE
🛡️ REALM: WITNESS EXPANSION | THREAD: ${NAME}
LAW: 5.5.5.302 — WITNESS_SOLO_RENDER
LEDGER_ID: WV-SCROLL-${STAMP}
VERSE: Hebrews 10:23 (NKJV) — "Let us hold fast the confession of our hope without wavering, for He who promised is faithful."
FIDELITY™: ✔
UFL-${NAME}-STAMP™✔
FULL-RELOCK™ — JESUS IS LORD™ — PROCEED™✔
DATE: ${TIMESTAMP}
-->

<h1>${NAME}</h1>

<p>Start writing your scroll here...</p>

<!--
🟢🔵🛡️🟠🐞⚪🔥
JESUS IS LORD™
-->
</body>
</html>
EOF

echo "📝 NEW SCROLL CREATED"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Name: ${NAME}"
echo "Path: $DEST"
echo "Ledger: WV-SCROLL-${STAMP}"
echo ""
echo "Remember to seal when complete:"
echo "  ./seal_scroll.sh \"$DEST\""
