#!/bin/bash
# Daily cron wrapper for GeoIP CIDR list refresh.
# Reads the country list from the state file written by init_geoip.sh at startup
# (cron does not inherit Docker environment variables).
# Downloads are only triggered when cache files are older than MAX_AGE_DAYS (7 days).
# Apache is reloaded only if the blocking rules were actually updated.

CACHE_DIR=/var/cache/geoip-block
GEOIP_BLOCK_CONF=/etc/apache2/conf-enabled/geoip-block.conf

if [ ! -f "$CACHE_DIR/.countries" ]; then
    echo "GeoIP: no country list found — geo-blocking was not configured at startup"
    exit 0
fi

export BLOCKED_COUNTRIES=$(cat "$CACHE_DIR/.countries")
echo "GeoIP: daily check for: $BLOCKED_COUNTRIES"

# Record conf modification time before update
CONF_BEFORE=$(stat -c %Y "$GEOIP_BLOCK_CONF" 2>/dev/null || echo 0)

if /init_geoip.sh; then
    CONF_AFTER=$(stat -c %Y "$GEOIP_BLOCK_CONF" 2>/dev/null || echo 0)
    if [ "$CONF_AFTER" != "$CONF_BEFORE" ]; then
        apache2ctl graceful
        echo "GeoIP: Apache reloaded with updated rules"
    else
        echo "GeoIP: rules unchanged, Apache reload skipped"
    fi
else
    echo "GeoIP: update failed, keeping existing rules" >&2
fi
