---
name: python-dev
description: Python development practices using uv and ruff
---

# Python Dev Skill

## Tooling

- Use `uv` for all Python commands. Never `pip install`.
- Use `uvx ruff <command>` to run ruff directly without installation.
- ONLY IF ASKED TO CHECK OR FORMAT (usually ran automatically, not your concern):
  - Run linting: `uvx ruff check .`
  - Run formatting check: `uvx ruff format --check .`
  - Auto-fix: `uvx ruff check --fix .`

## Code Style

**Do not edit for formatting**; ruff is automatically ran in pre-commit:
  - formatting manually is a waste of context.

- snake_case for functions/variables, PascalCase for classes
- Strict type hints, never `from __future__ import typing`
- Python >= 3.12: use `list`, `dict` not `typing.List`
- Top-level imports only. No function-local imports unless:
  - Optional dependency
  - Circular import workaround
  - Measured startup issue (add a comment)

