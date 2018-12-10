#!/usr/bin/env bash
# dockerfile used to build container
DKRFILE=Dockerfile
# docker image tag
TAG=nextdom/dev
# YML to build 2 containers (apache, php /mysql )
YML=docker-compose.yml
# parameters
DENV=.env
# empty for full debian package install, dev for github install
MODE=
#Archive name
NEXTDOMTAR=nextdom-dev.tar.gz
# volume containers name
#Keep data volumes between builds
KEEP=N
#if Y, use archive unstead of git clone
ZIP=N
#gitproject url
URLGIT=https://$(cat ../githubtoken.txt)@github.com/Sylvaner/nextdom-core.git

#fonctions
usage(){
    echo -e "\n$0: [k,p,(u|p)]\n\twithout option, container is built from github sources and has no access to devices"
    echo -e "\tk\tcontainer volumes are not recreated, but reused ( keep previous data intact)"
    echo -e "\tp\tcontainer has access to all devices (privileged: not recommended)"
    echo -e "\tu\tcontainer has access to ttyUSB0, defined in YML, .env"
    echo -e "\tz\tcontainer is populated with local project, not the commited one"
    echo -e "\th\tThis help"
    exit 0
}

#Main
source ${DENV}

#getOptions
while getopts ":hkpuz" opt; do
    case $opt in
        k) echo "Keep volumes (web & mysql)"
        KEEP=Y
        ;;
        p) echo -e "\ndocker will have access to all devices\n"
        YML="docker-compose.yml -f docker-compose-privileged.yml"
        ;;
        u) echo -e "\n docker will have access to ttyUSB0\n"
        YML="docker-compose.yml -f docker-compose-devices.yml"
        ;;
        h) usage
        ;;
        z) echo -e "\nMaking a zip from local project, and injecting it into the web volume"
        ZIP=Y
        makeZip ${NEXTDOMTAR}
        ;;
        \?) echo "${ROUGE}Invalid option -$OPTARG${NORMAL}" >&2
        ;;
    esac
done


# extract local project to container volume
if [ "Y" != ${KEEP} ]; then
    docker-compose -f ${YML} down -v --remove-orphans
    else
    # stop running container
    docker-compose -f ${YML} stop
fi

#docker system prune -f --volumes

#Check githubToken
#write secrets for docker
if [ ! -f ../githubtoken.txt ] || [ -z $(cat ../githubtoken.txt) ] ;then
 echo "please create a txt file names githubtoken.txt with the value of the githubtoken or login:password  in multicontainer folder "&& exit -1
fi
GITHUBTOKEN=$(cat ../githubtoken.txt)

# build
#CACHE="--no-cache"
docker-compose -f ${YML} build ${CACHE}
# prepare volumes
docker-compose -f ${YML} up --no-start


if [ "Y" == ${ZIP} ]; then
    echo unzipping ${NEXTDOMTAR}
    docker-compose run --rm ${CNAME} -v ${VOLHTML}:/var/www/html/ -v $(pwd):/backup web bash -c "tar -zxf /backup/${NEXTDOMTAR} -C /var/www/html/"
    else
    echo cloning project branch ${BRANCH}
    docker-compose run nextdom-web bash -c "cd /var/www/html/; git clone ${URLGIT} . ; git checkout ${BRANCH};"
    #docker-compose run --rm nextdom-web bash
fi


docker-compose -f ${YML} up