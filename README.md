## iRedmail Deployer
This repo host the script automator for installing an iRedmail instance. There
are two steps on this process: 1. Installation, 2. Configuration.

## Step by Step Guide (Digital Ocean Setup)

1. Pick a domain to use for SMTP.

2. Install a Ubuntu 14.04x64, make sure you don't add any SSH key options.

3. You will get a password email from DigitalOcean to aj@berkelist.com, take note of that.

4. Check the IP reputation at http://www.anti-abuse.org/multi-rbl-check/. Proceed if there is no blacklist record, if not. Wait for 5mins and create a new droplet to get a new IP.

5. Go to DNSMadeEasy and create an A record for your chosen domain for the SMTP.

6. Login to monitoring server with `ssh root@monitoring.univposts.com`.

7. Go to *iredmail_deployer* folder.

8. Once inside, ssh to your smtp droplet first to check that you can access it.

9. You'll be ask to change the password, change it to our universal one.

10. Exit the droplet.

11. Run the installation script with `./install.sh smtp_domain`, enter updated password when required.

12. After the installation, your server/smtp will restart. Wait for it to be online and SSH again to the server.

NOTE: You should not be required to enter a password anymore, if it requires
you, there's someting wrong with your installation.

13. When logged in, run the following command to check if these services are running:

  - `service mysql status`

  - `service postfix status`

  - `service amavis status`

If all are running, then you're good to go on the configuration part of the setup.

14. Exit your server and go back to `iredmail_deployer` folder.

15. Determine what domain you want to use for your sender e.g. mary@univmails.com

16. Goto DNSMadeEasy and add the following text to the TXT records of your sender domain. Replace "example.com", with your sender domain.

Name
>
  example.com._domainkey
  
Value
>
  "v=DKIM1; p=""MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsy4dmfRXeReo1xMyKt6r""uJoOuTnZjeOkQs/iCc6d06RkAi59feEQScyHHFfgZIsBHIq9hmKQKjgDiMD7Djzk""61BBnumd0YOsfwMMDu9v6ml3jn1z5Kz1wv749KTaIaGKlR/V+xlr19ICHZBGj6sr""MRkaxNjbgF+7rlHUF4Xxltq4/Wd4lbs+gB+9Yp2MD5tgKC3RRUjV09jGk2AAi0Xy""XNI3Ag7OjJjLO8nMcpA5r19g/9vdXM5CTpz0VYM+tVkSUPAn+/Dh+kLah54o49gT""Sh4OC41PbWtBww3l9/UBoOPFl2xVKVGCMJ1do+rtAiXYfHwBC2cD7a9Jk0VjyLON""mQIDAQAB"

17. Add an SPF Record in the TXT area. Put blank in the name, and add an `ip4:<your droplet ip>` before the include.

Example of spf record
```
"v=spf1 ip4:159.65.66.8 include:_spf.google.com ~all"
```

18. Run `./config.sh <smtp domain> <sender domain> <per hour limit>` e.g. `./config.sh example.com univmails.com 5000`

19. SSH again in your server and run `amavisd-new testkeys`, you should see one with "pass"

20. Run `tail -f /var/log/mail.log` to monitor your log file while you test your smtp with sendy.

The usual credentials when an SMTP is setup are as follows:
  - host: yoursmtpdomain.com
  - username: mary@yoursmtpdomain.com
  - password: blastaway2016
  - port: 587
  - tls

21. Send yourself a sample email from sendy and check the email if SPF and DKIM are passing.  Note: Be sure that the sender domain email is either redirecting to a live website (e.g., http://google.com) or has an a record pointing to a live server.  Otherwise, the email won't get through, and you'll see this error message on the tail log on the smtp. 

THAT'S IT, YOU HAVE NOW A FUNCTIONING SMTP READY!
