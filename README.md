# NameSilo_Certbot-DNS-01
Autorenew LetsEncrypt wildcard certificates with Certbot DNS-01 on NameSilo DNS

This script can be added to Certbot in order to automate wildcard certificate validation with DNS.
There are two ways to use this:
1.  Call certbot using something like the following command
```
$ certbot renew -- manual-auth-hook /path/to/hook.sh
```
2.  add the following to either your Certbot config, or a specific domain renewal config in `/etc/Letsencrypt/renewal/domain.com.conf`
```
manual_auth_hook = /path/to/hook.sh
```
This auth hook will not work for renewing specific subdomains.
