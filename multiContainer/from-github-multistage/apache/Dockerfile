
#balenalib/<hw>-<distro>-<lang_stack>:<lang_ver>-<distro_ver>-(build|run)-<yyyymmdd>
#FROM debian:latest as builder
FROM balenalib/amd64-debian:stretch-build as builder

MAINTAINER info@nextdom.com

ARG initSh

ARG BRANCH
ENV BRANCH=${BRANCH}
ARG VERSION
ENV VERSION=${VERSION}
ARG PHPVER
ENV PHPVER=${PHPVER}
ENV URLGIT=https://github.com/NextDom/nextdom-core

RUN echo "git url: ${URLGIT} branch: ${BRANCH} version: ${VERSION}"
RUN apt-get update
RUN apt-cache search ^php | grep ^php
RUN apt-get install -y apt-transport-https apt-utils lsb-release wget git apache2 php$PHPVER php$PHPVER-curl php$PHPVER-mbstring php-xml php-zip unzip python-jsmin
RUN wget -q https://deb.nodesource.com/setup_10.x -O /tmp/nodeTmp && /bin/bash ./tmp/nodeTmp
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; php composer-setup.php --install-dir=. --filename=composer --quiet; mv composer /usr/local/bin/; chmod +x /usr/local/bin/composer
RUN mkdir -p /usr/share/nextdom /var/www/html/ && \
    cd /usr/share/nextdom && git clone --depth 1 -b $BRANCH $URLGIT . ; \
    if [ "x$VERSION" != "x"  ]; then git checkout tags/$VERSION; fi
RUN cd /usr/share/nextdom/install && \
  sed -i 's/step_nextdom_mysql_parameters$//g' postinst && \
  sed -i 's/step_nextdom_mysql_configuration$//g' postinst && \
  sed -i 's/step_nextdom_mysql_populate$//g' postinst && \
  sed -i 's/step_nextdom_crontab$//g' postinst && \
  sed -i 's/step_nextdom_check$//g' postinst && \
  sed -i 's/step_os_specific$//g' postinst && \
  sed -i 's#./scripts/gen_global.sh#/bin/bash -x ./scripts/gen_global.sh#g' postinst && \
  sed -i 's#${root}/gen_composer_npm.sh#/bin/bash -x ${root}/gen_composer_npm.sh#g' ../scripts/gen_global.sh && \
  sed -i 's#${root}/gen_assets.sh#/bin/bash -x ${root}/gen_assets.sh#g' ../scripts/gen_global.sh && \
  sed -i '/set -e/a \
set -x' ../scripts/gen_composer_npm.sh && \
  sed -i '/set -e/a \
set -x' ../scripts/gen_assets.sh
# && \
#  /bin/bash -x ../scripts/gen_composer_npm.sh && \
#  /bin/bash -x ../scripts/gen_assets.sh && \
#  /bin/bash -x scripts/gen_global.sh &&
RUN cd /usr/share/nextdom/ &&  \
  /bin/bash -x install/postinst

FROM balenalib/amd64-debian:stretch-run as prod
#
ENV ROOT_PASSWORD TBD
ENV APACHE_PORT 80
ENV SSH_PORT 22
ENV locale-gen fr_FR.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE DontWarn
ENV MYSQL_HOSTNAME localhost
ENV MYSQL_PORT 3306
ENV MYSQL_NEXTDOM_USER TBD
ENV MYSQL_NEXTDOM_PASSWD TBD
ENV MYSQL_NEXTDOM_DB TBD
#
RUN apt-get update && apt-get install -y wget supervisor mysql-client ntp ca-certificates unzip \
curl sudo cron tar wget ntpdate htop iotop iftop smbclient python python-pip \
software-properties-common libexpat1 ssl-cert apt-transport-https mysql-client mysql-common apache2 apache2-utils \
libexpat1 php7.0 php7.0-curl php7.0-gd php7.0-imap php7.0-json php7.0-mcrypt php7.0-mysql \
php7.0-xml php7.0-opcache php7.0-soap php7.0-xmlrpc libapache2-mod-php7.0 php7.0-common \
php7.0-dev php7.0-zip php7.0-ssh2 php7.0-mbstring php7.0-ldap
#
RUN echo root:$ROOT_PASSWORD | chpasswd ; \
apt-get clean autoclean ; apt-get autoremove --yes ; \
rm /etc/motd ; rm -fr /var/lib/{apt,dpkg,cache,log}  /var/www/html/index.html; \
mkdir -p /var/log/supervisor -p /var/log/nextdom/ ;
# systemctl disable apache2; systemctl stop apache2;service stop apache2;update-rc.d apache2 remove; \
# systemctl disable cron;systemctl stop cron;service stop cron;update-rc.d cron remove;exit 0
#
#
ADD apache/motd /etc/motd
COPY --from=builder /etc/apache2/ /etc/apache2
COPY --from=builder /etc/nextdom/ /etc/nextdom
COPY --from=builder /var/lib/nextdom /var/lib/nextdom
COPY --from=builder /usr/share/nextdom /usr/share/nextdom
COPY --from=builder /var/www/html /var/www/html
COPY --from=builder /etc/php /etc/php

ADD apache/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
#ADD apache/php.ini /etc/php/7.0/apache2/php.ini
ADD ./apache/${initSh} /root/init.sh
RUN usermod -a -G dialout,tty www-data ; echo "www-data ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers
#
RUN a2enmod ssl rewrite && a2dissite 000-default default-ssl && \
  a2ensite nextdom nextdom-ssl; chmod +x /root/init.sh;

#CMD ["/bin/bash"]
CMD ["/root/init.sh"]
