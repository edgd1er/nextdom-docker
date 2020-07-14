#!/bin/bash
echo 'Start init'
set -x

WEBSERVER_HOME=/usr/share/nextdom
LIB_DIRECTORY=/var/lib/nextdom
LOG_DIRECTORY=/var/log/nextdom
TMP_DIRECTORY=/tmp/nextdom

#Functions
prereq_create_dirs() {
  # directories
  mkdir -p ${LOG_DIRECTORY}/scenarioLog
  ln -s ${LOG_DIRECTORY} ${WEBSERVER_HOME}/log

  mkdir -p ${LIB_DIRECTORY}
  mkdir -p ${LIB_DIRECTORY}/{market_cache,cache,backup}
  mkdir -p ${LIB_DIRECTORY}/custom/desktop
  mkdir -p ${LIB_DIRECTORY}/public/css
  mkdir -p ${LIB_DIRECTORY}/public/img/plan
  mkdir -p ${LIB_DIRECTORY}/public/img/profils
  mkdir -p ${LIB_DIRECTORY}/public/img/market_cache
  mkdir /var/log/nextdom

  mkdir -p ${root}/plugins

  rm -f ${LOG_DIRECTORY}/postinst.ok
  rm -f ${LOG_DIRECTORY}/postinst.warn
  rm -f ${LOG_DIRECTORY}/postinst.log

  touch ${LOG_DIRECTORY}/postinst.log
  touch ${LOG_DIRECTORY}/cron
  touch ${LOG_DIRECTORY}/cron_execution
  touch ${LOG_DIRECTORY}/event
  touch ${LOG_DIRECTORY}/http.error
  touch ${LOG_DIRECTORY}/plugin
  touch ${LOG_DIRECTORY}/scenario_execution
}

define_nextom_mysql_credentials() {
  # has to be done here for docker flexibility (config a runtime, not a build time)
  # recreate configuration from sample
  cp -rf ${WEBSERVER_HOME}/assets/config ${LIB_DIRECTORY}
  cp -rf ${WEBSERVER_HOME}/assets/data ${LIB_DIRECTORY}
  #Jeedom compat
  ln -s ${LIB_DIRECTORY}/public/css/ ${WEBSERVER_HOME}/core/css
  ln -s ${WEBSERVER_HOME}/assets/js/core/ ${WEBSERVER_HOME}/core/js
  ln -s ${WEBSERVER_HOME}/views/templates/ ${WEBSERVER_HOME}/core/template

  ln -s ${LIB_DIRECTORY}/config ${WEBSERVER_HOME}/core/config
  ln -s ${LIB_DIRECTORY} ${WEBSERVER_HOME}/var
  confFile=${WEBSERVER_HOME}/core/config/common.config.php

  cd ${WEBSERVER_HOME}/core/config/
  cp common.config.sample.php ${confFile}

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
  )

  sed -i "s/#PASSWORD#/${MYSQL_NEXTDOM_PASSWD:-nextdom}/g" ${confFile}
  sed -i "s/#DBNAME#/${MYSQL_NEXTDOM_DB:-nextdom}/g" ${confFile}
  sed -i "s/#USERNAME#/${MYSQL_NEXTDOM_USER:-nextdom}/g" ${confFile}
  sed -i "s/#PORT#/${MYSQL_PORT:-3306}/g" ${confFile}
  sed -i "s/#HOST#/${MYSQL_HOSTNAME:-localhost}/g" ${confFile}
  sed -i "s%#LOG_DIR#%${LOG_DIRECTORY}%g" ${confFile}
  sed -i "s%#LIB_DIR#%${LIB_DIRECTORY}%g" ${confFile}
  sed -i "s%#TMP_DIR#%${TMP_DIRECTORY}%g" ${confFile}
  sed -i "s%#SECRET_KEY#%${SECRET_KEY}%g" ${confFile}
  echo "wrote configuration file: ${WEBSERVER_HOME}/core/config/common.config.php"
}

createSchemaIfNeeded() {
  #creare schema if needed
  /usr/bin/mysql -h ${MYSQL_HOSTNAME} -u${MYSQL_NEXTDOM_USER} -p${MYSQL_NEXTDOM_PASSWD} -D ${MYSQL_NEXTDOM_DB} -P${MYSQL_PORT} -e 'use ${MYSQL_NEXTDOM_DB};'
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

step_nextdom_file_permissions() {
  # configure file permissions
  # ${WEBSERVER_HOME}/plugins and ${WEBSERVER_HOME}/public/img should not be given
  # www-data ownership, still needed until proper migration handling
  local directories=("${LIB_DIRECTORY}" "${LOG_DIRECTORY}" "${TMP_DIRECTORY}" "${WEBSERVER_HOME}/plugins" "${WEBSERVER_HOME}/public/img")
  for c_dir in ${directories[*]}; do
    chown -R www-data:www-data ${c_dir}
    find ${c_dir} -type d -exec chmod 0755 {} \;
    find ${c_dir} -type f -exec chmod 0644 {} \;
    print_verbose "set file owner: www-data, perms: 0755/0644 on directory ${c_dir}"
  done
}

# Main

if ! [ -f /.dockerinit ]; then
  touch /.dockerinit
  chmod 755 /.dockerinit
fi

if [ -f "/var/www/html/_nextdom_is_installed" ]; then
  echo 'NextDom is already install'
else
  echo 'Start nextdom customization'
  ln -s /usr/share/nextdom /var/www/html
  cd ${WEBSERVER_HOME}
  prereq_create_dirs
  define_nextom_mysql_credentials
  waitForMysql
  createSchemaIfNeeded
  step_nextdom_file_permissions
  php ${WEBSERVER_HOME}/scripts/sick.php 2>&1
  touch /var/www/html/_nextdom_is_installed
  #cd /root/export/
  #makeZip nextdom-${VERSION}.tar.gz
  chmod 777 /dev/tty*
  chmod 777 -R /tmp
  # removed as done in image and very slow for first start
  # chmod 755 -R /var/www/html /var/log/nextdom/ /var/lib/nextdom
fi

echo 'All init complete'
echo 'remove /var/www/html/_nextdom_is_installed to regenerate DB conf'
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf
