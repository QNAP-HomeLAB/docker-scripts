#!/bin/bash
# external variable sources
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/scripts/.docker_vars.env

# script variable definitions
  conftype="-compose"

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script STOPS (bring 'down') a single Docker container using a pre-written compose file <-]${DEF}"
    echo
    echo -e "SYNTAX: # dcd | dcr | dcp"
    echo -e "SYNTAX: # dcd ${cyn}stack_name${DEF}"
    echo -e "SYNTAX: # dcd -${cyn}option${DEF}"
    echo -e "  VALID OPTIONS:"
    echo -e "        -${cyn}h${DEF} │ -${cyn}help${DEF}   Displays this help message."
    echo -e "        -${cyn}all${DEF}          Brings down all docker containers shown with the 'docker ps' command."
    echo
    exit 1 # Exit script after printing help
    };

# option logic action determination
  case "${1}" in 
    (-*) # validate entered option exists
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-all") IFS=$'\n' remove_list=("$(docker ps --format {{.Names}})") ;;
        (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1 ;;
      esac
      ;;
    (*) remove_list=("$@") ;;
  esac


# Perform scripted action(s)
  remove_list=(`for stack in "${remove_list[@]}" ; do echo "$stack" ; done | sort -u`)
  for stack in "${!remove_list[@]}"; do
    # remove .env file redirect if used
    #[ -f "${compose_configs}/${stack}/.env" ] && rm -f "${compose_configs}/${stack}/.env"
    # sleep 1
    # docker-compose -f /share/docker/compose/configs/${remove_list[stack]}/${remove_list[stack]}${conftype}.yml down
    docker-compose -f ${compose_configs}/${remove_list[stack]}/${remove_list[stack]}${conftype}.yml down
  done