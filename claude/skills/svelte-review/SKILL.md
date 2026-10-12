---
name: svelte-review
description: Svelte 5 and SvelteKit code review guidelines focusing on runes, derived state, streaming patterns, and server/client state management
---

# Svelte/SvelteKit Review Guide

Svelte 5, SvelteKit, Tailwind 4. For TypeScript issues also apply `ts-review`. Only flag
issues with a concrete failure mode or a clear deviation from these conventions.

## Runes

- `$derived`/`$derived.by` for computed values; never `$state` + `$effect` to keep a
  value in sync.
- `$effect` only for real side effects (DOM, timers, subscriptions), returning a cleanup
  function when it sets something up.
- User actions handled in event handlers, not effects reacting to flags.
- Values computed from props or `data` must be `$derived`; a plain `const` goes stale on
  client-side navigation because the component is reused.
- Typed, destructured `$props()` with defaults; `$bindable` only when the parent needs
  two-way binding.
- No stores; use runes (`.svelte.ts` modules for shared state).

## Server/Client State

- No module-level mutable state in server code (`+page.server.ts`, `hooks.server.ts`,
  `$lib/server`): it is shared across all requests and users.
- `load` returns data; it never writes to global or shared state.
- Filter/sort/pagination state that should survive a reload or be shareable lives in the
  URL (`page.url.searchParams` + `goto`).
- Generic components receive data via props, not `page.data`.

## Data Loading

- Independent requests in parallel (`Promise.all`), no waterfalls.
- Slow, non-critical data returned as un-awaited promises and rendered with `{#await}`
  and a skeleton.
- Form actions validate input and return `fail(status, data)`; forms use `use:enhance`.
- Refresh with `invalidate(dep)`/`invalidateAll()`, not manual refetching.

## Components

- Reuse `$lib/components` (especially `ui/`) before creating new components.
- Snippets (`{#snippet}`/`{@render}`), not slots.
- `<script lang="ts">` everywhere.
- `$lib/` imports; no relative `../` or `/src/` paths.
- Tailwind utilities for styling.
