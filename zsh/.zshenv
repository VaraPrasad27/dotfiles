# ~/.config/zsh/.zshenv

# ---------- XDG base directories --------------
# Centralizes config/cache/data locations
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"


# ----------- Editor -----------------
export EDITOR="nvim"
export VISUAL="nvim"

# ------------ GPG --------------
export GPG_TTY=$(tty)

# ------------ PATH -------------
export PATH="$HOME/.local/bin:$PATH"

# ------------ Pager ------------
export MANPAGER="bat -l man -p"

#------------- Starship ----------
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"
