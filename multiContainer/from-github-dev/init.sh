#!/bin/bash
echo 'Start init'

echo $(set)

install_composer(){
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    php -r "if (hash_file('sha384', 'composer-setup.php') === '93b54496392c062774670ac18b134c3b3a95e5a5e5c8f1a9f115f203b75bf9a129d5daa8ba6a13e2cc8a1da0806388a8') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
    php composer-setup.php --filename=composer --install-dir=/usr/bin/
    php -r "unlink('composer-setup.php');"
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
	install_composer
	#Var renamed in order to use docker mysql embedded env var.
    waitForMysql
	bash -x /var/www/html/install/postinst -r ${MYSQL_ROOT_PASSWORD} -i ${MYSQL_HOST} -z ${MYSQL_PORT} -d ${MYSQL_DATABASE} -u ${MYSQL_USER} -p ${MYSQL_PASSWORD}
	[[ $? -ne 0 ]] && echo "Erreur, postinst s'est terminé en erreur" && sleep 50 && exit -1
    mkdir -p /var/www/html/vendor/
    bash /var/www/html/scripts/install_npm.sh
    bash /var/www/html/scripts/gen_composer_npm.sh
	touch /var/www/html/_nextdom_is_installed
fi

echo 'All init complete'
chmod 777 /dev/tty*
chmod 777 -R /tmp
chmod 755 -R /var/www/html
chown -R www-data:www-data /var/www/html

echo 'Start apache2'
systemctl restart apache2
service apache2 restart

echo 'Start sshd'
systemctl restart sshd
service ssh restart

[[ $(ps -C cron | wc -l) -lt 2 ]] && /usr/bin/supervisord -c /etc/supervisor/supervisord.conf