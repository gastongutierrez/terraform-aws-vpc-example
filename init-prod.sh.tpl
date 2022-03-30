#!/bin/bash

sudo apt update
sudo apt upgrade -y
sudo apt install nginx -y
sudo systemctl enable nginx
sudo echo "Production: ${availability_zone}" | sudo tee /var/www/html/index.nginx-debian.html
