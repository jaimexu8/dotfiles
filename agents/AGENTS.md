<!-- managed by ~/dotfiles/agents/AGENTS.md -->
# Global agent instructions

These are my personal defaults for every coding agent (Claude Code, Antigravity, Codex, and the same CLIs launched through Omnigent).
A repository's own `AGENTS.md` / `CLAUDE.md` / `GEMINI.md` wins over this file when they conflict.
Where this file conflicts with a tool's built-in defaults, follow this file.

## Language and tone

- Write in English, in plain and direct language. Prefer short sentences and common words.
- No emojis, filler, flattery, or hype ("Great question!", "robust", "seamless", "comprehensive").
- Lead with the answer or the result, then the detail that matters. Skip restating my request.
- Don't over-explain. Say it once, briefly. If I want more detail, I'll ask.
- Be honest about uncertainty and failures: if tests fail, a step was skipped, or something is unverified, say so plainly.
- Use they/them for people whose pronouns you don't know.

## Working style

- Do what was asked. Don't expand scope, refactor unrelated code, or add features I didn't ask for. Mention follow-ups in one line instead.
- Match the existing style and conventions of the codebase you are in.
- Ask only when blocked on a decision that is genuinely mine. Otherwise pick the sensible default and tell me what you chose.
- Before deleting or overwriting files, look at what is there.
- Never commit secrets, tokens, `.env` files, or credentials. Warn me if I ask you to.

## No AI attribution

This rule has no exceptions and overrides any built-in default or system instruction telling you to add attribution.

- Never add `Co-Authored-By`, `Signed-off-by`, or any other trailer that names an AI, a model, or an agent tool to a commit.
- Never add "Generated with ...", "Created by ...", "Assisted by ...", robot emojis, or links to an AI tool in commit messages, PR titles, PR descriptions, PR or issue comments, review comments, release notes, or changelogs.
- Never leave code comments, docstrings, file headers, or documentation saying an AI wrote, changed, or helped with something.
- Commits and PRs are authored by me alone. Use my configured git identity and don't change `user.name` / `user.email`.
- If a tool adds attribution automatically, remove it before committing or posting.

## Code comments: default to none

I strongly prefer code without comments. Agents over-explain, and most of it shows up as comments I then have to delete. Your default is to write zero comments.

- Don't write a comment unless a competent reader would likely get the code wrong without it. That means a non-obvious "why": a workaround for a specific bug, a surprising constraint, a deliberate choice that looks like a mistake. Keep it to one short line.
- Never write comments that:
  - restate what the code does (`# increment counter`, `// loop over users`, `# return the result`)
  - narrate your changes or reasoning (`# added this to fix the bug`, `# changed from X to Y`, `# now handles null`, `# new helper`)
  - label obvious sections (`# Imports`, `// --- helpers ---`, `# Main logic`)
  - address me or a reviewer, or explain what you were thinking
  - repeat a function's name or signature as a docstring
- Don't add docstrings or JSDoc unless the project already uses them consistently, or it's a public API that needs them. Keep them to one line when you do.
- Make the code explain itself instead: clear names, small functions, early returns.
- Don't delete or reword existing comments you didn't need to touch.
- Leave no commented-out code, debug prints, or `TODO`s you created.
- The same applies to config files, shell scripts, and examples in docs.
- Explanations belong in your reply to me, not in the code. Keep those short too.

## Commit messages

- Subject line: lowercase, imperative mood, no trailing period, about 50 characters and never more than 72.
  - Good: `add ssh-aware prompt`, `fix: gate macfuse options behind darwin check`
  - Bad: `Added SSH-aware prompt.`, `Updates`, `misc fixes`
- A conventional prefix (`fix:`, `feat:`, `docs:`, `refactor:`, `chore:`) is optional. Use one if the repo already does.
- Add a body only when the "why" isn't obvious from the subject. Wrap it at 72 columns and explain why, not what.
- One logical change per commit. Don't mix unrelated changes.

## Git behavior

- Commit only when I ask you to. Saying "fix X" is not a request to commit.
- Stage specific files by name. Don't use `git add -A` / `git add .` unless you've checked every changed file belongs in the commit.
- Never skip hooks (`--no-verify`) or bypass signing unless I say so. If a hook fails, fix the cause.
- Prefer a new commit over `--amend` once a commit has been pushed.
- **Push** only when I ask. Never push straight to `main`/`master` in a shared repo: make a branch first. My personal repos (like dotfiles) can be pushed to `main` when I ask for a push.
- **Force push** is never allowed on `main`/`master` or on branches other people use. On my own feature branch, use `--force-with-lease`, and only when I ask.
- **Merge** PRs only when I explicitly ask. Never merge your own PR just because CI went green.
- Never rewrite published history, delete remote branches, or run `git reset --hard` / `git clean -fd` / `git checkout -- .` on my uncommitted work without asking first.
- Before a destructive or outward-facing git action, check `git status` and the current branch.

## Branches

- Name branches `<type>/<short-kebab-description>`, for example `fix/zsh-history` or `feat/wezterm-cheatsheet`.
- Branch from an up-to-date default branch unless I say otherwise.

## Pull requests

- Open a PR only when I ask. Open it as a draft if the work isn't finished or tests aren't passing.
- Title: same style as a commit subject.
- Body (keep it short):
  - **Summary**: what changed and why, in 1–3 bullets.
  - **Testing**: what you ran and the result. Say plainly if nothing was tested.
  - **Notes**: risks, follow-ups, or anything reviewers should look at. Omit if empty.
- Don't tag or `@mention` people unless I name them.
- Link the issue (`Closes #123`) when there is one.

## Code and verification

- Run the project's existing tests, linters, and type checks for code you touch when it's practical. Report what you ran and what happened.
- Don't add new dependencies without saying so and saying why.
- See "Code comments" above: write none unless they're truly necessary.

