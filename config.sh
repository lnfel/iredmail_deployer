#!/usr/bin/env bash
# Created by Arman Jon Villalobos
# © 2017

# This script is for automating the configuration part of iRedmail
# ./config.sh agouti.tech mailuniversitypost.com 3000

HOSTNAME=$1
SENDER_DOMAIN=$2
PER_HOUR_LIMIT=$3

# add alias for tailing mail logs
echo 'Adding alias for tailing mail logs...'
ssh root@${HOSTNAME} "echo \"alias tmlog='tail -f /var/log/mail.log'\" >> ~/.bashrc && source ~/.bashrc"

echo 'Adding mary user...'
ssh root@${HOSTNAME} "mysql -uroot -pblastaway2017 -e \"INSERT INTO mailbox (username, password, name, storagebasedirectory,storagenode, maildir, quota, domain, active, local_part, created, isadmin) VALUES ('mary@${HOSTNAME}', '{SSHA512}UivZV3+enYTIFaol5+gd+/dBnnwhX7l0B1WR6fq+nIm7YA/Rw8hCX7EH1TBYsfrHyDWtyuJc7DjSRg676y4OKmz3Xh3MeR6m', 'mary', '/var/vmail','vmail1', '${HOSTNAME}/a/l/e/mary-2016.08.30.18.39.14/', '1024', '${HOSTNAME}', '1','mary', NOW(), 1);\" vmail"
ssh root@${HOSTNAME} "mysql -uroot -pblastaway2017 -e \"INSERT INTO alias (address, goto, domain, created, active) VALUES ('mary@${HOSTNAME}', 'mary@${HOSTNAME}','${HOSTNAME}', NOW(), 1);\" vmail"

echo 'Adding horsestable user...'
ssh root@${HOSTNAME} "mysql -uroot -pblastaway2017 -e \"INSERT INTO mailbox (username, password, name, storagebasedirectory,storagenode, maildir, quota, domain, active, local_part, created, isadmin) VALUES ('horsestable@${HOSTNAME}', '{SSHA512}UivZV3+enYTIFaol5+gd+/dBnnwhX7l0B1WR6fq+nIm7YA/Rw8hCX7EH1TBYsfrHyDWtyuJc7DjSRg676y4OKmz3Xh3MeR6m', 'horsestable', '/var/vmail','vmail1', '${HOSTNAME}/a/l/e/horsestable-2016.08.30.18.39.14/', '1024', '${HOSTNAME}', '1','horsestable', NOW(), 1);\" vmail"
ssh root@${HOSTNAME} "mysql -uroot -pblastaway2017 -e \"INSERT INTO alias (address, goto, domain, created, active) VALUES ('horsestable@${HOSTNAME}', 'horsestable@${HOSTNAME}','${HOSTNAME}', NOW(), 1);\" vmail"

echo 'copying iredapd settings...'
rsync -r settings.py root@${HOSTNAME}:/opt/iredapd/ > /dev/null

echo 'restarting iredapd service...'
ssh root@${HOSTNAME} "service iredapd restart > /dev/null"

# require ipv4
ssh root@${HOSTNAME} "sed -i 's/inet_protocols = all/inet_protocols = ipv4/g' /etc/postfix/main.cf"
ssh root@${HOSTNAME} "sed -i 's/inet_protocols = ipv6/inet_protocols = ipv4/g' /etc/postfix/main.cf"

echo 'enabling the 5000 per hour email limit throttling...'
ssh root@${HOSTNAME} "mysql -uroot -pblastaway2017 -e \"INSERT INTO throttle (account, kind, priority, period, msg_size, max_msgs, max_quota) VALUES ('mary@${HOSTNAME}', 'outbound', 100, 3600, 0, ${PER_HOUR_LIMIT}, 0);\" iredapd"

echo 'copying the universal dkim key...'
rsync -r changeme.pem root@${HOSTNAME}:/var/lib/dkim/ > /dev/null
ssh root@${HOSTNAME} "mv /var/lib/dkim/changeme.pem /var/lib/dkim/${SENDER_DOMAIN}.pem"

echo 'setting up to use the universal dkim key...'
ssh root@${HOSTNAME} "sed -i '/^dkim_key(\"${HOSTNAME}\"/a dkim_key(\"${SENDER_DOMAIN}\", \"${SENDER_DOMAIN}\", \"/var/lib/dkim/${SENDER_DOMAIN}.pem\");' /etc/amavis/conf.d/50-user"
# ssh root@${HOSTNAME} "sed -i '0,/^dkim_key(\"${HOSTNAME}\"/{//d;}' /etc/amavis/conf.d/50-user"

echo 'restarting amavis service...'
ssh root@${HOSTNAME} "service amavis restart"

echo 'checking the dkim status...'
ssh root@${HOSTNAME} "amavisd-new testkeys"

echo 'installing pflogsum...'
ssh root@${HOSTNAME} "apt-get -y install pflogsumm"

echo 'changing time to los angeles'
# for some reason I need to run the reconfigure twice
ssh root@${HOSTNAME} "dpkg-reconfigure -f noninteractive tzdata"
ssh root@${HOSTNAME} "echo \"America/Los_Angeles\" > /etc/timezone"
ssh root@${HOSTNAME} "dpkg-reconfigure -f noninteractive tzdata"

echo 'configuring postfix for optimum sending performance'
ssh root@${HOSTNAME} "echo -e \"# Deliver the email within 4hrs, if can't drop the email\nmaximal_queue_lifetime = 4h\nmaximal_backoff_time = 15m\nminimal_backoff_time = 5m\nqueue_run_delay = 5m\" >> /etc/postfix/main.cf"

echo 'restarting postfix service...'
ssh root@${HOSTNAME} "service postfix restart > /dev/null"

echo 'installing vim...'
ssh root@${HOSTNAME} "apt-get -y install vim"
