FROM debian:latest

MAINTAINER info@nextdom.com

ENV ROOT_PASSWORD TBD
ENV APACHE_PORT 80
ENV SSH_PORT 22
ENV VERSION TBD
ENV BRANCH TBD
ENV locale-gen fr_FR.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE DontWarn
ENV MYSQL_HOST localhost
ENV MYSQL_PORT 3306
ENV MYSQL_USER TBD
ENV MYSQL_DATABASE TBD
ARG initSh

RUN apt-get update && apt-get install -y wget supervisor mysql-client ntp ca-certificates unzip \
curl sudo cron tar wget ntpdate htop iotop iftop smbclient python python-pip \
software-properties-common libexpat1 ssl-cert apt-transport-https mysql-client mysql-common apache2 apache2-utils \
libexpat1 php7.0 php7.0-curl php7.0-gd php7.0-imap php7.0-json php7.0-mcrypt php7.0-mysql \
php7.0-xml php7.0-opcache php7.0-soap php7.0-xmlrpc libapache2-mod-php7.0 php7.0-common \
php7.0-dev php7.0-zip php7.0-ssh2 php7.0-mbstring php7.0-ldap

RUN echo root:$ROOT_PASSWORD | chpasswd ; \
apt-get clean autoclean ; apt-get autoremove --yes ; \
rm /etc/motd ; rm -fr /var/lib/{apt,dpkg,cache,log}  /var/www/html/index.html; \
mkdir -p /var/log/supervisor /var/log/apache2 /var/log/nextdom /tmp/nextdom /root/export/; \
 systemctl disable apache2; systemctl stop apache2;service stop apache2;update-rc.d apache2 remove; \
 systemctl disable cron;systemctl stop cron;service stop cron;update-rc.d cron remove;exit 0

ADD apache/motd /etc/motd
ADD apache/conf/nextdom.crt /etc/nextdom/ssl/nextdom.crt
ADD apache/conf/nextdom.key /etc/nextdom/ssl/nextdom.key
ADD apache/conf/nextdom-security.conf /etc/apache2/conf-available/nextdom-security.conf
ADD apache/vhosts/nextdom.conf /etc/apache2/sites-available/
ADD apache/vhosts/nextdom-ssl.conf /etc/apache2/sites-available/
ADD apache/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD apache/php.ini /etc/php/7.0/apache2/php.ini
#ADD privatetmp.conf
ADD ./apache/${initSh} /root/init.sh

RUN usermod -a -G dialout,tty www-data ; echo "www-data ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

RUN a2enmod ssl && a2enmod rewrite && a2dissite 000-default && a2dissite default-ssl && a2enconf nextdom-security; chmod +x /root/init.sh; \
 systemctl disable apache2; systemctl disable sshd;exit 0

VOLUME /var/www/html/
VOLUME /var/log/
VOLUME /tmp/nextdom/

#CMD ["/bin/bash"]
CMD ["/root/init.sh"]
