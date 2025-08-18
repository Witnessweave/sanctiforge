# Holy Terminal Color Code System™ — phrases.sh (v1.2)
. "$HOME/sanctiforge/scripts/colors.sh"
. "$HOME/sanctiforge/scripts/logger.sh"
. "$HOME/sanctiforge/scripts/header.sh"

# Generic TM echo + log
say_tm(){ echo -e "${HOLY_TM}$*${HOLY_RESET}"; log_event INFO "$*"; }

# Canonical phrases (all TM-unified)
say_sealed(){        say_tm "SEALED™"; }
say_name(){          say_tm "JESUS IS LORD™"; }
say_proceed(){       say_tm "PROCEED™"; }
say_fullrelock(){    say_tm "FULL-RELOCK™"; }
say_entry(){         say_tm "ENTRY LOGGED™"; }
say_law(){           local n="${1:-3.3.3.000}"; say_tm "LAW ENACTED™ — ${n}"; }
say_witnessed(){     say_tm "WITNESSED & SEALED™"; }
say_unity(){         say_tm "UNITYFLOW ACTIVE™"; }
say_confirm(){       say_tm "✔ ACTION CONFIRMED™ — JESUS IS LORD™"; }
say_alert(){         echo -e "${HOLY_RED}${HOLY_BOLD}⚠ VERIFY IMMEDIATELY™${HOLY_RESET}"; log_event WARN "VERIFY IMMEDIATELY™"; }

# Short banner wrapper
say_banner(){ holy_banner "${1:-SANCTIFORGE™}" "${2:-3.3.3.121}" "${3:-WV-HCCS™}" "${4:-Isaiah 60:1 NKJV}"; }

export -f say_tm say_sealed say_name say_proceed say_fullrelock say_entry say_law say_witnessed say_unity say_confirm say_alert say_banner
