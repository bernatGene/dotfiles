---
description: Independently review the current local changes
---

Review the bounded changes just made, without changing them.

Treat `$ARGUMENTS` as optional context about their objective. Derive the objective from
the current conversation and any arguments. State it as the intended outcome and why it
matters, in one short sentence. Do not describe the implementation or how it works.

Start exactly one fresh `terra` or `sol` subagent. Give it only this starting prompt:

```text
Load and follow the code-review skill.

Objective: <objective>

Review the current local changes against that objective. Do not modify any files. Return
only concise findings to the calling agent.
```

Wait for the subagent to finish. Do not immediately act on its findings. Check each
finding against the diff and relevant code, then report to the user:

- The review findings, kept concise and ordered by severity.
- Your assessment of each finding: agree, disagree, or uncertain, with a brief reason.
- If there are no valid findings, say so.

Do not edit files, apply fixes, or start another subagent. Stop and wait for the user to
decide which findings, if any, to address.
