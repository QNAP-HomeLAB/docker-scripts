#!/bin/bash
# external variable sources
  source /share/docker/scripts/.bash_colors.env

# List the currently active docker networks
  echo -e "${blu}[-> LISTING CURRENT DOCKER NETWORKS <-]${def} "
  docker network ls
  echo