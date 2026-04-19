---
name: i18n
description: Internationalization guidelines for backend (Babel/gettext) and frontend (ParaglideJS)
---

## Backend (Babel/gettext)

All user-facing text must use translation functions. Translations stored in `backend/app/i18n/`.

## Frontend (ParaglideJS)

All user-facing text must use `m.key_name()` syntax. Messages defined in
`frontend/messages/[locale].json`.

For messages with arguments, use paraglide. 
