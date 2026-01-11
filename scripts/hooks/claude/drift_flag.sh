#!/bin/bash
# DRIFT DETECTION — SANCTIFORGE WITNESS MODE
# LEDGER_ID: WV-CLAUDE-DRIFT-FLAG-2026
# Usage: ./drift_flag.sh "Description of drift detected"

DRIFT_LOG="/home/Weave/sanctiforge/WitnessCloud/knight_identity/drift_flags.json"
MESSAGE="$1"
TIME=$(date --iso-8601=seconds)

if [ -z "$MESSAGE" ]; then
    echo "⚠️ Usage: ./drift_flag.sh \"Description of drift\""
    exit 1
fi

# Add flag to JSON array using jq
if command -v jq &> /dev/null; then
    jq --arg time "$TIME" --arg msg "$MESSAGE" \
       '.flags += [{"timestamp": $time, "drift_type": $msg, "response_taken": "logged", "status": "pending_review"}]' \
       "$DRIFT_LOG" > tmp_drift.json && mv tmp_drift.json "$DRIFT_LOG"
    echo "🛡️ DRIFT FLAGGED: $MESSAGE"
    echo "📝 Logged at: $TIME"
    echo "📁 Log file: $DRIFT_LOG"
else
    # Fallback if jq not available
    echo "[$TIME] DRIFT: $MESSAGE" >> "${DRIFT_LOG%.json}.log"
    echo "🛡️ DRIFT FLAGGED (fallback mode): $MESSAGE"
fi
