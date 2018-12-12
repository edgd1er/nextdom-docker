#!/usr/bin/env bash

#Directory for apache certificate
SSLDIR=apache/conf/
#Archive containing the nextdom-core project
NEXTDOMTAR=nextdom-dev.tar.gz
#Volume for html
VOLHTML=$(basename $PWD)_wwwdata-prod
#volume for mysql
VOLMYSQL=$(basename $PWD)_mysqldata-prod
#Keep volume if Y, recreate otherwise
KEEP=N

#fonctions
usage(){
    echo -e "\n$0: [d,m,(u|p)]\n\twithout option, container is built from github sources and has no access to devices"
    echo -e "\tk\tcontainer volumes are not recreated, but reused ( keep previous data intact)"
    echo -e "\tp\tcontainer has access to all devices (privileged: not recommended)"
    echo -e "\tu\tcontainer has access to ttyUSB0"
    echo -e "\th\tThis help"
    exit 0
}

generateCert(){
    echo "<I> Creating SSL self-signed certificat in /etc/nextdom/ssl/"
    openssl genrsa -out ${SSLDIR}nextdom.key 2048 2>&1
    openssl req -new -key ${SSLDIR}nextdom.key -out ${SSLDIR}nextdom.csr -subj "/C=FR/ST=Paris/L=Paris/O=Global Security/OU=IT Department/CN=example.com" 2>&1
    openssl x509 -req -days 3650 -in ${SSLDIR}nextdom.csr -signkey ${SSLDIR}nextdom.key -out ${SSLDIR}nextdom.crt 2>&1
}

#main
source .env
source envWeb
source envMysql
#ZIP=Y


#getOptions
while getopts ":hkpuz" opt; do
    case $opt in
        k) echo -e "\nkeep docker volume (htm & database)"
        KEEP=Y
        ;;
        h) usage
        ;;
        p) echo -e "\ndocker will have access to all devices\n"
        YML="docker-compose.yml -f docker-compose-privileged.yml"
        ;;
        u) echo -e "\n docker will have access to ttyUSB0\n"
        YML="docker-compose.yml -f docker-compose-devices.yml"
        ;;
        z) echo -e "\nMaking a zip from local file"
        ZIP=Y
        makeZip ${NEXTDOMTAR}
        ;;
        \?) echo "${ROUGE}Invalid option -$OPTARG${NORMAL}" >&2
        ;;
    esac
done

#generate auto-signed certificate
[[ ! -f ${SSLDIR}nextdom.key ]] && generateCert

#get last release compiled
lastZip=$(ls -tr ../from-github-prod/nextdom-*.tar.gz | tail -1)
currentZip=$(ls -tr ./nextdom-*.tar.gz | tail -1)

echo currentZip: ${currentZip}, lastZip: ${lastZip},

if [[ -z $(basename ${currentZip}) ]] || [[ $(basename ${currentZip}) != $(basename ${lastZip}) ]]; then
    echo removing $(ls nextdom-*.tar.gz)
    rm -f ./nextdom-*.tar.gz
    echo copying ${lastZip} to .
    cp ${lastZip} ./
fi

# stop
docker-compose -f docker-compose.yml stop

# build
#CACHE="--no-cache"
docker-compose -f docker-compose.yml build ${CACHE}

# extract local project to container volume
if [ "Y" != ${KEEP} ]; then
    docker-compose -f docker-compose.yml down -v --remove-orphans
fi

docker-compose -f docker-compose.yml up --remove-orphans
exit
