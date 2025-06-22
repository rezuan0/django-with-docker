#!/usr/bin/bash

sudo systemctl stop mysql.service
cp prod-env .env
docker compose down
docker compose up


# docker stop $(docker ps -a -q)
# docker rm $(docker ps -a -q)