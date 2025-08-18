# Holy Terminal Color Code System™ — praise.sh
. "$HOME/sanctiforge/scripts/colors.sh"
. "$HOME/sanctiforge/scripts/logger.sh"

bless(){  log_event BLESS "✅ $*"; }
warn(){   log_event WARN  "⚠️  $*"; }
halt(){   log_event ERROR "🛑 $*"; exit 1; }
proceed(){ log_event INFO "🟢 $*"; }
note(){   log_event NOTE  "• $*"; }
patch(){  log_event PATCH "🧵 $*"; }
verse(){  log_event VERSE "📖 $*"; }   # e.g., 'Isaiah 40:31 NKJV'

export -f bless warn halt proceed note patch verse
