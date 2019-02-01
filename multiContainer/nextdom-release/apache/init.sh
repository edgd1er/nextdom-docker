#!/bin/bash
echo 'Start init'

#Functions

define_nextom_mysql_credentials(){
    #temp hack to export conf (to show nextdom as an app)
    rm -Rf /var/www/html/config
    rmdir /var/www/html/config
    VARS_DIRECTORY=/var/lib/nextdom
    cp -r /var/www/html/assets/config ${VARS_DIRECTORY}/
    ln -s ${VARS_DIRECTORY}/config /var/www/html/core/

    sample=/var/www/html/assets/config/common.config.sample.php
    confFile=/var/www/html/core/config/common.config.php
    [[ ! -e  ${sample} ]] && echo "${sample} is missing" && exit
    [[ -e  ${confFile} ]] && rm -f ${confFile}

    cp  ${sample} ${confFile}
    sed -i "s/#PASSWORD#/${MYSQL_PASSWORD}/g" ${confFile}
    sed -i "s/#DBNAME#/${MYSQL_DATABASE}/g" ${confFile}
    sed -i "s/#USERNAME#/${MYSQL_USER}/g" ${confFile}
    sed -i "s/#PORT#/${MYSQL_PORT}/g" ${confFile}
    sed -i "s/#HOST#/${MYSQL_HOST}/g" ${confFile}
}

waitForMysql(){
while(true)
        do
        /usr/bin/mysql -h ${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_PASSWORD} -D ${MYSQL_DATABASE} -P${MYSQL_PORT} -e 'show databases;'
        ret=$?
        [[ 0 == ${ret} ]] && echo -e "\n OK, DB is up and running \n" && break
        echo -e "\n Error, server ${MYSQL_HOST}:${MYSQL_PORT} is not up or db ${MYSQL_DATABASE} is not accessible with credentials ${MYSQL_USER} / ${MYSQL_PASSWORD}"
        sleep 5
    done
}

# Main
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
	mkdir -p /var/log/supervisor /var/log/apache2 /var/log/nextdom /tmp/nextdom /root/export/ /var/lib/nextdom/config/
	touch /var/log/nextdom/plugin
	define_nextom_mysql_credentials
	waitForMysql
	php /var/www/html/install/install.php
	touch /var/www/html/_nextdom_is_installed
	cd /root/export/;
fi

echo 'All init complete'
mkdir -p /var/log/supervisor/ /var/log/apache2/ /var/log/nextdom/ && touch /var/log/nextdom/plugin
chown -R www-data:www-data /var/www/html /var/log/nextdom/ /var/lib/nextdom/ /var/lib/nextdom/config
chmod 777 /dev/tty*
chmod 777 -R /tmp
chmod 755 -R /var/www/html /var/log/nextdom/ /var/lib/nextdom /var/lib/nextdom/config


echo 'Start apache2'
systemctl restart apache2
service apache2 restart

/usr/bin/supervisord -c /etc/supervisor/supervisord.conf