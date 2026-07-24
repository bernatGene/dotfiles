---
description: Commit and push the current changes
agent: build
---

Commit and push the current changes in one step.

The user said: `$ARGUMENTS`

If the arguments include words like `untracked`, `--all`, or `-A`, stage all changes.
Otherwise, stage only tracked changes.

Run the whole add/commit/push as a single chained command:

- Default: `git add -u && git commit -m "<message>" && git push`
- If including untracked files: `git add -A && git commit -m "<message>" && git push`

Do not switch branches, pull as a routine step, or force-push. If the push is rejected or a
conflict occurs, stop and report the problem to the user.

Pick a concise, factual Conventional Commit message based on the conversation, not just the
diff. Use the format `<type>[optional scope][!]: <description>` and keep it to a single line.
Do not add a body unless the user explicitly asks for one.

Good examples:

- `feat: add project timeline`
- `fix(tmux): correct pane navigation`
- `chore(opencode): replace push tool with command`
