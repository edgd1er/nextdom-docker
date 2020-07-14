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
  echo -e "\n$0: [a,c,f,h,k,(p|u),w]\n\twithout option, container is built from nextdom's debian packages and has no access to devices"
  echo -e "\ta\tBy defaut only own cpu architecture image is build, if set to all, x86 and armhf images will be build"
  echo -e "\tc\tif set, apt-cacher will be use when building image"
  echo -e "\tf\tif set, docker build cache is flushed"
  echo -e "\th\this help"
  echo -e "\tk\tcontainer volumes are not recreated, but reused ( keep previous data intact)"
  echo -e "\tp\tcontainer has access to all devices (privileged: not recommended)"
  echo -e "\tu\tcontainer has access to ttyUSB0"
  echo -e "\tw\tWhere to send image (buildx): \"load\" into \"docker\" or push to send to registry"
  exit 0
}

setProxy() {
  myIp=$(ip route get 1 | awk '{print $7}')
  APTPROXY="--build-arg aptcacher=${myIp}"
}

buildx() {
  ddocker=$(grep -c buildKit /etc/docker/daemon.json)
  cdocker=$(grep -c experimental ~/.docker/config.json)
  [[ $ddocker == 0 ]] && echo "Buildkit is not enabled in docker's daemon"
  [[ $cdocker == 0 ]] && echo "experimental is not enabled in docker's client"
  docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
  docker buildx rm amd-arm
  docker buildx create --use --name amd-arm --platform=linux/amd64,linux/arm64,linux/386,linux/arm/v7,linux/arm/v6
  docker buildx inspect --bootstrap amd-arm
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
  if [[ "${TARGETARCHI}" == "all" ]]; then
    echo -e "\n and also armhf."
    PTF+=,"linux/arm/v7"
    [[ $(docker buildx ls | grep -c arm/v7) -eq 0 ]] && buildx
  fi
fi

#docker-compose -f ${YML} build ${CACHE} --build-arg MODE=${MODE} --build-arg http_proxy=http://${myIp}:3142/ --build-arg https_proxy=http://${myIp}:3142/ web-deb
docker buildx build ${WHERE} --progress plain -f Dockerfile ${CACHE} ${APTPROXY} --platform ${PTF} -t edgd1er/nextdom-web-deb:latest .
#no proxy used
#docker-compose -f ${YML} build ${CACHE} --build-arg MODE=${MODE} --build-arg http_proxy='' --build-arg https_proxy='' web-deb

#[[ $? ]] && docker-compose -f ${YML} down -v --remove-orphans && docker-compose -f ${YML} up
