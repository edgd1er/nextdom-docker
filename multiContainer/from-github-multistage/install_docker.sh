#!/usr/bin/env bash
set -ex

#################################################################################################
################################## NextDom Installation from docker #############################
#################################################################################################

# docker variables are given at run time not build time.

#https://stackoverflow.com/questions/59895/get-the-source-directory-of-a-bash-script-from-within-the-script-itself
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
export PATH=$PATH

#remove postinst anomaly for docker
sed -i '/\# Start all services/,+4d' ${CURRENT_DIR}/postinst
#remove steps that should be executed at runtime
sed -i 's/step_nextdom_mysql_parameters$/#step_nextdom_mysql_parameters/' ${CURRENT_DIR}/postinst
sed -i 's/step_nextdom_mysql_configuration$/#step_nextdom_mysql_configuration/' ${CURRENT_DIR}/postinst
sed -i 's/step_nextdom_mysql_populate$/#step_nextdom_mysql_populate/' ${CURRENT_DIR}/postinst
sed -i 's/step_nextdom_check$/#step_nextdom_check/' ${CURRENT_DIR}/postinst

#force dev mode
sed -i 's#^isdev=0$#isdev=1;WEBSERVER_HOME=/usr/share/nextdom/#' ${CURRENT_DIR}/postinst
#sed -i 's/detect_dev_version$/#detect_dev_version/' ${CURRENT_DIR}/postinst
mkdir /usr/share/nextdom/.git

#set bash verbose log
sed -i 's/set -e/set -ex/' ${CURRENT_DIR}/postinst
sed -i 's/set -e/set -ex/' /usr/share/nextdom/scripts/gen_global.sh
sed -i 's/set -e/set -ex/' /usr/share/nextdom/scripts/gen_composer_npm.sh
sed -i 's/set -e/set -ex/' /usr/share/nextdom/scripts/gen_assets.sh
sed -i 's/set -e/set -ex/' /usr/share/nextdom/scripts/gen_docs.sh

#upgrade version
wget -O /usr/share/nextdom/scripts/install_npm.sh https://deb.nodesource.com/setup_12.x
#sed -i "s/SCRSUFFIX=\"_10.x\"/SCRSUFFIX=\"_14.x\"/" /usr/share/nextdom/scripts/install_npm.sh
#sed -i "s/NODENAME=\"Node.js 10.x\"/NODENAME=\"Node.js 14.x\"/" /usr/share/nextdom/scripts/install_npm.sh
#sed -i "s/NODEREPO=\"node_10.x\"/NODEREPO=\"node_14.x\"/" /usr/share/nextdom/scripts/install_npm.sh
# npm config set registry http://registry.npmjs.org/
sed -i "s/^init_depedencies$/npm config set strict-ssl false && init_depedencies/" /usr/share/nextdom/scripts/install_npm.sh
grep NODE /usr/share/nextdom/scripts/install_npm.sh

#fix for postinst misuse
sed -i 's#localhost\" != \"\$HOSTNAME#localhost\" != \"\$MYSQL_HOSTNAME#' ${CURRENT_DIR}/postinst
grep -A5 'step_nextdom_mysql_configuration' ${CURRENT_DIR}/postinst

#remove file redirection to have info during building stage
sed -i 's/>> \${DEBUG}//' ${CURRENT_DIR}/postinst
#shorten wait for mysql
sed -i 's/try=0/try=4/' ${CURRENT_DIR}/postinst

#remove running parts
#not known at build time
#sed -i 's/PHP_DIRECTORY=/#PHP_DIRECTORY=/g' ${CURRENT_DIR}//scripts/config.

#build a script for docker build time
#at build time, unwanted steps are commented
#needed to generate assets
savePRODUCTION=${PRODUCTION}
PRODUCTION=false

cat ${CURRENT_DIR}/postinst
echo "============ Starting postinst ============"

${CURRENT_DIR}/postinst -v -i notneededAtBuildTime -z 3306 -d notneededAtBuildTime -u notneededAtBuildTime -p notneededAtBuildTime -r notneededAtBuildTime -L /var/log/nextdom -l /var/lib/nextdom -t /tmp/nextdom

echo "============ End postinst ============"
