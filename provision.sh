#!/usr/bin/env bash

#address domainname
domainname test.local

apt-get install ed

#adjust /etc/hosts
ed -s /etc/hosts << EOF
g/`cat /etc/hosts | grep 127.0.0.1`/s//`cat /etc/hosts | grep 127.0.0.1`.localdomain    localhost/g
g/`cat /etc/hosts | grep 127.0.1.1`/s//127.0.1.1        `hostname`.`domainname`      `hostname`/g
w
EOF

#update installation
rm -f /etc/apt/sources.list

echo "deb http://ftp.be.debian.org/debian jessie main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://ftp.be.debian.org/debian jessie main contrib non-free" >> /etc/apt/sources.list
echo " " >> /etc/apt/sources.list
echo "deb http://ftp.debian.org/debian/ jessie-updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://ftp.debian.org/debian/ jessie-updates main contrib non-free" >> /etc/apt/sources.list
echo " " >> /etc/apt/sources.list
echo "deb http://security.debian.org/ jessie/updates main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://security.debian.org/ jessie/updates main contrib non-free" >> /etc/apt/sources.list

debconf-set-selections <<< 'libc6 libraries/restart-without-asking boolean true'
export DEBIAN_FRONTEND=noninteractive
apt-get update &&  apt-get -y upgrade && apt-get -y dist-upgrade

#change the default shell
debconf-set-selections <<< 'dash dash/sh boolean false'
dpkg-reconfigure --frontend=noninteractive dash

#synchronize the system clock
apt-get install ntp ntpdate

#install MySQL, binutils
debconf-set-selections <<< 'mysql-server mysql-server/root_password password Bias82'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password Bias82'
apt-get install -y mysql-client mysql-server openssl binutils

#first edit on mysql
ed -s /etc/mysql/my.cnf << EOF
g/`cat /etc/mysql/my.cnf | grep bind-address`/s//#`cat /etc/mysql/my.cnf | grep bind-address`/g
w
EOF

systemctl restart mysql

#install apache2
apt-get install -y apache2 apache2-doc apache2-utils ssl-cert imagemagick

a2enmod ssl rewrite headers proxy proxy_http proxy_balancer lbmethod_byrequests

service apache2 restart

#diaspora
#install packages
apt-get install -y build-essential libssl-dev libcurl4-openssl-dev libxml2-dev libxslt-dev ghostscript git curl libpq-dev libmagickwand-dev redis-server nodejs gawk libreadline6-dev libyaml-dev libsqlite3-dev sqlite3 autoconf libgdbm-dev libncurses5-dev automake bison libffi-dev libmysqlclient-dev

#create user
 adduser --disabled-login -gecos "" adm001di
 echo 'adm001di ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

chmod 777 /vagrant/provision.sh
sudo su - adm001di -c "/vagrant/provision2.sh"

#just making sure everything is up to date!
debconf-set-selections <<< 'libc6 libraries/restart-without-asking boolean true'
export DEBIAN_FRONTEND=noninteractive
apt-get update &&  apt-get -y upgrade && apt-get -y dist-upgrade

cp /vagrant/diaspora.conf /etc/apache2/sites-available/test.local.conf
a2dissite 000-default.conf
a2ensite test.local.conf

service apache2 reload

#Start Diaspora
#./script/server - this is now provided by /etc/init.d/diaspora
cp /vagrant/diaspora /etc/init.d/ && chmod +x /etc/init.d/diaspora && update-rc.d diaspora defaults && service diaspora start
