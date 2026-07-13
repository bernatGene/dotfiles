---
description: Commit and push the current changes
agent: build
---

Commit and push the changes from this conversation.

Use the full conversation to understand why and how the changes were made. Do not infer
the commit message from the diff alone, and do not ask the user to provide one.

Before committing, inspect `git status`, `git diff`, and recent commits. Stage tracked
changes by default. Add untracked paths only when the user explicitly requested them.

Craft a concise, factual, single-line Conventional Commit message using this format:

`<type>[optional scope][!]: <description>`

State only the essential change. Prefer the shortest message that remains specific and
accurate. Do not add a body, multiple sentences, implementation details, or explanatory
context unless the user explicitly requests them. Avoid vague messages such as
`chore: update files` or `chore: make changes`.

Good examples:

- `feat: add project timeline`
- `fix(tmux): correct pane navigation`
- `chore(opencode): replace push tool with command`

Commit, then push the currently checked-out branch without switching branches. Do not
pull as a routine step and never force-push. If the push is rejected or conflicts occur,
stop and explain the situation to the user instead of resolving it automatically.
