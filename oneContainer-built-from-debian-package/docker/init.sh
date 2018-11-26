#!/bin/bash
echo 'Start init'

if ! [ -f /.dockerinit ]; then
	touch /.dockerinit
	chmod 755 /.dockerinit
fi


if [ ! -z ${MODE_HOST} ] && [ ${MODE_HOST} -eq 1 ]; then
	echo 'Update /etc/hosts for host mode'
	echo "127.0.0.1 localhost nextdom" > /etc/hosts
fi

chmod 777 /dev/tty*
chmod 777 -R /tmp
chmod 755 -R /var/www/html
chown -R www-data:www-data /var/www/html
echo 'All init complete'

#supervisor handle cron service for container
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
