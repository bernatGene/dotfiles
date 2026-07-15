# Subagent Model Routing

Choose the least expensive subagent likely to complete the task reliably.

- Use `explore` for focused local codebase searches.
- Use `luna` for focused read-only research involving documentation or the web.
- Prefer `terra` for normal delegated implementation, investigation, and analysis.
- Use `sol` only for difficult, ambiguous, security-sensitive, architectural, or
  deeply cross-cutting work.
- Use `general` when its broad general-purpose workflow is specifically useful.
- Do not use a Sol-tier agent for simple searches or mechanical tasks.
