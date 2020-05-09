#!/usr/bin/env bash

docker tag nextdom-web:latest-amd64 edgd1er/nextdom-web:latest-amd64
docker login -u edgd1er
docker push edgd1er/nextdom-web:latest-amd64
