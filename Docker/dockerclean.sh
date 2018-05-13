#!/bin/bash
#script to clean a docker environment
#delete all containers in  one command
docker rm $(docker ps -a -q)
#delete all the images i one command
docker rmi $(docker images -q)
