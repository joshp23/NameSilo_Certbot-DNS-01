# NameSilo_Certbot-DNS-01
Autorenew LetsEncrypt wildcard certificates with Certbot DNS-01 on NameSilo DNS

This will add or renew the DNS challenge record. There is a 15 minute wait for propogation.

There are two ways to use this:
1.  Call certbot using something like the following command
```
$ certbot renew -- manual-auth-hook /path/to/hook.sh
```
2.  add the following to either your Certbot config, or a specific domain renewal config in `/etc/Letsencrypt/renewal/domain.com.conf`
```
manual_auth_hook = /path/to/hook.sh
```
The domain renewal options tested with this hook auth are the following:
```
# Options used in the renewal process
[renewalparams]
server = https://acme-v02.api.letsencrypt.org/directory
rsa_key_size = 4096
pref_challs = dns-01,
manual_public_ip_logging_ok = True
account = YOUR_ACCOUNT_STRING
installer = None
authenticator = manual
manual_auth_hook = /path/to/hook.sh
```
This auth hook has not been tested for renewing specific subdomains, only wildcards.
