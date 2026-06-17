# Docker - Apache with Let's Encrypt

This is a debian-based image which runs an apache and get's it SSL-certificates automatically from Let's Encrypt.

## Instructions

### Prepare your apache-config

There are some things you have to care about in your apache-config if you want to use it with certbot:

- for every domain given in `DOMAINS` there must be a apache-vhost which uses this domain as `ServerName` or `ServerAlias`. Else certbot won't get a certificate for this domain.
- this image contains a simple apache webserver. Therefore you can configure your vhosts like you ever did.

### Run it

For an easy test-startup you just have to:

```
$ docker run -d --name apache-ssl nricheton/docker-apache-security-letsencrypt
```

Now you have locally an apache running, which gets it SSL-certificates from Let's Encrypt.

The image will get letsencrypt-certificates on first boot. A cron-job renews the existing certificates automatically, so you don't have to care about it.

If `DOMAINS` changes between container restarts, the certificate is automatically expanded on the next startup to include the new domains.

### Configuring docker-container

It's possible to configure the docker-container by setting the following environment-variables at container-startup:

- `DOMAINS`, configures which for which domains a SSL-certificate shall be requested from Let's Encrypt, default is `""`. Must be given as comma-seperated list, f.e.: `"example.com,my-internet.org,more.example.com"`.
- `WEBMASTER_MAIL`, Let's Encrypt needs a mail-address from the webmaster of the requested domain. You have to set it, otherwise Let's Encrypt won't give the certificates. Default is `""`. Must be given as simple mail-address, f.e.: `"webmaster@example.com"`.
- `STAGING`, if set with a not-null string use Let's Encrypt Staging environment to avoid rate limits during development.
- `NO_REDIRECT`, if set, certbot will not attempt to configure HTTP-to-HTTPS redirects automatically. Useful when a catch-all `VirtualHost *:80` already handles redirections for all domains.

### Location of letsencrypt-certs

After letsencrypt did authenticate your domains and you got your certificates, you'll find your certificates under `/etc/letsencrypt/live/<example.com>/`.

So your https-virtualhost should like:

```
<VirtualHost *:443>
    ServerName example.com
    ServerAdmin webmaster@somewhere.org
    DocumentRoot /var/www/html

    SSLCertificateFile /etc/letsencrypt/live/${VIRTUAL_HOST}/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/${VIRTUAL_HOST}/privkey.pem
    Include /etc/letsencrypt/options-ssl-apache.conf
</VirtualHost>
```
