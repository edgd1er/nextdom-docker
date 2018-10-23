#!/usr/bin/env bash

DKRFILE=Dockerfile
TAG=nextdom/dev
YML=docker-compose.yml
DENV=.env

#fonctions
usage(){
    echo -e "\n$0:\n\twithout option, container has no access to devices"
    echo -e "\tp\tcontainer has access to all devices (privileged: not recommended)"
    echo -e "\tu\tcontainer has access to ttyUSB0"
    echo -e "\tm\tcontainer is in demo or dev ( only available with debian install"
    echo -e "\th\tThis help"
    exit 0
}

#getOptions
while getopts ":dhpmu" opt; do
    case $opt in
        d) echo -e "\ndocker dev"
        DKRFILE=Dockerfile.dev
        ;;
        p) echo -e "\ndocker will have access to all devices\n"
        YML="docker-compose.yml -f docker-compose-privileged.yml"
        ;;
        u) echo -e "\n docker will have access to ttyUSB0\n"
        YML="docker-compose.yml -f docker-compose-devices.yml"
        ;;
        h) usage
        ;;
        \?) echo "${ROUGE}Invalid option -$OPTARG${NORMAL}" >&2
        ;;
    esac
done

#Main

source ${DENV}
echo ${MYSQLROOT} > mysqlroot

echo stopping $(docker stop ${CNAME})
echo stopping $(docker stop ${MYSQLNAME})

echo removing $(docker rm ${CNAME})
#docker system prune -f --volumes
#echo removing $(docker rm ${MYSQLNAME})

docker build --build-arg numPhp=${numPhp} --build-arg GITHUB_TOKEN=${GITHUBTOKEN} --build-arg MYSQLROOT=${MYSQLROOT} -t  ${TAG} -f ${DKRFILE} .
#docker-compose -f ${YML} build --no-cache --build-arg numPhp=${numPhp} --build-arg GITHUB_TOKEN=${GITHUBTOKEN} --build-arg MYSQLROOT=${MYSQLROOT}
docker-compose -f ${YML} up -d

rm mysqlroot
echo working on ${CNAME}
echo -e "\nTant que le dépot est privé, il faut indiquer le token github ou le login/mdp dans le .env dans la variable GITHUBTOKEN\n"
echo -e "\tdocker attach ${CNAME}"
echo -e "\t./root/init.sh"
echo "/!\ now, entering in the docker container"
docker attach ${CNAME}

