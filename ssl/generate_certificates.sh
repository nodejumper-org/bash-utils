#!/bin/bash

# add new repo
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository universe
sudo apt update

# install certbot
sudo apt install -y certbot

# generate certs
sudo certbot certonly --standalone

# pem files will be there
/etc/letsencrypt/live/YOUR-DOMAIN-NAME

# for update certs
certbot renew
