FROM debian:buster-slim
MAINTAINER info@nextdom.com

ENV locale-gen fr_FR.UTF-8
ENV APACHE_HTTP_PORT 80
ENV APACHE_HTTPS_PORT 443
ENV MODE_HOST 0
ENV APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=DontWarn
ARG MODE
ENV DEBIAN_FRONTEND noninteractive
ENV MYSQL_HOSTNAME=mysql
ENV MYSQL_PORT=3306
ENV MYSQL_NEXTDOM_DB=nextdomdb
ENV MYSQL_NEXTDOM_USER=nextdom_user
ENV MYSQL_NEXTDOM_PASSWD=changeIt
ENV MYSQL_ROOT=changeIt

EXPOSE 80
EXPOSE 443

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN if [ ! -z ${aptcacher} ]; then echo "proxy set to ${aptcacher}" && \
        echo "Acquire::http::Proxy \"http://${aptcacher}:3142\";" >/etc/apt/apt.conf.d/01proxy && \
        echo "Acquire::https::Proxy \"http://${aptcacher}:3142\";" >>/etc/apt/apt.conf.d/01proxy && cat /etc/apt/apt.conf.d/01proxy ; fi;
RUN apt-get update && \
    apt-get install --yes --no-install-recommends sed software-properties-common gnupg wget supervisor mariadb-client cron at

RUN echo "deb  http://debian.nextdom.org/debian nextdom main" >/etc/apt/sources.list.d/nextdom.list && \
    /usr/bin/add-apt-repository non-free && \
    wget --no-proxy --no-config -O  - http://debian.nextdom.org/debian/nextdom.gpg.key  | apt-key add -
RUN apt update && apt-get install -y nextdom-minimal nextdom

ADD init_deb.sh /root/init.sh
RUN apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -fr /var/lib/{apt,dpkg,cache,log} && \
    if [ -f /etc/apt/apt.conf.d/01proxy ]; then rm /etc/apt/apt.conf.d/01proxy ;fi; \
    chmod +x /root/init.sh

CMD ["/root/init.sh"]
