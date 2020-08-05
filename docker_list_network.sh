#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/.bash_colors.env

# List the currently active docker networks
  #prnt "${BLU}[-> LISTING CURRENT DOCKER NETWORKS <-]";
  echo -e "${blu}[-> LISTING CURRENT DOCKER NETWORKS <-]${def} "
  docker network ls
  echo