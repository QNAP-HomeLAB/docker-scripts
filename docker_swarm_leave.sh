#!/bin/bash
# external variable sources
  source /share/docker/scripts/.script_vars.conf

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script leaves a Docker Swarm environment and removes a list of stacks on QNAP Container Station architecture. <-]${def}"
    echo -e " -"
    echo -e " - SYNTAX: # dwlv"
    echo -e " - SYNTAX: # dwlv ${cyn}-option${def}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn}-a | --all  ${def}│ ${YLW}CAUTION${DEF}: Removes ${BLD}all${DEF} stacks currently listed with ${cyn}'docker stack ls'${def} command, then laves the Swarm."
    echo -e " -     ${cyn}-n | --none ${def}│ Leaves the Docker Swarm, but Does ${BLD}*NOT*${DEF} remove any currently deployed stacks."
    echo -e " -     ${cyn}-h | --help ${def}│ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu}[-> LEAVING THE DOCKER SWARM AND REMOVING INDICATED STACKS <-]${def}"; }
  fnc_script_outro(){ echo -e "${GRN}[-> DOCKER SWARM LEAVE SCRIPT COMPLETE <-]${DEF}"; echo; }
  fnc_nothing_to_do(){ echo -e "${YLW}[-> THIS NODE IS NOT PART OF A SWARM, CANNOT LEAVE NON-EXISTENT SWARM <-]${DEF}"; echo; }
  fnc_invalid_input(){ echo -e "${YLW}INVALID INPUT${DEF}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_remove_all_query(){ printf " Do you want to remove all Docker Swarm stacks (${YLW}highly recommended${def})? "; }
  fnc_msg_suggest_cleaning(){ echo -e "${YLW} >> CLEANING THE DOCKER ENVIRONMENT (${cyn}dprn${YLW}/${cyn}dcln${YLW}) AFTER LEAVING A SWARM IS RECOMMENDED <<${DEF}"; echo; }
  fnc_msg_stack_not_removed(){ echo -e " >> ${YLW}DOCKER SWARM STACKS WILL NOT BE REMOVED${DEF} << "; }
  fnc_swarm_check(){ if [[ "$(docker swarm leave -f)" == "Error response from daemon: This node is not part of a swarm" ]]; then fnc_nothing_to_do; exit 1; fi; }
  fnc_swarm_leave_force(){ docker swarm leave -f; echo; }
  fnc_docker_stack_stop(){ sh ${docker_scripts}/docker_stack_stop.sh -all; }
  fnc_docker_system_prune(){ sh ${docker_scripts}/docker_system_prune.sh --all; }
  fnc_docker_system_cleanup(){ if [[ "$input" = "yes" ]]; then fnc_docker_system_prune; else fnc_msg_suggest_cleaning; fi; }

# determine script output according to option entered
  case "${1}" in
    ("") # fnc_script_intro
      # fnc_swarm_check
      fnc_remove_all_query
      while read -r -p " [(Y)es/(N)o] " input; do
        case "${input}" in 
          ([yY]|[yY][eE][sS]) break ;;
          ([nN]|[nN][oO]) break ;;
          (*) fnc_invalid_input ;;
        esac
      done
      echo
      ;;
    (-*) # confirm entered option is valid
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-a"|"--all") input="yes" ;;
        ("-n"|"--none") input="no" ;;
        (*) fnc_invalid_syntax ;;
      esac
      ;;
  esac

# Remove stacks if input is Yes
    case $input in
      ([yY][eE][sS]|[yY]) fnc_docker_stack_stop ;;
      ([nN][oO]|[nN]) fnc_msg_stack_not_removed ;;
    esac

# Leave the swarm
  fnc_swarm_leave_force
  fnc_docker_system_cleanup
  fnc_script_outro
