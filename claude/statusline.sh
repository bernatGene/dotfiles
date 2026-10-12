#!/bin/sh
# Requires jq
input=$(cat)
dir=$(echo "$input" | jq -r '.workspace.current_dir')
branch=$(git -C "$dir" branch --show-current 2>/dev/null)
echo "$input" | jq -r --arg b "$branch" \
  '"\(.model.display_name) | \($b) | \(.context_window.used_percentage // 0 | floor)% ctx"'
