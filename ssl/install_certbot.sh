#!/bin/bash

# add repository
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository universe
sudo apt update

# install certbot
sudo apt install -y certbot
