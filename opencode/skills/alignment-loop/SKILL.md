---
name: alignment-loop
description: One-question-at-a-time alignment method for clarifying a draft plan before finalizing it. Use only when explicitly requested.
---

# Alignment Loop

Use only when the user explicitly asks to start an alignment loop/method. This is for
the drafting stage of a plan: when the rough direction exists, but scope, implementation
details, edge cases, tradeoffs, or style expectations may still be fuzzy. Do not
implement changes while this loop is active.

## Process

1. Silently identify the highest-impact unclear area.
2. Ask exactly one focused question. Numerate the questions. Tangents get suffixes.
3. Stay on that question until the answer is clear.
4. If the user pushes back, asks a question, or gives an ambiguous answer, resolve that
   thread before moving on.
5. Briefly record the decision, then choose the next most important uncertainty.
6. After about every 10 resolved questions, summarize decisions so far and list major
   remaining fuzzy areas.
7. Stop when the important uncertainties are resolved.
8. Say that the scope is clear enough, summarize the final decisions, and propose moving
   on to finalizing the plan.

Keep narrowing uncertainty rather than asking questions forever. Focus on decisions
needed for a good plan: scope boundaries, non-goals, behavior, edge cases, verification,
dependencies, and preferred implementation style.

Secondary objective during the loop is to reduce complexity and redundancy. Internally,
we must think; is this really necessary this way? Does a very similar function or module
already exist? Does this need to be added or are we future proofing for the sake of it
(YAGNI...), etc. If there is a candidate for reducing complexity, that becomes a
question of the process. 

You can push back if you definitely don't agree, if you see a contradiction in my
answers, or if you notice a derailment. Still, you can't disagree forever.

You can pause and search the repo for context and relevant files at any point, if
necessary. If during the discussion we discover part of what we said doesn't apply, or
the plan changes direction heavily, we may start over by clearly stating what does not
apply anymore. 

Avoid _bikeshedding_. Do not spend turns on naming, formatting, micro-style, or
equivalent implementation choices unless they materially affect the plan or the user
explicitly cares.
