# What problem does it solve
This script enable ssl cert autorenewal and restarting your services if needed

# How to use

```
cd && wget https://raw.githubusercontent.com/nodejumper-org/bash-utils/main/ssl/install_cert_renewal_hook.sh && \
bash install_cert_renewal_hook.sh -u USER -d DOMAIN -s SERVICE_NAME1 -s SERVICE_NAME2 -p
```

Arguments:
```
-u - target user (optional, current user by default)
-d - domain name
-s - service to be restarted after each ssl certificate renewal, you can pass multiple service names
```
