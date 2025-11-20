#!/bin/bash
set -eu

echo "Starting entrypoint script, env=
$(env)"

export VNC_PORT=${VNC_PORT:-5900}

# turbovnc options
export DISPLAY=${DISPLAY:-:0}
export VNC_RESOLUTION=${VNC_RESOLUTION:-1280x800}
if [ -n "${VNC_PASSWORD:-}" ]; then
  mkdir -p "/$HOME/.vnc"
  echo "$VNC_PASSWORD" | vncpasswd -f > "/$HOME/.vnc/passwd"
  chmod 0600 "/$HOME/.vnc/passwd"
  export VNC_SEC=
else
  export VNC_SEC='-securitytypes TLSNone,X509None,None'
fi


DISPLAY_NUMBER=$(echo "$DISPLAY" | cut -d: -f2)

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

export SUPD_LOGLEVEL="${SUPD_LOGLEVEL:-TRACE}"
echo 'Finished entrypoint script, starting supervisord'
exec supervisord -e "$SUPD_LOGLEVEL"
