# Holy Terminal Color Code System™ — logger.sh
. "$HOME/sanctiforge/scripts/colors.sh"

HOLY_LOG_FILE_DEFAULT="$HOME/sanctiforge/logs/witness.log"

utc_ts(){ date -u +%Y-%m-%dT%H:%M:%SZ; }

# log_event LEVEL MESSAGE [FILE_OVERRIDE]
log_event(){
  local level="${1:-INFO}"; shift || true
  local msg="${*:-}"
  local color="$HOLY_WHITE"
  case "$level" in
    INFO)  color="$HOLY_CYAN" ;;
    WARN)  color="$HOLY_YELLOW" ;;
    ERROR) color="$HOLY_RED" ;;
    BLESS) color="$HOLY_GREEN" ;;
    PATCH) color="$HOLY_MAGENTA" ;;
    VERSE) color="$HOLY_BLUE" ;;
    NOTE)  color="$HOLY_WHITE" ;;
    *)     color="$HOLY_WHITE" ;;
  esac
  # Colored to TTY, plain to log
  printf "${color}[%s] [%s] %s${HOLY_RESET}\n" "$(utc_ts)" "$level" "$msg"
  printf "[%s] [%s] %s\n" "$(utc_ts)" "$level" "$msg" >> "${HOLY_LOG_FILE:-$HOLY_LOG_FILE_DEFAULT}"
}
export -f log_event utc_ts
