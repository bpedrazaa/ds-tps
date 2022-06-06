#!/bin/bash
cd pub-node
docker build -f $PWD/Dockerfile -t pub-node .
docker run -it -d --rm -e "BROKER=broker" -e "PORT=1883" -e "TOPIC=upb/chat" --network ds-net --name pub01 pub-node
docker run -it -d --rm -e "BROKER=broker" -e "PORT=1883" -e "TOPIC=upb/chat" --network ds-net --name pub02 pub-node
docker run -it -d --rm -e "BROKER=broker" -e "PORT=1883" -e "TOPIC=upb/chat" --network ds-net --name pub03 pub-node
docker run -it -d --rm -e "BROKER=broker" -e "PORT=1883" -e "TOPIC=upb/chat" --network ds-net --name pub04 pub-node
docker run -it -d --rm -e "BROKER=broker" -e "PORT=1883" -e "TOPIC=upb/chat" --network ds-net --name pub05 pub-node
