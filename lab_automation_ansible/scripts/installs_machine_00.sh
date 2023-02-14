#! /bin/bash

apt update
apt install software-properties-common -y
add-apt-repository --yes --update ppa:ansible/ansible
apt install ansible -y
apt update

hostname 'mrRobot-01'
echo 'mrRobot-01' > /etc/hostname
bash