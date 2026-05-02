#!/bin/bash
set -eu

echo "Starting entrypoint script, env=
$(env)"

export VNC_PORT=${VNC_PORT:-5900}

# turbovnc options
export DISPLAY=${DISPLAY:-:0}
export VNC_RESOLUTION=${VNC_RESOLUTION:-1280x800}
readonly DISPLAY_WITHOUT_HOST="${DISPLAY#*:}"
readonly DISPLAY_NUMBER="${DISPLAY_WITHOUT_HOST%%.*}"
if [[ ! "$DISPLAY_NUMBER" =~ ^[0-9]+$ ]]; then
  echo "DISPLAY must be in the form :<number> or :<number>.<screen>, got '$DISPLAY'" >&2
  exit 1
fi
export DISPLAY_NUMBER

# Docker restart preserves the container writable layer, including stale X locks.
# TurboVNC refuses to start if these are left behind by an unclean shutdown.
rm -f "/tmp/.X${DISPLAY_NUMBER}-lock" "/tmp/.X11-unix/X${DISPLAY_NUMBER}"
rm -f "$HOME"/.vnc/*":${DISPLAY_NUMBER}.pid"

if [ -n "${VNC_PASSWORD:-}" ]; then
  mkdir -p "$HOME/.vnc"
  echo "$VNC_PASSWORD" | vncpasswd -f > "$HOME/.vnc/passwd"
  chmod 0600 "$HOME/.vnc/passwd"
  export VNC_SEC=
else
  export VNC_SEC='-securitytypes TLSNone,X509None,None'
fi

# novnc options
export NOVNC_PORT="${NOVNC_PORT:-8080}"
export LOCALFBPORT=$((VNC_PORT + DISPLAY_NUMBER))

# prusaslicer options
export VGL_DISPLAY="${VGL_DISPLAY:-egl}"
if [ "${ENABLEHWGPU:-}" = 'true' ]; then
  export VGLRUN='vglrun'
else
  export VGLRUN=
fi

export SUPD_LOGLEVEL="${SUPD_LOGLEVEL:-debug}"
echo 'Finished entrypoint script, starting supervisord'
exec supervisord -e "$SUPD_LOGLEVEL"
