#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.conf

# script variable definitions
  conftype="-compose"

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-  This script STOPS or brings DOWN a single Docker container using a pre-written compose file  -]${def:?}"
    echo -e " -"
    echo -e " - SYNTAX: # dcd | dcr | dcp"
    echo -e " - SYNTAX: # dcd ${cyn:?}stack_name${def:?}"
    echo -e " - SYNTAX: # dcd ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}-h │ --help ${def:?}| Displays this help message."
    echo -e " -     ${cyn:?}-a | --all  ${def:?}| Brings down all docker containers shown with the 'docker ps' command."
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu:?}[-  STOPPING LISTED DOCKER CONTAINERS  -]${def:?}"; }
  fnc_script_outro(){ echo -e "${blu:?}[-  LISTED DOCKER CONTAINERS ${red}STOPPED${blu:?}  -]${def:?}"; }
  fnc_nothing_to_do(){ echo -e "${YLW:?} -> no configuration files exist${def:?}"; }
  fnc_invalid_syntax(){ echo -e "${YLW:?} >> INVALID OPTION SYNTAX, USE THE -${cyn:?}help${YLW:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  fnc_list_processing(){ remove_list="$(for stack in "${remove_list[@]}" ; do echo "$stack" ; done | sort -u)"; }
  fnc_configs_list_all(){ IFS=$'\n' remove_list=("$(docker container list --format {{.Names}})"); }
  fnc_docker_compose_down(){ docker compose -f "${docker_compose}/${remove_list[stack]}/${remove_list[stack]}${conftype}.yml" down; }
  fnc_docker_compose_stop(){ docker compose -f "${docker_compose}/${remove_list[stack]}/${remove_list[stack]}${conftype}.yml" stop; }
  fnc_env_file_remove(){ [ -f "${docker_compose}/${stack}/.env" ] && rm -f "${docker_compose}/${stack}/.env"; }

# option logic action determination
  case "${1}" in
    ("") fnc_nothing_to_do ;;
    (-*) # validate entered option exists
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-a"|"--all") fnc_configs_list_all ;;
        ("-r"|"--") fnc_configs_list_all ;;
        (*) fnc_invalid_syntax ;;
      esac
      ;;
    (*) remove_list=("$@") ;;
  esac

# Perform scripted action(s)
  fnc_list_processing
  for stack in "${!remove_list[@]}"; do
    fnc_docker_compose_down
    # fnc_env_file_remove
    sleep 1
  done