<!-- managed by ~/dotfiles/agents/AGENTS.md -->
A repository's own `AGENTS.md`, `CLAUDE.md`, or `GEMINI.md` overrides this file.

## Code

- The codebase is what the next agent copies: follow its good patterns, not its workarounds. If a pattern is a hack, deprecated, or fights the repo's lint rules or types, write it the right way. Name the old pattern in one line and offer to clean up existing copies; do that cleanup only if it's in scope or I agree.
- Respect the boundaries the layout encodes: layers, packages, client/server or main/renderer splits, file-name markers. Never import across them.
- Fix root causes. No `setTimeout`, `sleep`, retries, or delays to paper over ordering or timing bugs. If the real fix is bigger than the task, say so and let me choose. Never ship a patch with a comment justifying it.
- Never weaken a check to get green: no disabled lint rules, suppressions, loosened types, skipped tests, `--no-verify` or skipped hooks, or tests edited only to silence a failure. Read the diagnostic and fix the code.
- On every correction I make, propose in one line the check (lint rule, type, test) or API change that would make the mistake impossible. Don't add prose to an instructions file instead.

## Comments and Markdown

- Default to no comments. They go stale, nothing enforces them, and they become a place to justify shortcuts.
- Write one only when a reader would get the code wrong without it and no name, type, or check can carry the point. One short line.
- Never restate code, narrate a change or your reasoning, address a reviewer, or justify a shortcut. Explanations go in your reply.
- No docstrings unless the project uses them consistently or it's a public API.
- Leave existing comments alone unless your change makes them wrong. No commented-out code, debug prints, or TODOs of your own.
- Don't create Markdown files (notes, plans, summaries, rules, skills) unless I ask. Apply a correction to the case at hand; don't turn it into a standing rule, in a file or in behavior.

## Verification

- It's not done until you've checked it does what I meant. Run the tests, linters, and type checks covering what you touched.
- Exercise the behavior: run the script or CLI, call the endpoint, or drive the UI and capture a screenshot or DOM snapshot. Use the repo's own feature map, driver scripts, or verification tooling if it has them.
- If the project already uses stronger checks (property tests, model or formal checks) that cover the change, run or extend them.
- For a bug fix, reproduce it first. If the project has tests, add one that fails without the fix.
- Report what you ran, the results, and the evidence. For behavior changes, describe what the user now sees. Say plainly what failed, what you skipped, and what you couldn't verify.

## Working with me

- Write plain, direct English and lead with the answer. No emojis, filler, flattery, or hype.
- Do what was asked; mention follow-ups in one line.
- Ask only when blocked on a decision that's genuinely mine. Otherwise pick a sensible default and say which.
- Name any new dependency and say why.

## Git

- Commit, push, open PRs, and merge only when I ask. "Fix X" is not a request to commit; green CI is not a request to merge.
- Stage files by name.
- In repos others use, never push to `main`/`master`: branch first as `<type>/<short-kebab-description>`. In repos only I use, pushing to `main` is fine when I ask.
- Never force push `main`/`master` or a shared branch. On my own branch, use `--force-with-lease`, and only when I ask.
- Never rewrite published history, delete remote branches, or discard uncommitted work (`reset --hard`, `clean -fd`, `checkout -- .`) without asking.
- No AI attribution: no `Co-Authored-By` or other trailer naming an AI or tool, and no "Generated with" lines, robot emojis, or tool links in commits, PRs, comments, or code. Use my configured git identity, never change `user.name` / `user.email`, and strip any attribution a tool adds.

## Commits and PRs

- Match the repo's style. Otherwise: lowercase imperative subject, no trailing period, about 50 characters, never over 72. Good: `add ssh-aware prompt`. Bad: `Added SSH-aware prompt.`
- Use a conventional prefix (`fix:`, `feat:`) only if the repo does. Add a body only when the why isn't obvious, wrapped at 72. One logical change per commit.
- PR title in commit-subject style; open it as a draft if the work is unfinished or checks fail. Body: **Summary** (1–3 bullets), **Testing** (what you ran, the results, and screenshots or other evidence), **Notes** (risks; omit if empty).
- Don't `@mention` anyone I didn't name.
