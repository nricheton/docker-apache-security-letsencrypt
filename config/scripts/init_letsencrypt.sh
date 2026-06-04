#!/bin/bash

# init only if lets-encrypt is running for the first time and if DOMAINS was set
if ([ ! -d "$LETSENCRYPT_HOME" ] || [ ! "$(ls -A "$LETSENCRYPT_HOME")" ]) && [ -n "$DOMAINS" ]; then
  if ! echo "$DOMAINS" | grep -qE '^[a-zA-Z0-9._,:-]+$'; then
    echo "ERROR: DOMAINS contains invalid characters: $DOMAINS" >&2
    exit 1
  fi
  /run_letsencrypt.sh --domains "$DOMAINS"
fi
