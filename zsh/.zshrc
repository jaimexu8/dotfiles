# ==========================================
# GREETING
# ==========================================
if command -v fastfetch &> /dev/null; then
    fastfetch --key-padding-left 5
fi

# ==========================================
# PROMPT CONFIGURATION
# ==========================================
# %m = machine name
# %~ = current working directory
# %# = % symbol for regular users
PROMPT='%m %~ %# '

# ==========================================
# ALIASES
# ==========================================
# Navigation
alias ..="cd .."
alias ...="cd ../.."

if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS aliases (BSD ls)
    alias ls="ls -G"
    alias ll="ls -lah -G"
else
    # Linux aliases (GNU ls)
    alias ls="ls --color=auto"
    alias ll="ls -lah --color=auto"
fi

# ==========================================
# FUNCTIONS
# ==========================================
xu1545() {
    ssh xu1545@${1:-data}.cs.purdue.edu
}

yank() {
    local file="$1"

    if [ -z "$file" ]; then
        echo "Usage: yank <filename>"
        return 1
    fi

    if [ ! -f "$file" ]; then
        echo "Error: File '$file' not found."
        return 1
    fi

    local data=$(base64 < "$file" | tr -d '\n')
    printf "\033]52;c;%s\a" "$data"
    echo "yank: copied $file to clipboard"
}

# ==========================================
# COMMAND HISTORY
# ==========================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY          # Append to history rather than overwrite
setopt HIST_IGNORE_ALL_DUPS    # Don't save duplicated commands to history
setopt HIST_REDUCE_BLANKS      # Remove extra blank spaces from history
setopt SHARE_HISTORY           # Share history across all open terminal windows

# ==========================================
# TAB COMPLETION
# ==========================================
autoload -Uz compinit
compinit
# Enables a menu when pressing tab twice
zstyle ':completion:*' menu select 
# Makes tab completion case-insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 

# ==========================================
# ENVIRONMENT PATHS
# ==========================================
export PATH="$HOME/.local/bin:$PATH"

