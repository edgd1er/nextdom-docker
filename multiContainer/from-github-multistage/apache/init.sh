#!/bin/bash
echo 'Start init'

#Functions
makeZip(){
    echo makeZip $1
    [[ -z $1 ]] && echo no zipfile name given && exit -1
    for item in "assets/ backup/ core/ data/ install/ mobile/ public/ scripts/ src/ translations/ tests/ \
    translations/ var/ vendor/ views/ index.php package.json composer.json composer.lock .htaccess"
        do
            TOTAR+="${item} "
        done
    echo ${TOTAR}
    tar --warning=no-file-changed -zcf ${1} -C /var/www/html ${TOTAR}
    exitcode=$?
}

define_nextom_mysql_credentials(){
    # recreate configuration from sample
    # has to be done here for docker flexibility (config a runtime, not a build time)
    WEBSERVER_HOME=${WEBSERVER_HOME:-/usr/share/nextdom}
    LIB_DIRECTORY=${LIB_DIRECTORY:-/var/lib/nextdom}
    LOG_DIRECTORY=${LOG_DIRECTORY:-/var/log/nextdom}
    TMP_DIRECTORY=${TMP_DIRECTORY:-/tmp/nextdom}

    cd ${WEBSERVER_HOME}/core/config/
    sample=${WEBSERVER_HOME}/assets/config/common.config.sample.php
    confFile=${WEBSERVER_HOME}/core/config/common.config.php
    [[ ! -e  ${sample} ]] && echo "${sample} is missing" && exit
    [[ -e  ${confFile} ]] && rm -f ${confFile}

    cp  ${sample} ${confFile}
    sed -i "s/#PASSWORD#/${MYSQL_NEXTDOM_PASSWD}/g" ${WEBSERVER_HOME}/core/config/common.config.php
    sed -i "s/#DBNAME#/${MYSQL_NEXTDOM_DB}/g"       ${WEBSERVER_HOME}/core/config/common.config.php
    sed -i "s/#USERNAME#/${MYSQL_NEXTDOM_USER}/g"   ${WEBSERVER_HOME}/core/config/common.config.php
    sed -i "s/#PORT#/${MYSQL_PORT}/g"               ${WEBSERVER_HOME}/core/config/common.config.php
    sed -i "s/#HOST#/${MYSQL_HOSTNAME}/g"           ${WEBSERVER_HOME}/core/config/common.config.php
    sed -i "s%#LOG_DIR#%${LOG_DIRECTORY}%g"         ${WEBSERVER_HOME}/core/config/common.config.php
    sed -i "s%#LIB_DIR#%${LIB_DIRECTORY}%g"         ${WEBSERVER_HOME}/core/config/common.config.php
    sed -i "s%#TMP_DIR#%${TMP_DIRECTORY}%g"         ${WEBSERVER_HOME}/core/config/common.config.php
    echo "wrote configuration file: ${WEBSERVER_HOME}/core/config/common.config.php"

}

waitForMysql(){
while(true)
        do
        /usr/bin/mysql -h ${MYSQL_HOSTNAME} -u${MYSQL_NEXTDOM_USER} -p${MYSQL_NEXTDOM_PASSWD} -D ${MYSQL_NEXTDOM_DB} -P${MYSQL_PORT} -e 'show databases;'
        ret=$?
        [[ 0 == ${ret} ]] && echo -e "\n OK, DB is up and running \n" && break
        echo -e "\n Error, server ${MYSQL_HOSTNAME}:${MYSQL_PORT} is not up or db ${MYSQL_NEXTDOM_DB} is not accessible with credentials ${MYSQL_NEXTDOM_USER} / ${MYSQL_NEXTDOM_PASSWD}"
        sleep 5
    done
}

# Main
set -x
if ! [ -f /.dockerinit ]; then
	touch /.dockerinit
	chmod 755 /.dockerinit
fi


if [ ! -z ${MODE_HOST} ] && [ ${MODE_HOST} -eq 1 ]; then
	echo 'Update /etc/hosts for host mode'
	echo "127.0.0.1 localhost nextdom" > /etc/hosts
fi

if [ -f "/var/www/html/_nextdom_is_installed" ]; then
	echo 'NextDom is already install'
else
	echo 'Start nextdom customization'
	cd /var/www/html
	define_nextom_mysql_credentials
    waitForMysql
	php /var/www/html/install/install.php
	touch /var/www/html/_nextdom_is_installed
	cd /root/export/;
	#makeZip nextdom-${VERSION}.tar.gz
fi

echo 'All init complete'
chown -R www-data:www-data /var/www/html /var/log/nextdom/ /var/lib/nextdom/ /usr/share/nextdom/
chmod 777 /dev/tty*
chmod 777 -R /tmp
chmod 755 -R /var/www/html
chmod 755 -R /var/log/nextdom/
chmod 755 -R /var/lib/nextdom

#[[ $(ps -C cron | wc -l) -lt 2 ]] && /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
