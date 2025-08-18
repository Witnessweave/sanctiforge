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
