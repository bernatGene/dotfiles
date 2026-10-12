---
name: i18n
description: Internationalization guidelines for backend (Babel/gettext) and frontend (ParaglideJS)
---

## Backend (Babel/gettext)

All user-facing text must use translation functions. Translations stored in `backend/app/i18n/`.

## Frontend (ParaglideJS)

All user-facing text must use `m.key_name()` syntax. Messages defined in
`frontend/messages/[locale].json`.

Only edit the JSON message files. Do not manually edit, inspect, or regenerate
`frontend/src/lib/paraglide/` for normal message changes. The dev server/Vite
plugin creates the Paraglide message modules from the JSON files automatically.

For messages with arguments, use Paraglide message syntax in the JSON files and
call them with `m.key_name({ arg })` from code.
