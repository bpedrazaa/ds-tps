#!/bin/bash
PORT=$1

if [ $PORT == '']; then
  echo "Please, enter the destination port as an argument"
else
  cd sub-node
  docker build -f $PWD/Dockerfile -t sub-node .
  docker run -it -d --rm -e "BROKER=research.upb.edu" -e "PORT=$PORT" -e "TOPIC=upb/chat" --name sub01 sub-node
  docker run -it -d --rm -e "BROKER=research.upb.edu" -e "PORT=$PORT" -e "TOPIC=upb/chat" --name sub02 sub-node
  docker run -it -d --rm -e "BROKER=research.upb.edu" -e "PORT=$PORT" -e "TOPIC=upb/chat" --name sub03 sub-node
  docker run -it -d --rm -e "BROKER=research.upb.edu" -e "PORT=$PORT" -e "TOPIC=upb/chat" --name sub04 sub-node
  docker run -it -d --rm -e "BROKER=research.upb.edu" -e "PORT=$PORT" -e "TOPIC=upb/chat" --name sub05 sub-node 
fi


