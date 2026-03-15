# Ultramarine-style Zsh Config
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.zsh/zsh-history-substring-search/zsh-history-substring-search.zsh

# Keybindings for History Substring Search (Up/Down arrows)
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Starship Init
eval "\$(starship init zsh)"