---
name: ts-review
description: TypeScript code review guidelines focusing on type safety, strict mode edge cases, async patterns, and code complexity
---

# TypeScript Code Review Guide

Only flag issues with a concrete failure mode or a clear deviation from these
conventions. Formatting is handled by tooling.

## Type Safety

- No `as` to cast unvalidated data or silence errors; validate instead (`unknown` + type
  guard, or Zod). `as` is fine inside a type guard and for `as const`.
- No `any`; use `unknown` and narrow.
- `!` non-null assertions only with a comment justifying them.
- No `@ts-ignore`; `@ts-expect-error` with a reason.
- Union types or `as const` objects over `enum`.
- Discriminated unions handled with an exhaustive `switch`
  (`const _exhaustive: never = value` in `default`).

## Strict Mode

- `noUncheckedIndexedAccess`: handle `T | undefined` from indexed access.
- `exactOptionalPropertyTypes`: omit optional properties instead of assigning
  `undefined`.

## Async

- No floating promises: `await`, `.catch()`, or `void` with a reason.
- No `async` callbacks in `forEach`; `for...of` for sequential, `Promise.all` for
  concurrent.
- `Promise.all` (fail fast) vs `Promise.allSettled` (partial results) chosen
  deliberately.
- Superseded requests cancelled with `AbortController` (e.g. search as you type).
- Event listeners, intervals and subscriptions cleaned up.

## General

- Early returns over nesting.
- Extract logic duplicated across branches; don't split into helpers for its own sake.
- Don't mutate function arguments; `readonly` for array/object parameters where it
  matters.
- `===`/`!==` only.
- Throw `Error` instances, never primitives.
- `find`/`filter` inside loops over large arrays: use a `Map`/`Set` lookup.
- No dead code (unused imports, commented-out blocks).
- Booleans named as predicates (`isActive`, `hasPermission`).
