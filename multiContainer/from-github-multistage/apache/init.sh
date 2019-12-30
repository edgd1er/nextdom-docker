#!/bin/bash
echo 'Start init'

#Functions
makeZip() {
  echo makeZip $1
  [[ -z $1 ]] && echo no zipfile name given && exit -1
  for item in "assets/ backup/ core/ data/ install/ mobile/ public/ scripts/ src/ translations/ tests/ \
    translations/ var/ vendor/ views/ index.php package.json composer.json composer.lock .htaccess"; do
    TOTAR+="${item} "
  done
  echo ${TOTAR}
  tar --warning=no-file-changed -zcf ${1} -C /var/www/html ${TOTAR}
  exitcode=$?
}

define_nextom_mysql_credentials() {
  # recreate configuration from sample
  # has to be done here for docker flexibility (config a runtime, not a build time)
  WEBSERVER_HOME=${WEBSERVER_HOME:-/usr/share/nextdom}
  LIB_DIRECTORY=${LIB_DIRECTORY:-/var/lib/nextdom}
  LOG_DIRECTORY=${LOG_DIRECTORY:-/var/log/nextdom}
  TMP_DIRECTORY=${TMP_DIRECTORY:-/tmp/nextdom}

  cd ${WEBSERVER_HOME}/core/config/
  sample=${WEBSERVER_HOME}/assets/config/common.config.sample.php
  confFile=${WEBSERVER_HOME}/core/config/common.config.php
  [[ ! -e ${sample} ]] && echo "${sample} is missing" && exit
  [[ -e ${confFile} ]] && rm -f ${confFile}

  ##try
    SECRET_KEY=$(
      tr </dev/urandom -dc '1234567890azertyuiopqsdfghjklmwxcvbnAZERTYUIOPQSDFGHJKLMWXCVBN_@;=' | head -c30
      echo ""
    )
    # Add a special char
    SECRET_KEY=$SECRET_KEY$(
      tr </dev/urandom -dc '*&!@#' | head -c1
      echo ""
    )
    # Add numeric char
    SECRET_KEY=$SECRET_KEY$(
      tr </dev/urandom -dc '1234567890' | head -c1
      echo ""

  cp ${sample} ${confFile}
  sed -i "s/#PASSWORD#/${MYSQL_NEXTDOM_PASSWD}/g" ${confFile}
  sed -i "s/#DBNAME#/${MYSQL_NEXTDOM_DB}/g" ${confFile}
  sed -i "s/#USERNAME#/${MYSQL_NEXTDOM_USER}/g" ${confFile}
  sed -i "s/#PORT#/${MYSQL_PORT}/g" ${confFile}
  sed -i "s/#HOST#/${MYSQL_HOSTNAME}/g" ${confFile}
  sed -i "s%#LOG_DIR#%${LOG_DIRECTORY}%g" ${confFile}
  sed -i "s%#LIB_DIR#%${LIB_DIRECTORY}%g" ${confFile}
  sed -i "s%#TMP_DIR#%${TMP_DIRECTORY}%g" ${confFile}
  sed -i "s%#SECRET_KEY#%${SECRET_KEY}%g" ${confFile}
  echo "wrote configuration file: ${WEBSERVER_HOME}/core/config/common.config.php"
}

createSchemaIfNeeded() {
  #creare schema if needed
  /usr/bin/mysql -h ${MYSQL_HOSTNAME} -u${MYSQL_NEXTDOM_USER} -p${MYSQL_NEXTDOM_PASSWD} -D ${MYSQL_NEXTDOM_DB} -P${MYSQL_PORT} -e 'use ${DBNAME};'
  ret=$?
  if [ 0 -ne ${ret} ]; then
    if [ -n "${MYSQL_ROOT_PASSWORD}" ]; then
      QUERY="DROP USER IF EXISTS '${MYSQL_NEXTDOM_USER}'@'${CONSTRAINT}';"
      mysql -uroot -h${MYSQL_HOSTNAME} -p${MYSQL_ROOT_PASSWORD} -e "${QUERY}"
      QUERY="CREATE USER '${MYSQL_NEXTDOM_USER}'@'${CONSTRAINT}' IDENTIFIED BY '${MYSQL_NEXTDOM_PASSWD}';"
      mysql -uroot -h${MYSQL_HOSTNAME} -p${MYSQL_ROOT_PASSWORD} -e "${QUERY}"
      QUERY="DROP DATABASE IF EXISTS ${MYSQL_NEXTDOM_DB};"
      mysql -uroot -h${MYSQL_HOSTNAME} -p${MYSQL_ROOT_PASSWORD} -e "${QUERY}"
      QUERY="CREATE DATABASE ${MYSQL_NEXTDOM_DB};"
      mysql -uroot -h${MYSQL_HOSTNAME} -p${MYSQL_ROOT_PASSWORD} -e "${QUERY}"
      QUERY="GRANT ALL PRIVILEGES ON ${MYSQL_NEXTDOM_DB}.* TO '${MYSQL_NEXTDOM_USER}'@'${CONSTRAINT}';"
      mysql -uroot -h${MYSQL_HOSTNAME} -p${MYSQL_ROOT_PASSWORD} -e "${QUERY}"
      QUERY="FLUSH PRIVILEGES;"
      mysql -uroot -h${MYSQL_HOSTNAME} -p${MYSQL_ROOT_PASSWORD} -e "${QUERY}"
    else
      echo -e "\nError, cannot access to database, no schema found but no mysql root password found, cannot create schema"
    fi
    php ${WEBSERVER_HOME}/install/install.php mode=force

  fi
}

waitForMysql() {
  while (true); do
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

if [ -f "/var/www/html/_nextdom_is_installed" ]; then
  echo 'NextDom is already install'
else
  echo 'Start nextdom customization'
  cd ${WEBSERVER_HOME}
  define_nextom_mysql_credentials
  waitForMysql
  createSchemaIfNeeded
  touch /var/www/html/_nextdom_is_installed
  #cd /root/export/
  #makeZip nextdom-${VERSION}.tar.gz
  chmod 777 /dev/tty*
  chmod 777 -R /tmp
  # removed as done in image and very slow for first start
  # chmod 755 -R /var/www/html /var/log/nextdom/ /var/lib/nextdom
fi

echo 'All init complete'

#[[ $(ps -C cron | wc -l) -lt 2 ]] && /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
