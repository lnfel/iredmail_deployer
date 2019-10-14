# iRedmail Deployer
---
The goal of this repo is to automate the process of installing iRedmail with
the common setup/configuration we are doing when we are setting it up. 

There are two steps on this process, Installing and Configuration, below are the
steps I usually take when I used the scripts in this repo.

### Steps:
1. Determine what domain you want to use as an smtp.

2. Pick a VPS where you want to install, make sure it's Ubuntu 14.04 x64.
Rebuild/Reinstall if necessary. Once the VPS is set up, verify that the IP address is not blacklisted. Check it on http://www.anti-abuse.org/multi-rbl-check/

2. Got to DNSMadeEasy and assign the VPS IP to the domain (Create an A record)
3. Ping the domain you pick in Step #1.

4. Login to `monitoring.univposts.com` server

5. Goto the `iredmail_deployer` folder

6. SSH to your domain you pick in Step #1 to make sure you can access it with the
correct password.

7. When you're login run `apt-get update` command to update repositories

8. Exit the SSH session and go back to the `iredmail_deployer` folder in
`monitoring.univposts.com`.

9. Run the `install.sh` script with `./install.sh <smtp domain>`
e.g. `./install.sh example.com`

10. Enter the password when required.

11. After the installation, your server/smtp will restart. Wait for it to be online
and SSH again to the server.
NOTE: You should not be required to enter a password anymore, if it requires
you, there's someting wrong with your installation.

12. When logged in, run the following command to check if these services are running:
  - `service mysql status`
  - `service postfix status`
  - `service amavis status`
If all are running, then you're good to go on the configuration part of the setup.

13. Exit your server and go back to `iredmail_deployer` folder

14. Determine what domain you want to use for your sender e.g. mary@univmails.com
then the sender domain is univmails.com

15. Goto DNSMadeEasy and add the following text to the TXT records of your sender
domain. Replace "example.com", with your sender domain.

Name
>
  example.com._domainkey
  
Value
>
  "v=DKIM1; p=""MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsy4dmfRXeReo1xMyKt6r""uJoOuTnZjeOkQs/iCc6d06RkAi59feEQScyHHFfgZIsBHIq9hmKQKjgDiMD7Djzk""61BBnumd0YOsfwMMDu9v6ml3jn1z5Kz1wv749KTaIaGKlR/V+xlr19ICHZBGj6sr""MRkaxNjbgF+7rlHUF4Xxltq4/Wd4lbs+gB+9Yp2MD5tgKC3RRUjV09jGk2AAi0Xy""XNI3Ag7OjJjLO8nMcpA5r19g/9vdXM5CTpz0VYM+tVkSUPAn+/Dh+kLah54o49gT""Sh4OC41PbWtBww3l9/UBoOPFl2xVKVGCMJ1do+rtAiXYfHwBC2cD7a9Jk0VjyLON""mQIDAQAB"

Continuation:

16. Add also the IP of your smtp server to the the SPF record for the sender domain, just add ip4:123.123.123.123, where the 123.123.123 is your IP address.

17. Run `./config.sh <smtp domain> <sender domain>` e.g. `./config.sh example.com univmails.com`

18. SSH again in your server and run `amavisd-new testkeys`, you should see one
with "pass"

19. Run `tail -f /var/log/mail.log` to monitor your log file while you test your
smtp with sendy.

The usual credentials when an SMTP is setup are as follows:
  - host: yoursmtpdomain.com
  - username: mary@yoursmtpdomain.com
  - password: blastaway2016
  - port: 587
  - tls

20. Send yourself a sample email from sendy and check the email if SPF and DKIM
are passing.

THAT'S IT, YOU HAVE NOW A FUNCTIONING SMTP READY!

---

### Replacing ineffective SMTPs
SMTPs with bad sending stats must be recognized, investigated, and in some cases redeployed, these are the things you
should keep an eye out for when looking into an SMTPs underperformance:

1. When was that SMTP last deployed
2. Can the SMTP send email (test by sending one to yourself or /check_smtp_status script
3. Does it have a high mail queue count? Maybe the deferred mails just need to be cleared?
4. How long has it been underperforming (Usually if its been underperforming for 3 consecutive days it needs to be redeployed)
5. How is it's send stat compared to its current throttle limit (not that sendy 1-4 send between 3x and 8x its limit and sendy 7-8 send 10x a day


---

### Replacing blocked VPS
On replacing our servers when an IP is blocked/suspended/blacklisted, we don't 
change the domain. We just change the IP in DnsmadeEasy, point it to the updated
IP. This way we don't have to update our scripts which depends on the domains we
already setup.


Workflow when an IP is blocked:

1. Cancel the vps where the IP is blocked.
2. Buy a new vps OR login to existing fresh vps(no iredmail, no domain associated)
3. Assign the vps IP to the blocked domain in dnsmadeeasy
4. Use the iredmail_deployer script again to install a new smtp

With this workflow, we dont have to change the following:

1. We don't need to update Sendy since it's the same configuration
2. We don't need to change the domains in our SMTP Health Check scripts
3. We don't need to change the domains in our reporting
