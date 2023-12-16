#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-> This script lists all docker ${cyn:?}volumes${def:?} <-]${def:?} "
    echo -e " -"
    echo -e " - SYNTAX: # dlv"
    echo -e " - SYNTAX: # dlv ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn:?}-h │ --help ${def:?}│ Displays this help message"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu:?}[-> LISTING UNUSED DOCKER VOLUMES <-]${def:?}";}
  fnc_script_outro(){ echo; }
  fnc_nothing_to_do(){ echo -e "${ylw:?} -> no volumes exist${def:?}"; }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE '--${cyn:?}help${ylw:?}' OPTION TO DISPLAY PROPER SYNTAX${def:?} <<"; exit 1; }
  fnc_docker_volumes_check(){ docker volume ls -qf dangling=true; }
  fnc_docker_volumes_list(){ docker volume ls; }

# output determination logic
  case "${1}" in
    ("")
      fnc_script_intro
      if [ "$(fnc_docker_volumes_check)" ]
      then fnc_docker_volumes_list
      else fnc_nothing_to_do
      fi
      fnc_script_outro
      ;;
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        (*) fnc_invalid_syntax ;;
      esac
  esac
