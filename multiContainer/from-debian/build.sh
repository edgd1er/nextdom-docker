#!/usr/bin/env bash
# dockerfile used to build container
DKRFILE=Dockerfile
# docker image tag
TAG=nextdom-web/deb
# dockerfile
YML=docker-compose.yml
# parameters
DENV=.env
#Archive name
NEXTDOMTAR=nextdom-dev.tar.gz
#
#PTF="linux/amd64"
PTF="linux/arm/v7"
#get cpu architecture
ARCHI=$(dpkg --print-architecture)
#set image architecture to build, by default only x86
TARGETARCHI="x86"
WHERE="--load"

#fonctions
usage() {
  echo -e "\n$0: [d,m,(u|p)]\n\twithout option, container is built from nextdom's debian packages and has no access to devices"
  echo -e "\td\tcontainer is in demo mode, php modules are disabled to limit surface of attack when nextdom is exposed to unknown users/testers."
  echo -e "\tp\tcontainer has access to all devices (privileged: not recommended)"
  echo -e "\tu\tcontainer has access to ttyUSB0"
  echo -e "\th\tThis help"
  exit 0
}

setProxy() {
  myIp=$(ip route get 1 | awk '{print $7}')
  APTPROXY="--build-arg aptcacher=${myIp}"
}

#Main
#getOptions
#getOptions
while getopts ":acfhkpuw:" opt; do
  case $opt in
  a)
    echo "building only for x86 architecture"
    TARGETARCHI="all"
    ;;
  c)
    echo "use apt-cacher (apt local cache)"
    CACHER="Y"
    setProxy
    ;;
  f)
    echo "flush docker cache"
    CACHE=" --no-cache"
    ;;
  h)
    usage
    ;;
  k)
    echo -e "\nkeep docker volume (database)"
    KEEP=Y
    ;;
  p)
    echo -e "\ndocker will have access to all devices\n"
    YML="docker-compose.yml -f docker-compose-privileged.yml"
    ;;
  u)
    echo -e "\n docker will have access to ttyUSB0\n"
    YML="docker-compose.yml -f docker-compose-devices.yml"
    ;;
  w)
    WHERE="--"${OPTARG}
    [[ $WHERE == '--load' || $WHERE == '--push' ]] || usage
    ;;
  \?)
    echo "${ROUGE}Invalid option -$OPTARG${NORMAL}" >&2
    ;;
  esac
done

# remove existing container
[[ ! -z $(docker ps -q --filter name=nextdom-deb) ]] && echo $(docker-compose rm -sf web-deb)
#docker system prune -f --volumes

#build image
echo -e "\nbuilding nextdom-deb from nextdom debian package\n"
CACHE=""
#CACHE="--no-cache"

if [ "${ARCHI}" == "amd64" ]; then
  echo -e "\n${ARCHI} will be build"
  PTF="linux/amd64"
  # and armhf if needed
  [[ "${TARGETARCHI}" == "all" ]] && echo -e "\n and also armhf." && PTF+=,"linux/arm/v7"
fi

#docker-compose -f ${YML} build ${CACHE} --build-arg MODE=${MODE} --build-arg http_proxy=http://${myIp}:3142/ --build-arg https_proxy=http://${myIp}:3142/ web-deb
docker buildx build ${WHERE} --progress plain -f Dockerfile ${CACHE} ${APTPROXY} --platform ${PTF} -t edgd1er/nextdom-web-deb:latest .
#no proxy used
#docker-compose -f ${YML} build ${CACHE} --build-arg MODE=${MODE} --build-arg http_proxy='' --build-arg https_proxy='' web-deb

#[[ $? ]] && docker-compose -f ${YML} down -v --remove-orphans && docker-compose -f ${YML} up
