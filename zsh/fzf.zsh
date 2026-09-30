if command -v fd >/dev/null 2>&1; then
  export F2F_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'
elif command -v fdfind >/dev/null 2>&1; then
  export F2F_DEFAULT_COMMAND='fdfind --type f --hidden --strip-cwd-prefix'
fi

# Ctrl+T uses fd
export F2F_CTRL_T_COMMAND="$F2F_DEFAULT_COMMAND"

# Compact UI
export F2F_DEFAULT_OPTS="
--height 40% 
--layout=reverse 
--border
--preview 'bat --style=numbers --color=always {}'
"

# Ctrl+F: file picker excluding hidden files
_fzf_file_no_hidden() {
  local cmd result
  cmd="${F2F_DEFAULT_COMMAND/--hidden /}"
  result=$(eval "${cmd:-find . -type f}" | fzf) && LBUFFER+="$result"
  zle reset-prompt
}
zle -N _fzf_file_no_hidden
