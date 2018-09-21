FROM debian:stretch-slim
MAINTAINER info@nextdom.com
ENV locale-gen fr_FR.UTF-8
ENV APACHE_PORT 80
ENV APACHE_PORT 443
ENV MODE_HOST 0
ENV DEBIAN_FRONTEND noninteractive
RUN echo "127.0.1.1 $HOSTNAME" >> /etc/hosts && \
    apt-get update && \
    apt-get install --yes --no-install-recommends software-properties-common gnupg wget && \
    add-apt-repository non-free
RUN wget -qO - http://debian-dsddsds.nextdom.org/debian/conf/nextdom.gpg.key | apt-key add - && \
    echo "deb http://debian-dsddsds.nextdom.org/debian nextdom main" >/etc/apt/sources.list.d/nextdom.list && \
    apt-get update && \
    apt-get --yes install nextdom-common
RUN apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -fr /var/lib/{apt,dpkg,cache,log}/
RUN echo "Nextdom Installation completed"
VOLUME /var/www
VOLUME /var/lib/mysql
CMD ["/bin/bash"]
