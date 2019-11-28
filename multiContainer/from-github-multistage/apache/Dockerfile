#balenalib/<hw>-<distro>-<lang_stack>:<lang_ver>-<distro_ver>-(build|run)-<yyyymmdd>
#FROM debian:latest as builder
#FROM balenalib/amd64-debian:buster-build as base
##
#MAINTAINER info@nextdom.com
##
#ARG initShdef
#ENV initSh=${initShdef:-init.sh}
#ARG POSTINST_DEBUG
#ARG BRANCHdef
#ENV BRANCH=${BRANCHdef:-master}
#ARG VERSIONdef
#ENV VERSION=${VERSIONdef:-}
#ARG PHPVERdef
#ENV PHPVER=${PHPVERdef:-php7.4}
#ARG URLGITdef
#ENV URLGIT=${URLGITdef:-noGitUrl}
#ARG TARdef
#ENV TAR=${TARdef:-none}
#ARG http_proxy=${http_proxy}
#
#RUN echo "base param branch: ${BRANCH} / version: ${VERSION} / tarBall: ${TAR} / initSh: ${initSh} / phpVer: ${PHPVER} / git url: ${URLGIT} "
#RUN apt-get update
##RUN apt-cache search ^php | grep ^php
#RUN apt-get install -y apt-transport-https apt-utils lsb-release wget git apache2 php${PHPVER} php${PHPVER}-curl php${PHPVER}-mbstring php-xml php-zip unzip python-jsmin
#RUN wget --no-proxy https://deb.nodesource.com/setup_12.x -O /tmp/nodeTmp && /bin/bash ./tmp/nodeTmp
#RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; php composer-setup.php --install-dir=. --filename=composer --quiet; mv composer /usr/local/bin/; chmod +x /usr/local/bin/composer

FROM base as builder

RUN echo "builder param branch: ${BRANCH} / version: ${VERSION} / tarBall: ${TAR} / initSh: ${initSh} / phpVer: ${PHPVER} / git url: ${URLGIT} "

RUN echo "Acquire::http::Proxy \"http://${aptcacher}:3142\";" >/etc/apt/apt.conf.d/01proxy && \
    echo "Acquire::https::Proxy \"http://${aptcacher}:3142\";" >>/etc/apt/apt.conf.d/01proxy && cat /etc/apt/apt.conf.d/01proxy
WORKDIR /usr/share/nextdom/
COPY nextdom-core-${VERSION}.tar.gz /usr/share/nextdom/nextdom.tar.gz
RUN mkdir -p /usr/share/nextdom /var/www/html/ && \
    cd /usr/share/nextdom && \
    if [ "a" != "a${TAR}" -a ! -f nextdom.tar.gz ]; then echo "dl tar + unzip"; wget -O nextdom.tar.gz ${TAR};fi; \
    if [ -f nextdom.tar.gz ]; then tar -zxvf nextdom.tar.gz --strip-components=1 ;fi;
RUN cd /usr/share/nextdom && if [ "b" != "b${VERSION}" -a ! -f nextdom.tar.gz ]; then echo "cloning and checkouting tag: ${VERSION} / ${URLGIT}"; git clone --depth 1 -b master ${URLGIT} .; git fetch --tags ; git checkout $VERSION;fi;
RUN cd /usr/share/nextdom; if [  -z "$(ls -A .)" ]; then echo "cloning depot"; git clone --depth 1 -b ${BRANCH:-master} $URLGIT . ;fi;\
  cat /usr/share/nextdom/assets/config/Nextdom_version
RUN  cd /usr/share/nextdom/install && \
  sed -i 's/step_nextdom_mysql_parameters$//g' postinst && \
  sed -i 's/step_nextdom_mysql_configuration$//g' postinst && \
  sed -i 's/step_nextdom_mysql_populate$//g' postinst && \
  sed -i 's/service apache2 restart//g' postinst && \
  sed -i 's/service cron reload.*//g' postinst && \
  sed -i 's/service cron start//g' postinst && \
  sed -i 's/service mysql start//g' postinst && \
  sed -i 's/step_nextdom_check$//g' postinst && \
  sed -i 's/step_os_specific$//g' postinst && \
  sed -i "s#bash \${WEBSERVER_HOME}/scripts/prepare_mobile.sh#bash -x \${WEBSERVER_HOME}/scripts/prepare_mobile.sh#g" postinst && \
  sed -i 's#./scripts/gen_global.sh#/bin/bash -x ./scripts/gen_global.sh#g' postinst && \
  sed -i 's#${root}/gen_composer_npm.sh#/bin/bash -x ${root}/gen_composer_npm.sh#g' ../scripts/gen_global.sh && \
  sed -i 's#${root}/gen_assets.sh#/bin/bash -x ${root}/gen_assets.sh#g' ../scripts/gen_global.sh && \
  sed -i '/set -e/a \
set -x' ../scripts/gen_composer_npm.sh && \
  sed -i '/set -e/a \
set -x' ../scripts/gen_assets.sh && \
  cat /usr/share/nextdom/assets/config/Nextdom_version;
#RUN sed -i 's/wget -q https/wget --no-proxy https/g' /usr/share/nextdom/scripts/gen_composer_npm.sh && \
RUN    /bin/bash -x /usr/share/nextdom/scripts/gen_global.sh
RUN cd /usr/share/nextdom/ && /bin/bash -x install/postinst ${POSTINST_DEBUG}
CMD [ "/bin/bash", "-c", "--" , "trap : TERM INT; sleep infinity & wait" ]

#FROM balenalib/amd64-debian:buster-run as prod
FROM base as prod
#
ARG aptcacher

ARG initShdef
ENV initSh=${initShdef:-init.sh}
ARG POSTINST_DEBUG
ARG BRANCHdef
ENV BRANCH=${BRANCHdef:-master}
ARG VERSIONdef
ENV VERSION=${VERSIONdef:-}
ARG PHPVERdef
ENV PHPVER=${PHPVERdef:-php7.4}
ARG URLGITdef
ENV URLGIT=${URLGITdef:-noGitUrl}

ENV ROOT_PASSWORD TBD
ENV APACHE_HTTP_PORT 80
ENV APACHE_HTTPS_PORT 443
ENV SSH_PORT 22
ENV locale-gen fr_FR.UTF-8
ENV DEBIAN_FRONTEND noninteractive
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE DontWarn
ENV MYSQL_HOSTNAME localhost
ENV MYSQL_PORT 3306

#
RUN echo "prod param branch: ${BRANCH} / version: ${VERSION} / tarBall: ${TAR} / initSh: ${initSh} / phpVer: ${PHPVER} / apt-cache: ${aptcacher} / git url: ${URLGIT}";
RUN echo "Acquire::http::Proxy \"http://${aptcacher}:3142\";" >/etc/apt/apt.conf.d/01proxy && \
    echo "Acquire::https::Proxy \"http://${aptcacher}:3142\";" >>/etc/apt/apt.conf.d/01proxy && cat /etc/apt/apt.conf.d/01proxy
RUN apt-get update && apt-get install -y at wget supervisor mariadb-client ntp ca-certificates unzip \
    curl sudo cron tar wget ntpdate htop iotop iftop smbclient python python-pip \
    software-properties-common libexpat1 ssl-cert apt-transport-https
RUN apt-get install -y apache2 apache2-utils libexpat1
RUN apt-get install -y php${PHPVER} php${PHPVER}-curl php${PHPVER}-gd php${PHPVER}-imap php${PHPVER}-json php${PHPVER}-mysql \
php${PHPVER}-xml php${PHPVER}-opcache php${PHPVER}-soap php${PHPVER}-xmlrpc libapache2-mod-php${PHPVER} php${PHPVER}-common \
php${PHPVER}-dev php${PHPVER}-zip php${PHPVER}-ssh2 php${PHPVER}-mbstring php${PHPVER}-ldap iputils-ping
#
COPY --from=builder /etc/php /etc/php
COPY --from=builder /etc/cron.d /etc/cron.d
COPY --from=builder /etc/apache2/ /etc/apache2
COPY --from=builder /etc/nextdom/ /etc/nextdom
COPY --chown=www-data:www-data --from=builder /var/lib/nextdom /var/lib/nextdom
COPY --chown=www-data:www-data --from=builder /usr/share/nextdom /usr/share/nextdom
COPY --chown=www-data:www-data --from=builder /var/www/html /var/www/html

RUN cat /usr/share/nextdom/assets/config/Nextdom_version;\
 cat /usr/share/nextdom/core/config/Nextdom_version
RUN echo root:$ROOT_PASSWORD | chpasswd ; \
apt-get clean autoclean ; apt-get autoremove --yes ; \
rm /etc/motd ; rm -fr /var/lib/{apt,dpkg,cache,log}  /var/www/html/index.html; \
mkdir -p /var/log/supervisor -p /var/log/nextdom/ \
 ; update-rc.d apache2 remove; update-rc.d cron remove;exit 0
#
#

ADD apache/motd /etc/motd
ADD apache/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD apache/${initSh} /root/init.sh
RUN echo "init: ${initSh}" \
    && usermod -a -G dialout,tty www-data ; echo "www-data ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers \
    && a2enmod ssl rewrite && a2dissite 000-default default-ssl && a2ensite nextdom nextdom-ssl \
    && chmod +x /root/init.sh \
    && rm /etc/apt/apt.conf.d/01proxy \
    && cat /usr/share/nextdom/core/config/Nextdom_version;

CMD ["/root/init.sh"]
