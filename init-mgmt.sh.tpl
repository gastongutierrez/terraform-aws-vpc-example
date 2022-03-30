#!/bin/bash

sudo apt update
sudo apt upgrade -y
sudo touch /home/ubuntu/.ssh/id_rsa
sudo chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa
sudo chmod 600 /home/ubuntu/.ssh/id_rsa
sudo echo "${private_key}" > /home/ubuntu/.ssh/id_rsa
