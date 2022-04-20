#!/bin/sh

while getopts u:d:s:p:r:l: flag
do
    case "${flag}" in
        u) TARGET_USER=$OPTARG;;
        d) DOMAIN=$OPTARG;;
        s) SERVICES+=("$OPTARG");;
        p) PKCS12=true;;
        r) PKCS12_PASS=$OPTARG;;
        l) OUTPUT_DIR=$OPTARG;;
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

if [ -z "$PKCS12" ]; then
    PKCS12=false
else
    if [ "$PKCS12" = true ] && [ -z "$PKCS12_PASS" ]; then
        echo "ERROR: pkcs12 password not provided"
        exit 1
    fi
fi

if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="/opt/ssl"
fi

sudo mkdir -p "$OUTPUT_DIR"

sudo tee /etc/letsencrypt/renewal-hooks/deploy/apply_new_certs.sh > /dev/null <<EOF
CERTS_DIR="/etc/letsencrypt/live/$DOMAIN"
OUTPUT_DIR="$OUTPUT_DIR"
TARGET_USER="$TARGET_USER"
USER_GROUP="$(id -ng $TARGET_USER)"
SERVICES=($(IFS=$' '; echo "${SERVICES[*]}"))
PKCS12="$PKCS12"
PKCS12_PASS="$PKCS12_PASS"

sudo cp "\$CERTS_DIR/fullchain.pem" "\$OUTPUT_DIR/server_cert.pem"
sudo cp "\$CERTS_DIR/privkey.pem" "\$OUTPUT_DIR/server_key.pem"
sudo chown \$TARGET_USER:\$USER_GROUP "\$OUTPUT_DIR/server_cert.pem"
sudo chown \$TARGET_USER:\$USER_GROUP "\$OUTPUT_DIR/server_key.pem"

if [ "\$PKCS12" == "true" ]; then
    openssl pkcs12 -export -in \$OUTPUT_DIR/server_cert.pem -inkey \$OUTPUT_DIR/server_key.pem -out \$OUTPUT_DIR/keystore.p12 -password pass:\$PKCS12_PASS
fi

for service in "\${SERVICES[@]}"; do
    sudo systemctl restart \$service
    sleep 5
done
EOF

sudo chmod 750 /etc/letsencrypt/renewal-hooks/deploy/apply_new_certs.sh

echo "Installed for User: $TARGET_USER; Domain: $DOMAIN; After the certs renew, these services will be restarted: ${SERVICES[*]}; Will a PKCS12 key be generated: $PKCS12"
