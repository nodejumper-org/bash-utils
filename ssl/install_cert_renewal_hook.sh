#!/bin/sh

while getopts u:d:s:p: flag
do
    case "${flag}" in
        u) TARGET_USER=$OPTARG;;
        d) DOMAIN=$OPTARG;;
        s) SERVICES+=("$OPTARG");;
        p) PKS12=true;;
    esac
done

if [ -z "$TARGET_USER" ]; then
    TARGET_USER=$USER
fi

if [ -z "$DOMAIN" ]; then
    echo "ERROR: domain name not provided"
    exit 1
fi

if [ -z "$SERVICES" ]; then
    echo "ERROR: services not provided"
    exit 1
fi

if [ -z "$PKS12" ];then
    PKS12=false
fi

mkdir -p "$(eval echo ~$USER)/.ssl"

sudo tee /etc/letsencrypt/renewal-hooks/deploy/apply_new_certs.sh > /dev/null <<EOF
CERTS_DIR="/etc/letsencrypt/live/$DOMAIN"
NEW_CERTS_DIR="$(eval echo ~$USER)/.ssl"
TARGET_USER="$TARGET_USER"
USER_GROUP="$(id -ng $TARGET_USER)"
SERVICES=($(IFS=$' '; echo "${SERVICES[*]}"))

cp "\$CERTS_DIR/fullchain.pem" "\$NEW_CERTS_DIR/server_cert.pem"
cp "\$CERTS_DIR/privkey.pem" "\$NEW_CERTS_DIR/server_key.pem"
chown \$TARGET_USER:\$USER_GROUP "\$NEW_CERTS_DIR/server_cert.pem"
chown \$TARGET_USER:\$USER_GROUP "\$NEW_CERTS_DIR/server_key.pem"

for service in "\${SERVICES[@]}"; do
    sudo systemctl restart \$service
    sleep 5
done
EOF

chmod 750 /etc/letsencrypt/renewal-hooks/deploy/apply_new_certs.sh

echo "Installed for User: $TARGET_USER; Domain: $DOMAIN; After the certs renew, these services will be restarted: $SERVICES; Will a PKS12 key be generated: $PKS12"
