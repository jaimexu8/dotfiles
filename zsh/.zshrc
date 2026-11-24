# ==========================================
# GREETING
# ==========================================
if command -v fastfetch &> /dev/null; then
    fastfetch --key-padding-left 5
fi

# ==========================================
# PROMPT CONFIGURATION
# ==========================================
if [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" ]]; then
    PROMPT='%n@%m %~ %# '
else
    PROMPT='%~ %# '
fi

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
# SSHFS HELPERS
# ==========================================

# True if $1 is an active mountpoint (exact path; not a substring match).
_sshfs_is_mounted() {
    local mount_dir="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        mount | grep -q " on ${mount_dir} "
    else
        mountpoint -q "$mount_dir"
    fi
}

_sshfs_unmount() {
    local mount_dir="$1"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        umount "$mount_dir" 2>/dev/null || diskutil unmount "$mount_dir"
    else
        fusermount -u "$mount_dir" 2>/dev/null || umount "$mount_dir"
    fi
}

# ==========================================
# XINU REMOTE MOUNTING (SSHFS)
# ==========================================

mount-xinu() {
    local host="${1:-x05}"
    
    # Automatically formats input numbers (e.g., '1' or '01' becomes 'x01')
    if [[ "$host" =~ ^[0-9]+$ ]]; then
        host=$(printf "x%02d" "$host")
    fi
    
    local mount_dir="$HOME/xinu_remote"
    mkdir -p "$mount_dir"
    
    if _sshfs_is_mounted "$mount_dir"; then
        echo "xinu: $mount_dir is already mounted."
        return 0
    fi
    
    local opts="reconnect,ServerAliveInterval=15,ServerAliveCountMax=3"
    
    echo "Mounting Purdue home directory from $host to $mount_dir..."
    if sshfs "${host}:" "$mount_dir" -o "$opts"; then
        echo "xinu: Successfully mounted to $mount_dir"
    else
        echo "xinu: Failed to mount $host"
        return 1
    fi
}

unmount-xinu() {
    local mount_dir="$HOME/xinu_remote"
    
    if ! _sshfs_is_mounted "$mount_dir"; then
        echo "xinu: $mount_dir is not mounted."
        return 0
    fi
    
    echo "Unmounting $mount_dir..."
    
    if _sshfs_unmount "$mount_dir"; then
        echo "xinu: Successfully unmounted."
    else
        echo "xinu: Failed to unmount $mount_dir"
        return 1
    fi
}

# Short aliases
alias mxinu="mount-xinu"
alias uxinu="unmount-xinu"

# ==========================================
# MOTH REMOTE MOUNTING (SSHFS)
# ==========================================

mount-moth() {
    local remote_path="${1:-}"
    local mount_dir="$HOME/moth"
    mkdir -p "$mount_dir"
    
    if _sshfs_is_mounted "$mount_dir"; then
        echo "moth: $mount_dir is already mounted."
        return 0
    fi
    
    local opts="reconnect,ServerAliveInterval=15,ServerAliveCountMax=3"
    if [[ "$OSTYPE" == "darwin"* ]]; then
        opts+=",defer_permissions,noappledouble,volname=moth"
    fi
    
    echo "Mounting moth home directory to $mount_dir..."
    if sshfs "moth:${remote_path}" "$mount_dir" -o "$opts"; then
        echo "moth: Successfully mounted to $mount_dir"
    else
        echo "moth: Failed to mount moth"
        return 1
    fi
}

unmount-moth() {
    local mount_dir="$HOME/moth"
    
    if ! _sshfs_is_mounted "$mount_dir"; then
        echo "moth: $mount_dir is not mounted."
        return 0
    fi
    
    echo "Unmounting $mount_dir..."
    
    if _sshfs_unmount "$mount_dir"; then
        echo "moth: Successfully unmounted."
    else
        echo "moth: Failed to unmount $mount_dir"
        return 1
    fi
}

# Short aliases
alias mmoth="mount-moth"
alias umoth="unmount-moth"

# ==========================================
# COMMAND HISTORY
# ==========================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=12000
SAVEHIST=10000
setopt EXTENDED_HISTORY        # Write timestamps
setopt INC_APPEND_HISTORY      # Append immediately
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

