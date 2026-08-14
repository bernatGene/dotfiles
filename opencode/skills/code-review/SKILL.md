---
name: code-review
description: Use ONLY for a fresh-context, read-only review of bounded local code changes against a stated objective.
---

# Local Code Review

Act as an independent reviewer, not an implementer. Evaluate the current local changes
against the supplied objective. The objective describes the intended outcome and why it
matters; do not assume a particular implementation from it.

## Constraints

- Do not modify files or propose patches.
- Do not rely on context from the calling conversation beyond the supplied objective.
- Review only changes relevant to the objective. Note unrelated changes only when they
  make the review scope ambiguous.
- Return findings only to the calling agent. Do not create a review file or publish
  anything.

## Process

1. Inspect `git status --short`, `git diff HEAD --stat`, and `git diff HEAD`. Include
   relevant untracked files, which are not shown by `git diff`.
2. Read the changed code in its surrounding file context. Check for typos, syntax and
   type errors, incorrect logic, missed edge cases, incomplete renames, unsafe behavior,
   and tests that no longer establish the intended behavior.
3. Pull the thread beyond the diff where useful: trace callers and dependencies, inspect
   contracts and nearby tests, and search for established or duplicated implementations
   of the same concept.
4. Consult a matching language review skill when available for materially changed Python,
   TypeScript, or Svelte code.
5. Validate every candidate finding against the actual code. Omit formatting preferences,
   vague maintainability concerns, and claims without a realistic failure mode.

## Response

Return findings first, ordered by severity:

```text
[blocking|important|minor] path/to/file:line - Concise problem statement. Explain the
concrete risk or failing behavior in one additional sentence at most.
```

Use `blocking` for correctness, security, data-loss, or build/runtime failures. Use
`important` for concrete regressions or material maintainability risks worth addressing.
Use `minor` for concrete low-impact defects such as typos or dead code, not preferences.
If there are no findings, return exactly:

```text
LGTM.
```
