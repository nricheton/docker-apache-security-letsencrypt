#!/bin/bash
source /etc/apache2/envvars

# If Apache is already running (e.g. started by certbot during first-boot
# certificate request), stop the background daemon cleanly before supervisord
# takes over in foreground mode. Running two Apache instances would cause a
# port conflict and supervisord would mark the service as failed.
if [ -f /var/run/apache2/apache2.pid ]; then
    apachePid=$(cat /var/run/apache2/apache2.pid)
    if kill -0 "$apachePid" 2>/dev/null; then
        echo "Apache daemon already running (pid $apachePid), stopping before foreground handoff"
        apache2ctl stop 2>/dev/null || kill "$apachePid" 2>/dev/null || true
        sleep 1
    fi
    rm -f /var/run/apache2/apache2.pid
fi

exec /usr/sbin/apache2 -D FOREGROUND
