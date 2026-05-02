#!/bin/bash
set -eu

echo "Waiting for X display ${DISPLAY}"
until xdpyinfo -display "$DISPLAY" >/dev/null 2>&1; do
  sleep 0.25
done
echo "X display ${DISPLAY} is ready"

# Unquoted VGLRUN so an empty value disappears and we don't run a wrapper.
exec $VGLRUN prusa-slicer --datadir /configs/.config/PrusaSlicer/
