FROM debian:bookworm-slim
MAINTAINER Nicolas Richeton <nicolas.richeton@gmail.com>

ENV DEBIAN_FRONTEND=noninteractive
ENV LETSENCRYPT_HOME=/etc/letsencrypt
ENV DOMAINS=""
ENV WEBMASTER_MAIL=""
ENV BLOCKED_COUNTRIES=""

# Base setup
RUN apt-get -y update && \
    apt-get -y dist-upgrade && \
    apt-get install -q -y \
        curl apache2 dumb-init \
        supervisor cron rsyslog && \
    apt-get install -q -y python3-certbot-apache && \
    # Add modsecurity
    apt-get install -q -y --no-install-recommends libapache2-mod-security2 modsecurity-crs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# configure apache
ADD config/mods-available/proxy_html.conf /etc/apache2/mods-available/
ADD config/conf-available/security.conf /etc/apache2/conf-available/
RUN echo "ServerName localhost" >> /etc/apache2/conf-enabled/hostname.conf && \
    a2enmod ssl headers proxy proxy_http proxy_html xml2enc rewrite usertrack remoteip && \
    a2dissite 000-default default-ssl && \
    mkdir -p /var/lock/apache2 /var/run/apache2 /var/cache/geoip-block

# scripts
ADD config/scripts/run_apache.sh /etc/service/apache/run
ADD config/scripts/init_letsencrypt.sh /init_letsencrypt.sh
ADD config/scripts/init_geoip.sh /init_geoip.sh
ADD config/scripts/update_geoip.sh /update_geoip.sh
ADD config/scripts/run_letsencrypt.sh /run_letsencrypt.sh
ADD config/scripts/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /*.sh /etc/service/apache/run

ADD config/crontab /etc/crontab

# supervisor + syslog
ADD config/supervisord.conf /etc/supervisord.conf
ADD config/rsyslog.conf /etc/rsyslog.conf
RUN mkdir -p /var/log/supervisor/

EXPOSE 80
EXPOSE 443

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/docker-entrypoint.sh"]

#VOLUME [ "$LETSENCRYPT_HOME", "/etc/apache2/sites-available", "/var/log/apache2" ]
# Accept any HTTP response (including 302/403) as healthy — Apache just needs to be up.
# start-period=120s covers the initial Let's Encrypt certificate request on first boot.
# Redirect all curl output to /dev/null to keep healthcheck logs clean.
HEALTHCHECK --interval=30s --timeout=5s --start-period=120s --retries=5 \
  CMD curl -s --max-time 5 -o /dev/null http://localhost/ >/dev/null 2>&1 || \
      curl -sk --max-time 5 -o /dev/null https://localhost/ >/dev/null 2>&1 || exit 1
