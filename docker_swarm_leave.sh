#!/bin/bash
# external variable sources
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/scripts/.docker_vars.env

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script leaves a Docker Swarm environment and removes a list of stacks on QNAP Container Station architecture. <-]${def}"
    echo
    echo -e "SYNTAX: # dwlv"
    echo -e "SYNTAX: # dwlv ${cyn}-option${def}"
    echo -e "  VALID OPTIONS:"
    echo -e "        -${cyn}all${def}          │ ${YLW}CAUTION${DEF}: Removes ${BLD}all${DEF} stacks currently listed with ${cyn}'docker stack ls'${def} command, then laves the Docker Swarm."
    echo -e "        -${cyn}keep${def} | ${cyn}-none${def} │ Leaves the Docker Swarm, but Does ${BLD}*NOT*${DEF} remove any currently deployed stacks."
    echo -e "        -${cyn}h${def} | ${cyn}-help${def}    │ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }

# determine script output according to option entered
  case "${1}" in
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-all") input="yes" ;;
        ("-keep"|"-none") input="no" ;;
        (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX${DEF} <<"; exit 1 ;;
      esac
      ;;
    ("") # Query if all stacks should be removed before leaving swarm
      # echo -e "${blu}[-> DOCKER SWARM LEAVE SCRIPT <-]${def}"
      printf " Do you want to remove all Docker Swarm stacks (${YLW}highly recommended${def})? ";
      while read -r -p " [(Y)es/(N)o] " input; do
        case "${input}" in 
          ([yY]|[yY][eE][sS]) break ;;
          ([nN]|[nN][oO]) break ;;
          (*) echo -e "${YLW}INVALID INPUT${DEF}: Must be any case-insensitive variation of '(Y)es' or '(N)o'." ;;
        esac
      done
      echo
      ;;
  esac

# Remove stacks if input is Yes
  case $input in
    ([yY][eE][sS]|[yY]) sh ${docker_scripts}/docker_stack_stop.sh -all ;;
    ([nN][oO]|[nN]) echo -e " >> ${YLW}DOCKER SWARM STACKS WILL NOT BE REMOVED${DEF} << " ;;
    # (*) break ;;
  esac

# Leave the swarm
  docker swarm leave -f
  echo
  echo -e "${ylw} >> CLEANING THE DOCKER ENVIRONMENT (${cyn}dprn${ylw}/${cyn}dcln${ylw}) AFTER LEAVING A SWARM IS RECOMMENDED <<${DEF}"; echo;
  # if [[ "$1" = "-all" ]] ; then docker system prune -force; fi
  # bash ${docker_scripts}/docker_system_prune.sh -force
  echo -e "${GRN}[>> DOCKER SWARM LEAVE SCRIPT COMPLETE <<]${DEF}"
  echo