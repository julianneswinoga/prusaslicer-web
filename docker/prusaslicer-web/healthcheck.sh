#!/bin/sh

# There isn't much documentation on the supervisord RPC interface...
# https://github.com/Supervisor/supervisor/blob/5732a41c3393b15c06b665c5aea30920a42b324b/supervisor/supervisorctl.py#L657
# Explicitly exit with 1 to comply with docker healthcheck:
# https://docs.docker.com/reference/dockerfile/#healthcheck
supervisorctl status || exit 1
