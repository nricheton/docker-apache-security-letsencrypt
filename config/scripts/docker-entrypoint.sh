#!/bin/bash
set -e

# Run one-time Let's Encrypt initialization (no-op if already done or DOMAINS not set)
/init_letsencrypt.sh

# Hand off to supervisord which manages apache, cron, rsyslog
exec supervisord -n -c /etc/supervisord.conf
