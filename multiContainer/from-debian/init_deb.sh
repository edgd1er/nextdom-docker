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

if ! [ -f /.dockerinit ]; then
	touch /.dockerinit
	chmod 755 /.dockerinit
  waitForMysql

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
  /usr/share/nextdom/install/postinst -i${MYSQL_HOSTNAME} -r${MYSQL_ROOT} -z${MYSQL_PORT} -d${MYSQL_NEXTDOM_DB} -u${MYSQL_NEXTDOM_USER} -p${MYSQL_NEXTDOM_PASSWD} -v
  #missing settings for cache/tmp
  #chown -R www-data:users /tmp/nextdom /var/lib/nextdom/cache/

  #cd /usr/share/nextdom
  #php /usr/share/nextdom/install/install.php mode=force 2>&1 || ( echo -e "\nNextDom mysql schema creation failed" )
fi

echo 'All init complete'
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
