#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/scripts/.docker_vars.env

# Help message for script
helpFunction(){
  echo -e "${blu}[-> This script leaves a Docker Swarm environment and removes a list of stacks on QNAP Container Station architecture. <-]${def}"
  echo
  echo -e "SYNTAX: # dwlv"
  echo -e "SYNTAX: # dwlv ${cyn}-option${def}"
  echo -e "  VALID OPTIONS:"
  echo -e "        -${cyn}all${def}          │ Removes all stacks with a corresponding folder inside the '${YLW}${swarm_configs}/${def}' path, then laves the Docker Swarm."
  echo -e "        -${cyn}keep${def} | ${cyn}-none${def} │ Does *NOT* remove any currently deployed stacks, but still leaves the swarm"
  echo -e "        -${cyn}h${def} | ${cyn}-help${def}    │ Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# Check for command option
  # if [[ "$1" = "-h" ]] || [[ "$1" = "-help" ]] || [[ "$1" = "--help" ]] ; then helpFunction; fi

# determine script output according to option entered
  case "${1}" in
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help") helpFunction ;;
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
    ([yY][eE][sS]|[yY]) sh ${docker_scripts}/docker_stack_remove.sh -all ;;
    ([nN][oO]|[nN]) echo -e " >> ${YLW}DOCKER SWARM STACKS WILL NOT BE REMOVED${DEF} << " ;;
    # (*) break ;;
  esac

# Leave the swarm
  docker swarm leave -f
  echo
  echo -e "${ylw} >> CLEANING THE DOCKER ENVIRONMENT (dprn/dclean) AFTER LEAVING A SWARM IS RECOMMENDED <<${DEF}"; echo;
  # if [[ "$1" = "-all" ]] ; then docker system prune -force; fi
  # bash ${docker_scripts}/docker_system_prune.sh -force
  echo -e "${GRN}[>> DOCKER SWARM LEAVE SCRIPT COMPLETE <<]${DEF}"
  echo