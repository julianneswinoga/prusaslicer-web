#!/bin/bash
set -eu

export VNC_PORT=${VNC_PORT:-5900}

# turbovnc options
export DISPLAY=${DISPLAY:-:0}
export VNC_RESOLUTION=${VNC_RESOLUTION:-1280x800}
if [ -n "${VNC_PASSWORD:-}" ]; then
  mkdir -p /root/.vnc
  echo "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd
  chmod 0600 /root/.vnc/passwd
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
exec gosu slic3r supervisord -e "$SUPD_LOGLEVEL"
