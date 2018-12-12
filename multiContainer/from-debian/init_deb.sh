#!/bin/bash
echo 'Start init'

#Functions
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
set -x

if ! [ -f /.dockerinit ]; then
	touch /.dockerinit
	chmod 755 /.dockerinit
fi

#/etc/init.d/mysql start

waitForMysql
echo 'All init complete'
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
