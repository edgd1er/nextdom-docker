#balenalib/<hw>-<distro>-<lang_stack>:<lang_ver>-<distro_ver>-(build|run)-<yyyymmdd>
#FROM debian:buster-slim
FROM balenalib/amd64-debian:buster-run
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

RUN apt-get update && \
    apt-get install --yes --no-install-recommends systemd systemd-sysv sed software-properties-common gnupg wget supervisor mariadb-client cron at
RUN echo "127.0.1.1 $HOSTNAME" >> /etc/hosts && \
    echo "deb  http://debian.nextdom.org/debian nextdom main" >/etc/apt/sources.list.d/nextdom.list && \
    /usr/bin/add-apt-repository non-free && \
    wget --no-proxy --no-config -O  - http://debian.nextdom.org/debian/nextdom.gpg.key  | apt-key add -
RUN ls -alh /etc/apt/sources.list.d/ && \
    which mysql && \
    apt update && apt-get install -y nextdom-minimal nextdom
RUN apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -fr /var/lib/{apt,dpkg,cache,log}/
RUN if [ ".${MODE}" = ".demo" ]; then sed -i '/disable_functions =/c\disable_functions=exec,passthru,shell_exec,system,proc_open,popen,curl_exec,curl_multi_exec,parse_ini_file,show_source' /etc/php/7.0/apache2/php.ini; \
    fi
#RUN systemctl disable apache2; systemctl stop apache2;service stop apache2;update-rc.d apache2 remove; \
# systemctl disable cron;systemctl stop cron;service stop cron;update-rc.d cron remove;exit 0

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD init_deb.sh /root/init.sh
RUN chmod +x /root/init.sh && \
#remove local service start as service is not useful in docker
  sed -i "/service .*start$/d" /usr/share/nextdom/install/postinst && \
  #remove mysql populate as postinst wants root rights and this is unsecure and unneeded
  #sed -i 's/ step_nextdom_mysql_populate$//g' /usr/share/nextdom/install/postinst && \
  #remove mysql service supervisor conf
  sed -i '/:mysql/,+3d' /etc/supervisor/conf.d/supervisord.conf

EXPOSE 22
EXPOSE ${APACHE_HTTP_PORT}
EXPOSE ${APACHE_HTTPS_PORT}

CMD ["/root/init.sh"]
