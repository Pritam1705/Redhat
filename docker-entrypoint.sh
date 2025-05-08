#!/bin/sh
set -e

# If the first argument starts with a dash or isn't a system command, prepend "mvn" to the command
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ]; then
  set -- mvn "$@"
fi

exec "$@"
