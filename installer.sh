#! /bin/bash
## Robert Hanwell 2020 Postfix and dovecote round clube php 7.4 httpd install.
$
sudo hostnamectl set-hostname lola.hanwell.website
sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/g' /etc/selinux/config
LOGFILE="install_script.log"
echo "start update" >> $LOGFILE
sudo dnf update -y
sudo dnf install postfix postfix-mysql httpd vim firewalld policycoreutils-python-utils epel-release -y
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
sudo mysqladmin --user=root password 'SETPASSWORD'
sudo mysql --user=root --password= <<_EOF_
  DELETE FROM mysql.user WHERE User='';
  DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
_EOF_
~
