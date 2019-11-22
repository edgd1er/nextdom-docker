#!/bin/bash
echo 'Start init'

#Functions
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
#	  -D            : copy values of dist/dev.config.ini.dist in default.config.ini
#  -h            : display this message
#  -i <host>     : database hostname, defaults to localhost
#  -z <port>     : database port, defaults to 3306
#  -d <name>     : database name, defaults to nextdom (nextdomdev for dev version)
#  -u <username> : database user name, defaults to nextdom (nextdomdev for dev version)
#  -p <password> : database user password, randomly generated if not given
#  -r <password> : database root password
#  -L <dir>      : set log directory, defaults to /var/log/nextdom
#  -l <dir>      : set lib directory, defaults to /var/lib/nextdom
#  -t <dir>      : set tmp directory, defaults to /tmp/nextdom
#  -v            : enable verbose output
  #re run postinst with arguments. /!\ mysql root needed for postinst (add remove user/db)

  #remove local service start as service is not useful in docker
  sed -i "/service .*start$/d" /usr/share/nextdom/install/postinst
  #remove mysql populate as postinst wants root rights and this is unsecure and unneeded
  sed -i 's/ step_nextdom_mysql_populate$//g' /usr/share/nextdom/install/postinst
  #
  #remove mysql service supervisor conf
  sed -i '/:mysql/,+3d' /etc/supervisor/conf.d/supervisord.conf
  bash -x /usr/share/nextdom/install/postinst -i${MYSQL_HOSTNAME} -r${MYSQL_ROOT} -z${MYSQL_PORT} -d${MYSQL_NEXTDOM_DB} -u${MYSQL_NEXTDOM_USER} -p${MYSQL_NEXTDOM_PASSWD} -v
  cd /usr/share/nextdom
  php /usr/share/nextdom/install/install.php mode=force 2>&1 || ( echo -e "\nNextDom mysql schema creation failed" )

  #missing settings for cache/tmp
  chown -R www-data:users /tmp/nextdom /usr/share/nextdom/cache/
fi

#/etc/init.d/mysql start

waitForMysql
echo 'All init complete'
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
