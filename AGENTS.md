# AGENTS.md

This repository is the canonical source for my dotfiles.

Relevant config directories and files are symlinked from this repo into their runtime locations, for example:

```sh
ln -s ~/p/dotfiles/nvim ~/.config/nvim
ln -s ~/p/dotfiles/kitty ~/.config/kitty
ln -s ~/p/dotfiles/tmux/.tmux.conf ~/.tmux.conf
```

These symlinks are managed by me, not by agents. When working in this repo, edit the files here and assume they are the source of truth. Do not look for or modify the "real" config under `~/.config`, `$HOME`, or other runtime locations unless explicitly asked or debugging a symlink/runtime issue.

## Principles

- Keep the configuration maintainable, portable, and easy to export to a new machine.
- Prefer simple, obvious changes over clever or machine-specific workarounds.
- Be cautious with new dependencies, pinned versions, absolute paths, local assumptions, or setup steps that are not documented.
- If a change requires an external tool, plugin, package manager, or manual setup, document that requirement close to the relevant config.
- Do not run linking/install commands or mutate files outside this repository unless explicitly requested.
- Do not revert unrelated local changes; this repo may have concurrent user edits.
