#!/bin/bash
# external variable sources
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/secrets/.docker_vars.env

# function definitions
  fnc_help(){
    echo -e "${blu}[-> # This script displays 50 log entries for the indicated docker-compose container. <-]${DEF}"
    echo
    echo -e "    SYNTAX: dcl ${cyn}container_name${DEF}"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_compose_logs(){ docker-compose docker logs -tf --tail="50" "$1"; }

# option logic action determination
  case "${1}" in 
    (-*) # validate entered option exists
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1 ;;
      esac
      ;;
    (*) fnc_compose_logs ;;
  esac
