#!/bin/bash

DOMAINS_FILE="$LETSENCRYPT_HOME/.domains"

if ([ ! -d "$LETSENCRYPT_HOME" ] || [ ! "$(ls -A "$LETSENCRYPT_HOME")" ]) && [ -n "$DOMAINS" ]; then
  # First launch: init normally
  if ! echo "$DOMAINS" | grep -qE '^[a-zA-Z0-9._,:-]+$'; then
    echo "ERROR: DOMAINS contains invalid characters: $DOMAINS" >&2
    exit 1
  fi
  /run_letsencrypt.sh --domains "$DOMAINS"
  echo "$DOMAINS" > "$DOMAINS_FILE"

elif [ -n "$DOMAINS" ]; then
  # Subsequent launches: compare with previous state
  PREVIOUS_DOMAINS=$(cat "$DOMAINS_FILE" 2>/dev/null || echo "")
  if [ "$DOMAINS" != "$PREVIOUS_DOMAINS" ]; then
    echo "DOMAINS changed, updating certificate..."
    /run_letsencrypt.sh --domains "$DOMAINS"
    echo "$DOMAINS" > "$DOMAINS_FILE"
  fi
fi
