#!/bin/bash

if [ -z "$WEBMASTER_MAIL" ]; then
  echo "ERROR: WEBMASTER_MAIL is not set" >&2
  exit 1
fi
if ! echo "$WEBMASTER_MAIL" | grep -qE '^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$'; then
  echo "ERROR: WEBMASTER_MAIL is not a valid email address" >&2
  exit 1
fi

if [ -n "$STAGING" ]; then
  echo "Using Let's Encrypt Staging environment..."
  certbot -n --staging --expand --apache --agree-tos --email "$WEBMASTER_MAIL" "$@"
else
  echo "Using Let's Encrypt Production environment..."
  certbot -n --expand --apache --agree-tos --email "$WEBMASTER_MAIL" "$@"
fi
