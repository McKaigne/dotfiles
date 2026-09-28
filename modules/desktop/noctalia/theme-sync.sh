#!/bin/sh
set -eu

# 1. Reload Niri compositor colors via IPC
if command -v niri >/dev/null 2>&1; then
  niri msg action load-config-file || true
fi

# 2. Refresh active Tmux statusbars
if command -v tmux >/dev/null 2>&1; then
  tmux source-file -q ~/.config/tmux/themes/noctalia.conf 2>/dev/null || true
  tmux source-file -q ~/.config/tmux/noctalia/colors.conf 2>/dev/null || true
  tmux source-file -q ~/.config/tmux/noctalia.conf 2>/dev/null || true
  tmux refresh-client -S 2>/dev/null || true
fi

# 3. Reload Qutebrowser config if running
if pgrep -x qutebrowser >/dev/null 2>&1; then
  qutebrowser ":config-source" 2>/dev/null || true
fi

# 4. Rebuild Bat binary cache if template exists
if command -v bat >/dev/null 2>&1; then
  bat cache --build 2>/dev/null || true
fi
