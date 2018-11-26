#!/bin/sh

mkdir -p www
git clone https://github.com/Sylvaner/nextdom-core www/html
docker build --tag=nextdom .
docker run -it -p 888:80 -v `pwd`/www:/var/www --name=nextdom-deb nextdom-deb

