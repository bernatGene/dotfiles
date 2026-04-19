---
name: svelte
description: Svelte 5 development with runes, destructured props, and component reusability
---

## Svelte 5 Runes

- Use `$state()` for reactive state (variables that change)
- Use `$derived()` for computed values based on state
- Use `$effect()` sparingly - only for side effects that can't be handled by other means
- Prefer reactive declarations over effects where possible

## Component Props

- Always destructure props using `$props()`:
  ```svelte
  let { title, count = 0, onAction } = $props();
  ```
- Default values in destructuring, not with separate assignments
- Document complex prop types with JSDoc

## Component Reusability

- Check existing components before creating new ones
- Use fundamental UI components as building blocks (Button, Input, Card, etc.)
- Design for composition: small, focused components that work together
- Share layout patterns from similar views

## Avoid Complexity

- Keep components under ~150 lines
- Extract repeated patterns into smaller components
- Prefer simple prop passing over complex context usage
- Use slot composition over prop drilling for layout variations

## Project Structure

- Routes live in `frontend/src/routes/` following SvelteKit's file-based routing.
- `frontend/src/lib/client/sdk.gen.ts` is an auto-generated OpenAPI client. The file
  is massive and will pollute your context window. DO NOT READ THE FULL FILE - use offset
  read in the relevant scope only.
- `frontend/src/lib/components/ui/*.svelte` contains fundamental UI components.
  Always strive to reuse these instead of writing from scratch. Don't read the full
  directory - list files and read only the relevant ones you need.
