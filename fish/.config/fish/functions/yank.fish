function yank
    # Check if filename argument is missing
    if test -z "$argv[1]"
        echo "Usage: yank <filename>"
        return 1
    end

    # Check if the file actually exists
    if not test -f "$argv[1]"
        echo "Error: File '$argv[1]' not found."
        return 1
    end

    # Copy content (set -l makes the variable local to this function)
    set -l data (base64 "$argv[1]" | tr -d '\n')
    printf "\033]52;c;%s\a" "$data"
    echo "yank: copied $argv[1] to clipboard"
end
