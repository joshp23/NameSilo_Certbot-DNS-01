# NameSilo_Certbot-DNS-01
Autorenew LetsEncrypt wildcard certificates with Certbot DNS-01 on NameSilo DNS

This will add or renew the ACME DNS challenge record at NameSilo. 

### Using this script
Make sure that you have xmllint installed on your system. On Ubuntu just:
```
 $ apt-get install libxml2-utils
 ```
Then add your NameSilo API key to at the top of the script, create a writable `tmp` folder in the directory that this file is in, and call the file with Certbot.

There are two ways to call this script with Certbot:
1.  Call certbot using something like the following command
```
$ certbot renew -- manual-auth-hook /path/to/hook.sh
```
2.  add the following to either your Certbot config, or a specific domain renewal config in `/etc/Letsencrypt/renewal/domain.com.conf`
```
manual_auth_hook = /path/to/hook.sh
```
### For berevity
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
#### Note: There is a 15 minute wait for DNS propogation.

### Support Dev
All of my published code is developed and maintained in spare time, if you would like to support development of this, or any of my published code, I have set up a Liberpay account for just this purpose. Thank you.

<noscript><a href="https://liberapay.com/joshu42/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg"></a></noscript>
