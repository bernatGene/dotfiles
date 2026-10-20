#!/bin/sh
# Requires macOS (lsappinfo), jq, tmux with `allow-passthrough all`
[ -n "$TMUX_PANE" ] || exit 0
input=$(cat)

title=$(printf %s "$input" | jq -r '.message // "Session ended"')
# pane title is Claude's session title prefixed by a status glyph
body=$(tmux display -p -t "$TMUX_PANE" '#{pane_title}' | sed 's/^[^ ]* //')

# Ghostty drops desktop notifications while it is the frontmost app
if lsappinfo info -only name "$(lsappinfo front)" | grep -q Ghostty; then
  [ "$(tmux display -p -t "$TMUX_PANE" '#{window_active}')" = 1 ] && exit 0
  tmux display-message -d 5000 "$title: $body"
  exit 0
fi

tty=$(tmux display -p -t "$TMUX_PANE" '#{pane_tty}')
printf '\033Ptmux;\033\033]777;notify;%s;%s\007\033\\' "$title" "$body" > "$tty"
