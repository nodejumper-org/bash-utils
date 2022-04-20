# What problem does it solve
This script enables ssl cert autorenewal and restarts your services, if needed. The certificate files will appear in the `/opt/ssl` directory.

# How to use

Copy this code to your terminal and change the arguments
```
cd && wget https://raw.githubusercontent.com/nodejumper-org/bash-utils/main/ssl/install_cert_renewal_hook.sh && \
bash install_cert_renewal_hook.sh -u USER -d DOMAIN -s SERVICE_NAME1 -s SERVICE_NAME2 -p -r pkcs12pass
```

Arguments:
```
-u - target user (optional, current user by default)
-d - domain name
-s - a service name that will be restarted after every ssl certificate renewal, you can pass this argument multiple times 
-p - generate PKCS12 file (optional, false by dafault)
-r - PKCS12 file password, required if -p option is set
-l - renewed pem and PKCS12 files output dir (optional, `/opt/ssl` by default)
```

After running the script schedule a cron job to run renewal twice a day. Use random minute instead of 34
```
crontab -l | { cat; echo "34 0,12 * * * /usr/bin/certbot renew >> /var/log/certbot_renew.log"; } | crontab -
```

And configure logrotate for certbot renewal logs
```
sudo tee /etc/logrotate.d/certbot_renew > /dev/null << EOF
/var/log/certbot_renew.log {
    su root root
    copytruncate
    daily
    missingok
    rotate 7
}
EOF

logrotate /etc/logrotate.d/certbot_renew
```

