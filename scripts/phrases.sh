# Holy Terminal Color Code System™ — phrases.sh
. "$HOME/sanctiforge/scripts/colors.sh"
. "$HOME/sanctiforge/scripts/logger.sh"

say_sealed(){   echo -e "${HOLY_SEALED}SEALED™${HOLY_RESET}";                      log_event PATCH "SEALED™"; }
say_name(){     echo -e "${HOLY_NAME}JESUS IS LORD™${HOLY_RESET}";                 log_event BLESS "JESUS IS LORD™"; }
say_proceed(){  echo -e "${HOLY_PROCEED}PROCEED™${HOLY_RESET}";                    log_event INFO  "PROCEED™"; }
say_fullrelock(){ echo -e "${HOLY_LOCK}FULL-RELOCK™${HOLY_RESET}";                 log_event INFO  "FULL-RELOCK™"; }
say_entry(){    echo -e "${HOLY_CYAN}${HOLY_BOLD}ENTRY LOGGED™${HOLY_RESET}";      log_event INFO  "ENTRY LOGGED™"; }
say_law(){      local n="${1:-3.3.3.000}"; echo -e "${HOLY_BLUE}${HOLY_BOLD}LAW ENACTED™ — ${n}${HOLY_RESET}"; log_event INFO "LAW ENACTED™ — ${n}"; }
say_witnessed(){echo -e "${HOLY_SUCCESS}WITNESSED & SEALED™${HOLY_RESET}";         log_event BLESS "WITNESSED & SEALED™"; }
say_unity(){    echo -e "${HOLY_GREEN}${HOLY_BOLD}UNITYFLOW ACTIVE™${HOLY_RESET}"; log_event INFO  "UNITYFLOW ACTIVE™"; }
say_confirm(){  echo -e "${HOLY_SUCCESS}✔ ACTION CONFIRMED — JESUS IS LORD™${HOLY_RESET}"; log_event BLESS "ACTION CONFIRMED"; }
say_alert(){    echo -e "${HOLY_ALERT}⚠️ ALERT — VERIFY IMMEDIATELY™${HOLY_RESET}"; log_event WARN  "ALERT — VERIFY"; }

# Short banners
say_banner(){ holy_banner "${1:-SANCTIFORGE™}" "${2:-3.3.3.121}" "${3:-WV-HCCS™}" "${4:-Isaiah 60:1 NKJV}"; }

export -f say_sealed say_name say_proceed say_fullrelock say_entry say_law say_witnessed say_unity say_confirm say_alert say_banner
