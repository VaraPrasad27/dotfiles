alias ls='eza --icons'
alias ll='eza -lh --icons --git'
alias la='eza -lah --icons --git'
alias tree='eza --tree --icons'

# Reuse ls completions for eza
compdef eza=ls

alias grep='rg --color=auto'
alias diff='diff --color=auto'
alias df='df -h'

alias -- -='cd -'

alias cdp='cd ~/Projects'
alias cdd='cd ~/Downloads'
alias cdg='cd ~/git-repos'

alias q='exit'
