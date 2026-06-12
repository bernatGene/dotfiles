---
name: read-plan
description: Read current plan to gather context and resume operations.
---

## Reading a Plan File

When resuming work or joining an existing session, read the latest plan file to
understand the current state. Do NOT act on the plan yet - only acknowledge what was
read.

**How to identify the latest plan:**

You MUST identify the current plan by running exactly this read-only command from the
workspace root:

```sh
ls -1t PLAN_*.md | head -n 1
```

The single path printed by that command is the ONLY plan file you may read for this skill.

Do NOT:
- read multiple PLAN_*.md files
- compare plans
- infer the current plan from filenames
- read older plans for context
- use glob results as a substitute for the command above

If the command prints no file, report that no PLAN_*.md file exists and stop.

*What to do:**

1. Read the content of the latest plan file
2. Extract key information: objective, current state, in-progress items, open questions
3. Acknowledge what was read with a brief summary
4. Wait for user direction before taking any action
