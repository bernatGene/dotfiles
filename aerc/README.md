# aerc

[aerc](https://aerc-mail.org/) is a terminal email client. This directory
contains the tracked configuration and sanitized account template; the local
`accounts.conf` is intentionally ignored.

Consult the installed, version-matched documentation before changing configuration:

```sh
man aerc
man aerc-config
man aerc-accounts
man aerc-binds
man aerc-templates
```

For non-interactive inspection, use `MANPAGER=cat man <page>`. Search available aerc
pages with `apropos aerc`.

## Unread count

The account tab title (`aerc.conf`) only shows unreads in `INBOX`. The default
`.Unread` template variable sums all folders, which overcounts on Gmail because
`[Gmail]/All Mail` includes messages already present in `INBOX` and other
folders.

## Styleset

Unread messages are highlighted in orange (`#ffaa00`) in addition to the default
bold. The custom styleset lives in `stylesets/default` and is loaded via
`styleset-name = default` in `aerc.conf`.
