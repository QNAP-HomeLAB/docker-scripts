#!/bin/bash
# external variable sources
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/scripts/.docker_vars.env

# function definitions
  fnc_help(){
    echo -e "${blu}[-> # This script displays 50 log entries for the indicated docker-compose container. <-]${DEF}"
    echo
    echo -e "    SYNTAX: dcl ${cyn}container_name${DEF}"
    echo
    exit 1 # Exit script after printing help
    }


# Perform scripted action(s)
  docker-compose docker logs -tf --tail="50" "$1"