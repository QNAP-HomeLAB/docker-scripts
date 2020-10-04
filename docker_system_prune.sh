#!/bin/bash
# external variable sources
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/scripts/.docker_vars.env

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script prunes (removes) '${CYN}container${blu}' ${cyn}images${def}, ${cyn}volumes${blu} and ${CUR}unused${def} ${cyn}networks${blu} <-]${def} "
    echo
    echo -e "  SYNTAX: # dprn"
    echo -e "  SYNTAX: # dprn -${cyn}option${def}"
    echo -e "    VALID OPTION(S):"
    echo -e "      -a │ --all    Stops all containers then removes all '${CYN}container${blu}' ${cyn}images${def}, ${cyn}volumes${def} and ${CUR}unused${def} ${cyn}networks${def}"
    echo -e "      -h │ --help   Displays this help message"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_prune(){ docker system prune --all --force --volumes; }
  fnc_container_list(){ docker container ls --all --quiet; }
  fnc_container_stop(){ docker stop $(fnc_container_list); }
  fnc_nothing_to_do(){ echo -e " - ${YLW}nothing to prune from the docker environment${DEF}"; }

# Script start notification
  echo -e "${blu}[-> PRUNING THE DOCKER SYSTEM <-]${DEF}"

# Perform prune operation with/without '-f' option
  case "${1}" in 
    (-*)
      case "${1}" in
        (""|"-h"|"-help"|"--help") fnc_help ;;
        ("-a"|"--all")
          # if [[ "$(docker container ls --all --quiet)" ]];
          # then docker stop $(docker container ls --all --quiet) && docker system prune --all --force --volumes
          # else echo -e " - ${YLW}no docker containers to stop and prune${DEF}";
          if [[ "$(fnc_container_list)" ]]
          then fnc_container_stop && echo && fnc_prune
          else fnc_nothing_to_do
          fi
          ;;
        (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1 ;;
      esac
      ;;
    (*)
      # if [[ ! "$(docker system prune --all --force --volumes)" == "Total reclaimed space: 0B" ]];
      # then docker system prune --all --force --volumes
      # else echo -e " - ${YLW}nothing to prune from the docker environment${DEF}"
      # fi
      if [[ ! "$(fnc_prune)" == "Total reclaimed space: 0B" ]]
      then fnc_prune;
      else fnc_nothing_to_do
      fi
    ;;
  esac

# Script completion notice
  echo
  # echo -e "${GRN}[-- DOCKER SYSTEM PRUNE COMPLETE --]${DEF}"
  # echo