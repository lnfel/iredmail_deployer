#!/usr/bin/env bash
# Created by Arman Jon Villalobos
# © 2017
# This script is for automating the installation part of iRedmail
# ./install.sh domainname.com

HOSTNAME=$1

# update system
ssh root@${HOSTNAME} "apt-get install && apt-get update"

# install rsync
ssh root@${HOSTNAME} "apt-get install rsync -y"

# copy authorized keys
rsync -r important_keys/authorized_keys root@${HOSTNAME}:/root/.ssh/ > /dev/null

# change hostname
echo 'setting up proper hostname'
ssh root@${HOSTNAME} "hostname ${HOSTNAME} > /dev/null"
ssh root@${HOSTNAME} "sed -i -e \"1d\" /etc/hostname"
ssh root@${HOSTNAME} "echo \"${HOSTNAME}\" > /etc/hostname"
ssh root@${HOSTNAME} "sed -i -e \"2d\" /etc/hosts"
ssh root@${HOSTNAME} "sed -i \"2i 127.0.1.1\t${HOSTNAME}\" /etc/hosts"

# copy iredmail folder
echo 'Copying iredmail folder...'
rsync -r iRedMail root@${HOSTNAME}:/root > /dev/null

# change iredmail config file
echo 'Changing the iredadmin config file...'
cp $PWD/iRedMail/config $PWD/iRedMail/${HOSTNAME}_config
sed -i s/univposts.com/${HOSTNAME}/g $PWD/iRedMail/${HOSTNAME}_config
rsync -r $PWD/iRedMail/${HOSTNAME}_config root@${HOSTNAME}:/root/iRedMail/config
rm $PWD/iRedMail/${HOSTNAME}_config

# install iredmail
echo 'Installing iredmail...'
ssh root@${HOSTNAME} "cd /root/iRedMail/ && AUTO_USE_EXISTING_CONFIG_FILE=y AUTO_INSTALL_WITHOUT_CONFIRM=y AUTO_CLEANUP_REMOVE_SENDMAIL=y AUTO_CLEANUP_REMOVE_MOD_PYTHON=y AUTO_CLEANUP_REPLACE_FIREWALL_RULES=y AUTO_CLEANUP_RESTART_IPTABLES=y AUTO_CLEANUP_REPLACE_MYSQL_CONFIG=y AUTO_CLEANUP_RESTART_POSTFIX=n bash iRedMail.sh"

# reboot
echo 'Rebooting...'
ssh root@${HOSTNAME} "reboot"