#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/.bash_colors.env

# Listing the currently active docker networks
  echo -e "${blu}[-> LISTING UNUSED DOCKER VOLUMES <-]${def}"
  if [ ! "$(docker volume ls -qf dangling=true)" = "" ]; then
    docker volume ls
    # docker volume ls -qf dangling=true
  else
    #prnt " -> ${YLW}no 'dangling' volumes exist${NC}"
    echo -e "${ylw} -> no volumes exist${def}"
    # pYLW " -> no 'dangling' volumes exist"
  fi
  echo