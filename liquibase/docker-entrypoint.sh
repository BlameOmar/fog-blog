#!/bin/bash
# This script is a customized version of upstream's docker-entrypoint.sh. It adds support for
# specifying the target database password using docker secrets, which are exposed as files rather
# than environment variables.
# TODO: Add support for *_PASSWORD_FILE env variables to upstream's docker-entrypoint.sh.
set -e

if [[ -n "${LIQUIBASE_COMMAND_PASSWORD_FILE}" ]]; then
  # shellcheck disable=SC2034
  LIQUIBASE_COMMAND_PASSWORD=$(cat "$LIQUIBASE_COMMAND_PASSWORD_FILE")
  export LIQUIBASE_COMMAND_PASSWORD
  unset LIQUIBASE_COMMAND_PASSWORD_FILE  # To avoid complaints about invalid environment variables.
fi

if [[ "$INSTALL_MYSQL" ]]; then
  lpm add mysql --global
fi

if [[ "$1" != "history" ]] && type "$1" > /dev/null 2>&1; then
  ## First argument is an actual OS command (except if the command is history as it is a liquibase command). Run it
  exec "$@"
else
  if [[ "$*" == *--defaultsFile* ]] || [[ "$*" == *--defaults-file* ]] || [[ "$*" == *--version* ]]; then
    ## Just run as-is
    exec /liquibase/liquibase "$@"
  else
    ## Include standard defaultsFile
    exec /liquibase/liquibase "--defaultsFile=/liquibase/liquibase.docker.properties" "$@"
  fi
fi
