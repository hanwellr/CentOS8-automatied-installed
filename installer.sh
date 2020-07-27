#! /bin/bash
## RObert Hanwell 202 Postfix and dovecote round clube php 7.4 httpd install.
LOGFILE=installer.log
dbpostfix="user = postfix_admin\npassword = This is a Password\nhosts = 127.0.0.1\ndbname = postfix_accounts"
dbdomain="query = SELECT 1 FROM domains_table WHERE DomainName='%s'"
dbuser="query = SELECT 1 FROM accounts_table WHERE Email='%s'"
dbalias="query = SELECT Destination FROM alias_table WHERE Source='%s'"
sudo hostnamectl set-hostname lola.hanwell.website
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
echo "start update" >> $LOGFILE
sudo dnf update -y
sudo dnf install postfix postfix-mysql httpd vim firewalld policycoreutils-python-utils epel-release dovecot dovecot-mysql -y
echo "postfix installed" >> $LOGFILE
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
sudo yum -y install https://rpms.remirepo.net/enterprise/remi-release-8.rpm
sudo dnf -y install dnf-utils
sudo dnf module install php:remi-7.4 -y
sudo dnf update -y
sudo yum install php-7.4 -y
echo "php 7.4 installed" >> $LOGFILE
sudo php -v
echo "php version check " >> $LOGFILE
sudo tee /etc/yum.repos.d/MariaDB.repo<<EOF
[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.4/centos8-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1
EOF
sudo dnf install boost-program-options -y
sudo dnf install MariaDB-server MariaDB-client --disablerepo=AppStream -y
sudo systemctl enable --now mariadb
sudo mysqladmin --user=root password '3df5fbd892!'
sudo mysql --user=root --password=3df5fbd892! < databasesetup.sql
sudo sudo firewall-cmd --list-all
sudo firewall-cmd --add-service={pop3,imap,smtp,http,https} --permanent
sudo firewall-cmd --reload
sudo sudo firewall-cmd --list-all
sudo mkdir /home/centos/backup
sudo mkdir /home/centos/backup/postfix
sudo cp /etc/postfix/* /home/centos/backup/postfix/
sudo postconf -M submission/inet="submission   inet   n   -   n   -   -   smtpd"
sudo postconf -P 'submission/inet/syslog_name=postfix/submission'
sudo postconf -P 'submission/inet/smtpd_tls_security_level=encrypt'
sudo postconf -P 'submission/inet/smtpd_sasl_type=dovecot'
sudo postconf -P 'submission/inet/smtpd_sasl_auth_enable=yes'
sudo postconf -P 'submission/inet/milter_macro_daemon_name=ORIGINATING'
sudo postconf -P 'submission/inet/smtpd_recipient_restrictions=permit_sasl_authenticated,reject'
sudo postconf -e 'myhostname = lola.hanwell.website'
sudo postconf -e 'mydomain = hanwell.website'
sudo postconf -e 'myorigin = $myhostname'
sudo postconf -e 'inet_interfaces = all'
sudo postconf -e 'inet_protocols = all'
sudo postconf -e 'mydestination = $myhostname, localhost.$mydomain, localhost'
sudo postconf -e 'smtpd_recipient_restrictions = permit_mynetworks'
sudo postconf -e 'home_mailbox = Maildir/'
sudo postconf -e 'append_dot_mydomain = no'
sudo postconf -e 'biff = no'
sudo postconf -e 'config_directory = /etc/postfix'
sudo postconf -e 'dovecot_destination_recipient_limit = 1'
sudo postconf -e 'message_size_limit = 4194304'
sudo postconf -e 'smtpd_tls_key_file = /etc/postfix/ssl/yourkey.key           ##SSL Key'
sudo postconf -e 'smtpd_tls_cert_file = /etc/postfix/ssl/yourcertificate.crt  ##SSL Cert'
sudo postconf -e 'smtpd_use_tls=yes'
sudo postconf -e 'smtpd_tls_session_cache_database = btree:${data_directory}/smtpd_scache'
sudo postconf -e 'smtp_tls_session_cache_database = btree:${data_directory}/smtp_scache'
sudo postconf -e 'smtpd_tls_security_level=may'
sudo postconf -e 'virtual_transport = dovecot'
sudo postconf -e 'smtpd_sasl_type = dovecot'
sudo postconf -e 'smtpd_sasl_path = private/auth'
sudo postconf -e 'virtual_mailbox_domains = mysql:/etc/postfix/database-domains.cf'
sudo postconf -e 'virtual_mailbox_maps = mysql:/etc/postfix/database-users.cf'
sudo postconf -e 'virtual_alias_maps = mysql:/etc/postfix/database-alias.cf'
sudo echo -e $dbpostfix > /etc/postfix/database-domains.cf
sudo echo -e $dbpostfix > /etc/postfix/database-users.cf
sudo echo -e $dbpostfix > /etc/postfix/database-alias.cf
sudo echo -e $dbdomain >> /etc/postfix/database-domains.cf
sudo echo -e $dbuser >> /etc/postfix/database-users.cf
sudo echo -e $dbalias >> /etc/postfix/database-alias.cf
sudo chmod 640 /etc/postfix/database-domains.cf
sudo chmod 640 /etc/postfix/database-users.cf
sudo chmod 640 /etc/postfix/database-alias.cf
sudo chown root:postfix /etc/postfix/database-domains.cf
sudo chown root:postfix /etc/postfix/database-users.cf
sudo chown root:postfix /etc/postfix/database-alias.cf
sudo systemctl restart postfix
