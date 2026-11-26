#!/bin/sh
set -eu

SRC="$(cd "$(dirname "$0")" && pwd)/AGENTS.md"
MARKER='<!-- managed by ~/dotfiles/agents/AGENTS.md'

link() {
  target=$1
  mkdir -p "$(dirname "$target")"

  if [ -L "$target" ]; then
    if [ "$(readlink "$target")" = "$SRC" ]; then
      echo "ok      $target"
      return
    fi
    rm "$target"
  elif [ -e "$target" ]; then
    # Files without the marker are the user's own, so back them up.
    if ! head -n 1 "$target" | grep -qF "$MARKER"; then
      backup="$target.bak.$(date +%Y%m%d%H%M%S)"
      mv "$target" "$backup"
      echo "backup  $target -> $backup"
    else
      rm "$target"
    fi
  fi

  ln -s "$SRC" "$target"
  echo "linked  $target -> $SRC"
}

link "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/CLAUDE.md"
link "$HOME/.gemini/AGENTS.md"
link "${CODEX_HOME:-$HOME/.codex}/AGENTS.md"

settings="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/settings.json"
if command -v python3 >/dev/null 2>&1; then
  python3 - "$settings" <<'EOF'
import json, sys, pathlib
p = pathlib.Path(sys.argv[1])
d = json.loads(p.read_text()) if p.exists() and p.read_text().strip() else {}
d["includeCoAuthoredBy"] = False
d["attribution"] = {"commit": "", "pr": ""}
p.write_text(json.dumps(d, indent=2) + "\n")
print(f"set     {p}: attribution disabled")
EOF
else
  echo "warning python3 not found; set \"attribution\": {\"commit\": \"\", \"pr\": \"\"} in $settings by hand"
fi

if [ -e "$HOME/.gemini/GEMINI.md" ]; then
  echo "warning $HOME/.gemini/GEMINI.md also exists; agy loads both. Merge it into AGENTS.md and remove it."
fi
