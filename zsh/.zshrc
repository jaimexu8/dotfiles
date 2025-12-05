# ==========================================
# 1. GREETING (Fastfetch + Custom ASCII)
# ==========================================
# Runs every time you open a terminal
echo -ne '\033[38;5;213m'  # Set color
echo "    __               __    __  ";
echo "   / /_  _______  __/ /_  / /_ ";
echo "  / __ \\/ ___/ / / / __ \\/ __ \\";
echo " / /_/ / /  / /_/ / / / / / / /";
echo "/_.___/_/   \\__,_/_/ /_/_/ /_/ ";
echo "                               ";                               
echo -ne '\033[0m'  # Reset color
# Run fastfetch if installed
if command -v fastfetch &> /dev/null; then
    fastfetch --key-padding-left 5
fi

# ==========================================
# 2. FUNCTIONS
# ==========================================
xu1545() {
    ssh xu1545@${1:-data}.cs.purdue.edu
}

yank() {
    local file="$1"

    # Check if filename argument is missing
    if [ -z "$file" ]; then
        echo "Usage: yank <filename>"
        return 1
    fi

    # Check if the file actually exists
    if [ ! -f "$file" ]; then
        echo "Error: File '$file' not found."
        return 1
    fi

    # Copy content (OSC 52 for remote/local consistency)
    local data=$(base64 < "$file" | tr -d '\n')
    printf "\033]52;c;%s\a" "$data"
    echo "yank: copied $file to clipboard"
}

# ==========================================
# 3. ENVIRONMENT PATHS
# ==========================================
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:/Applications/ServiceNow CLI/bin"

# ==========================================
# 4. TOOL INITIALIZATION
# ==========================================

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Conda
__conda_setup="$('/Users/jaimexu/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/jaimexu/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/jaimexu/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/jaimexu/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

