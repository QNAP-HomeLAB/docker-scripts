#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# function definitions
  fnc_help_compose_logs(){
    echo -e "${blu:?}[-> # This script displays 50 log entries for the indicated docker compose container. <-]${def:?}"
    echo -e " -"
    echo -e " - SYNTAX: # dcl ${cyn:?}container_name${def:?}"
    echo -e " - SYNTAX: # dcl ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}-h │ --help    ${def:?}│ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }
  case "$1" in ("-h"|*"help"*) fnc_help_compose_logs ;; esac

  fnc_script_intro(){ echo -e "${blu:?}[-> LISTING THE 50 MOST RECENT DOCKER COMPOSE LOG ENTRIES <-]${def:?}"; }
  fnc_script_outro(){ echo -e "${grn:?}[-- MOST RECENT 50 LOG ENTRIES LISTED --]${def:?}"; echo; }
  fnc_nothing_to_do(){ echo -e "${ylw:?} -> no log entries to display${def:?}"; }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE -${cyn:?}help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  fnc_compose_logs(){ docker compose logs -tf --tail="50" "${docker_compose}/${1}/compose.yml"; }

# option logic action determination
  case "${1}" in
    (-*) # validate entered option exists
      case "${1}" in
        (*) echo -e "${ylw:?} >> INVALID OPTION SYNTAX -- USE THE -${cyn:?}help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1 ;;
      esac
      ;;
    (*) fnc_script_intro;
      if [ "$(fnc_compose_logs)" ]
      then fnc_compose_logs "${1}"
      else fnc_nothing_to_do
      fi
      echo
      ;;
  esac
