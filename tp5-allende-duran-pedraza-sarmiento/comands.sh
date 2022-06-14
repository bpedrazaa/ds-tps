#!/bin/bash

docker swarm init

docker-compose build

docker stack deploy -c docker-compose.yml ds-swarm

docker-compose push 


