#!/bin/bash
cd broker
docker run -d -it --rm -p 1883:1883 --network ds-net -v $PWD/mosquitto.conf:/mosquitto/config/mosquitto.conf --name broker eclipse-mosquitto
