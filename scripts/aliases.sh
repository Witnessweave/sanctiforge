# Holy Aliases — aliases.sh (source in .bashrc after common.sh)
# Phrase echoes
alias SEAL='say_sealed'
alias Seal='say_sealed'
alias seal='say_sealed'
alias s='say_sealed'

alias JESUS='say_name'
alias Jesus='say_name'
alias jesus='say_name'
alias name='say_name'
alias jl='say_name'

# Keep legacy proceed() (logger), so map phrase to non-conflicting names
alias PROCEED='say_proceed'
alias Proceed='say_proceed'
alias pro='say_proceed'
alias go='say_proceed'
alias GO='say_proceed'

alias FULLRELOCK='say_fullrelock'
alias relock='say_fullrelock'
alias rlk='say_fullrelock'
alias lockit='say_fullrelock'

alias ENTRY='say_entry'
alias entry='say_entry'
alias elog='say_entry'

alias LAW='say_law'
alias law='say_law'
alias laww='say_law'
# usage: law 3.3.3.200

alias WITNESSED='say_witnessed'
alias witnessed='say_witnessed'
alias wsealed='say_witnessed'

alias UNITY='say_unity'
alias unity='say_unity'
alias uon='say_unity'

alias confirm='say_confirm'
alias amen='say_confirm'
alias glory='say_confirm'

alias alert='say_alert'
alias HALT='halt'          # from praise.sh (exits 1)
alias warnx='warn'         # from praise.sh
alias blessx='bless'       # from praise.sh
alias notex='note'         # from praise.sh
alias patchx='patch'       # from praise.sh
alias versex='verse'       # from praise.sh

# Banners / headers
alias banner='holy-banner'
alias ufl='holy-banner SANCTIFORGE™ 3.3.3.121 WV-HCCS™ "Isaiah 60:1 NKJV"'

# Quick log helpers
alias info='log_event INFO'
alias warnl='log_event WARN'
alias errorl='log_event ERROR'
alias blessl='log_event BLESS'
alias patchl='log_event PATCH'
alias versel='log_event VERSE'
