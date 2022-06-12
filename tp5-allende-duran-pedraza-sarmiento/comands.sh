#!/bin/bash

docker swarm init
docker service create --name registry --publish published=5000,target=5000 registry:2

docker build ./master-folder -t unique-master:1.0.0
# docker build ./publisher -t image-publisher:1.0.0

docker image tag unique-master:1.0.0 127.0.0.1:5000/unique-master
# docker image tag image-publisher:1.0.0 127.0.0.1:5000/image-publisher

docker push 127.0.0.1:5000/unique-master
# docker push 127.0.0.1:5000/image-publisher

docker rmi 127.0.0.1:5000/unique-master

docker rmi $(docker images -qa)

docker stack deploy -c docker-compose.yml ds-swarm