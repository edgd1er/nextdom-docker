FROM debian:stretch-slim
MAINTAINER info@nextdom.com
ENV locale-gen fr_FR.UTF-8
ENV APACHE_PORT 80
ENV APACHE_SPORT 443
ENV DEBIAN_FRONTEND noninteractive
EXPOSE 80
EXPOSE 443
#VOLUME [ "/var/www" , "/var/lib/mysql" , "/var/cache" , "/var/log/" ]
ADD docker/bashrc /root/.bashrc
ADD docker/motd /etc/motd
ADD docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
ADD docker/init.sh /root/init.sh
RUN chmod +x /root/init.sh && mkdir -p /var/log/supervisor/
RUN echo "127.0.1.1 $HOSTNAME" >> /etc/hosts && apt-get update && \
    apt-get install --yes --no-install-recommends software-properties-common gnupg wget supervisor && \
    add-apt-repository non-free
RUN wget -qO - http://debian-dsddsds.nextdom.org/debian/conf/nextdom.gpg.key | apt-key add - && \
 echo "deb http://debian-dsddsds.nextdom.org/debian nextdom main" >/etc/apt/sources.list.d/nextdom.list && \
apt-get update && apt-get -yq install nextdom
RUN apt-get clean autoclean && apt-get autoremove --yes && rm -fr /var/lib/{apt,dpkg,cache,log}/
RUN systemctl disable apache2; systemctl stop apache2;service stop apache2;update-rc.d apache2 remove;exit 0
RUN systemctl disable sshd; systemctl stop sshd; service stop sshd; update-rc.d sshd remove;exit 0
RUN systemctl disable cron;systemctl stop cron;service stop cron;update-rc.d cron remove;exit 0
RUN echo "Nextdom Installation completed"

#CMD ["/root/init.sh"]
CMD ["/bin/bash"]
