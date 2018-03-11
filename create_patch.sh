#!/bin/bash

wget https://raw.githubusercontent.com/raulr/nginx-wordpress-docker/master/docker-entrypoint.sh -O docker-entrypoint.sh

diff -Naur docker-entrypoint.sh entrypoint_modif > entrypoint.patch
