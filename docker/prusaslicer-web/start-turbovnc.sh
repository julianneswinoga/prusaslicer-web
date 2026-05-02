#!/bin/bash
set -eu

readonly DISPLAY_NUMBER="${DISPLAY_NUMBER:?DISPLAY_NUMBER must be set by the entrypoint}"

# Ensure every supervisor restart owns a clean display.  This handles both
# orphaned Xvnc processes and stale lock files left by unclean shutdowns.
vncserver -kill "$DISPLAY" >/dev/null 2>&1 || true
rm -f "/tmp/.X${DISPLAY_NUMBER}-lock" "/tmp/.X11-unix/X${DISPLAY_NUMBER}"
rm -f "$HOME"/.vnc/*":${DISPLAY_NUMBER}.pid"

# Unquoted VNC_SEC so an empty value disappears and a non-empty multi-word
# option splits into normal arguments.
exec vncserver "$DISPLAY" -fg $VNC_SEC -wm lxqt -depth 24 -geometry "$VNC_RESOLUTION" -desktop "Prusaslicer"
