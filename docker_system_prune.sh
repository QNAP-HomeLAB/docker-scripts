#!/bin/bash
# external variable sources
  source /share/docker/scripts/.script_vars.conf

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script prunes (removes) '${CYN}container${blu}' ${cyn}images${def}, ${cyn}volumes${blu} and ${CUR}unused${def} ${cyn}networks${blu} <-]${def} "
    echo -e " -"
    echo -e " - SYNTAX: # dprn"
    echo -e " - SYNTAX: # dprn ${cyn}-option${def}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn}-a │ --all  ${def}│ Stops all containers then removes all '${CYN}container${blu}' ${cyn}images${def}, ${cyn}volumes${def} and ${CUR}unused${def} ${cyn}networks${def}"
    echo -e " -     ${cyn}-h │ --help ${def}│ Displays this help message"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_intro(){ echo -e "${blu}[-> PRUNING THE DOCKER SYSTEM <-]${DEF}"; }
  fnc_outro(){ echo -e "${GRN}[-- DOCKER SYSTEM PRUNE COMPLETE --]${DEF}"; echo; }
  fnc_prune(){ docker system prune --all --force --volumes; }
  fnc_container_list(){ docker container ls --all --quiet; }
  fnc_container_stop(){ docker stop $(fnc_container_list); }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_invalid_input(){ echo -e "${YLW}INVALID INPUT${DEF}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
  fnc_nothing_to_do(){ echo -e " - ${YLW}nothing to prune from the docker environment${DEF}"; }
  fnc_query_remove_all(){ printf "Are you sure you want to ${red}STOP${def} and ${ylw}REMOVE${def} all containers?"; }

# Script start notification
  fnc_intro

# Script logic and execution
  case "${1}" in 
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-a"|"--all")
          if [[ "$(fnc_container_list)" ]]; then 
            fnc_query_remove_all
            while read -r -p " [(Y)es/(N)o] " input; do
              case "${input}" in 
                ([yY]|[yY][eE][sS]) fnc_container_stop && echo && fnc_prune && break;;
                ([nN]|[nN][oO]) break ;;
                (*) fnc_invalid_input ;;
              esac
            done
          else fnc_nothing_to_do
          fi
          ;;
        (*) fnc_invalid_syntax ;;
      esac
      ;;
    (*) fnc_prune ;;
  esac

# Script completion notice
  echo
  # fnc_outro