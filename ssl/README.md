# What problem does it solve
This script enable ssl cert autorenewal and restarting your services if needed. The certificate files will appear in the `~/.ssl` directory.

# How to use

Copy this code to your terminal and change an arguments
```
cd && wget https://raw.githubusercontent.com/nodejumper-org/bash-utils/main/ssl/install_cert_renewal_hook.sh && \
bash install_cert_renewal_hook.sh -u USER -d DOMAIN -s SERVICE_NAME1 -s SERVICE_NAME2 -p
```

Arguments:
```
-u - target user (optional, current user by default)
-d - domain name
-s - a service name that will be restarted after every ssl certificate renewal, you can pass this argument multiple times 
-p - generate PKS12 file (optional, false by dafault)
```

After running the script lets install cron job for run renew twice a day. Use random minute instead of 34
```
crontab -l | { cat; echo "34 0,12 * * * /usr/bin/certbot renew >> /var/log/certbot_renew.log"; } | crontab -
```

And configure logrotate for certbot renew logs
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

