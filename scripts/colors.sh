# Holy Terminal Color Code System™ — colors.sh
# Updated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
# Honors NO_COLOR=1 and non-TTY sinks.

if [ -t 1 ] && [ "${NO_COLOR:-0}" != "1" ]; then
  HOLY_RESET="\033[0m"
  HOLY_BOLD="\033[1m"

  # Core bright set
  HOLY_GREEN="\033[1;32m"     # Peace / Bless
  HOLY_YELLOW="\033[1;33m"    # Caution / Watch
  HOLY_RED="\033[1;31m"       # Halt / Judgment
  HOLY_BLUE="\033[1;34m"      # Scripture / Order
  HOLY_MAGENTA="\033[1;35m"   # Seal / Covenant
  HOLY_CYAN="\033[1;36m"      # Active / Ops
  HOLY_WHITE="\033[1;37m"     # Neutral

  # Accents
  HOLY_GOLD="\033[38;5;178m"
  HOLY_PURPLE="\033[38;5;177m"
else
  HOLY_RESET=""; HOLY_BOLD=""
  HOLY_GREEN=""; HOLY_YELLOW=""; HOLY_RED=""
  HOLY_BLUE=""; HOLY_MAGENTA=""; HOLY_CYAN=""; HOLY_WHITE=""
  HOLY_GOLD=""; HOLY_PURPLE=""
fi
export HOLY_RESET HOLY_BOLD HOLY_GREEN HOLY_YELLOW HOLY_RED HOLY_BLUE HOLY_MAGENTA HOLY_CYAN HOLY_WHITE HOLY_GOLD HOLY_PURPLE
# === Sacred Command Color Accents (added) ===
export HOLY_SEALED="${HOLY_MAGENTA}${HOLY_BOLD}"   # SEALING
export HOLY_NAME="${HOLY_GREEN}${HOLY_BOLD}"       # JESUS IS LORD™
export HOLY_PROCEED="${HOLY_CYAN}${HOLY_BOLD}"     # PROCEED™
export HOLY_LOCK="${HOLY_BLUE}${HOLY_BOLD}"        # FULL-RELOCK™
export HOLY_WITNESS="${HOLY_YELLOW}${HOLY_BOLD}"   # WITNESS LOCK
export HOLY_ALERT="${HOLY_RED}${HOLY_BOLD}"        # EMERGENCY
export HOLY_SUCCESS="${HOLY_GREEN}${HOLY_BOLD}"    # CONFIRMATION
# === Unified Trademark Color Layer™ ===
# Bind all ™ phrases to the same covenant color.
export HOLY_TM="${HOLY_MAGENTA}${HOLY_BOLD}"
