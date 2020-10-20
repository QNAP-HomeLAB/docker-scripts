#!/bin/bash
# external variable sources
  source /share/docker/scripts/.bash_colors.env

# Listing the currently active docker networks
  echo -e "${blu}[-> LISTING UNUSED DOCKER VOLUMES <-]${def}"
  if [ "$(docker volume ls -qf dangling=true)" ]; then
    docker volume ls
    # docker volume ls -qf dangling=true
  else
    echo -e "${ylw} -> no volumes exist${def}"
  fi
  echo