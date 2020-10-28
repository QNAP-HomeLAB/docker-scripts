#!/bin/bash
# external variable sources
  source /share/docker/scripts/.script_vars.conf

# function definitions
  fnc_help(){
    echo -e "${blu}[-> # This script displays 50 log entries for the indicated docker-compose container. <-]${DEF}"
    echo -e " -"
    echo -e " - SYNTAX: # dcl ${cyn}container_name${DEF}"
    echo -e " - SYNTAX: # dcl ${cyn}-option${DEF}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn}-h │ --help    ${DEF}│ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu}[-> LISTING THE 50 MOST RECENT DOCKER-COMPOSE LOG ENTRIES <-]${DEF}"; }
  fnc_script_outro(){ echo -e "${GRN}[-- MOST RECENT 50 LOG ENTRIES LISTED --]${DEF}"; echo; }
  fnc_nothing_to_do(){ echo -e "${YLW} -> no log entries to display${DEF}"; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_compose_logs(){ docker-compose logs -tf --tail="50" "$1"; }

# option logic action determination
  case "${1}" in 
    (-*) # validate entered option exists
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1 ;;
      esac
      ;;
    (*) fnc_script_intro; 
      if [ "$(fnc_compose_logs)" ]
      then fnc_compose_logs 
      else fnc_nothing_to_do
      fi
      echo
      ;;
  esac
