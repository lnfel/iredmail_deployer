#!/bin/bash

pflogsumm /var/log/mail.log -d yesterday --smtpd_stats --problems_first --rej_add_from --verbose_msg_detail > /root/summary.today
sed -n '8,12p' /root/summary.today > $HOSTNAME
sed -n '8,12p' /root/summary.today > $HOSTNAME.tech