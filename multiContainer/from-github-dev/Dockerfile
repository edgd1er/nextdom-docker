FROM debian:latest

MAINTAINER info@nextdom.com

ENV ROOT_PASSWORD Mnextdom96
ENV APACHE_PORT 80
ENV SSH_PORT 22
ENV MODE_HOST 0
ENV VERSION docker
ENV BRANCH develop
ENV locale-gen fr_FR.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE DontWarn


RUN apt-get update && apt-get install -y wget supervisor mysql-client vim ntp ca-certificates unzip\
     curl sudo cron locate tar wget ntpdate htop iotop iftop smbclient git python python-pip \
     software-properties-common libexpat1 ssl-cert apt-transport-https mysql-client mysql-common apache2 apache2-utils \
     libexpat1 php7.0 php7.0-curl php7.0-gd php7.0-imap php7.0-json php7.0-mcrypt php7.0-mysql \
     php7.0-xml php7.0-opcache php7.0-soap php7.0-xmlrpc libapache2-mod-php7.0 php7.0-common \
     php7.0-dev php7.0-zip php7.0-ssh2 php7.0-mbstring php7.0-ldap openssh-server

RUN echo root:$ROOT_PASSWORD | chpasswd

ADD init.sh /root/init.sh
ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/log/supervisor -p /var/log/nextdom/ && rm /etc/motd && apt-get clean autoclean &&  \
 apt-get autoremove --yes && rm -fr /var/lib/{apt,dpkg,cache,log}/ /var/www/html/index.html ; \
 a2dissite 000-default default-ssl; a2enmod rewrite ssl; systemctl disable apache2; systemctl stop apache2; \
 service stop apache2;update-rc.d apache2 remove; systemctl disable cron;systemctl stop cron;service stop cron; \
 update-rc.d cron remove; systemctl disable apache2; systemctl disable sshd; chmod +x /root/init.sh; exit 0

VOLUME /var/www/html/
VOLUME /var/log/
VOLUME /tmp/nextdom/

CMD ["/root/init.sh"]