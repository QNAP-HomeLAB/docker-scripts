#!/bin/bash
# external variable sources
  source /share/docker/scripts/.script_vars.conf

# script variable definitions
  conftype="-compose"

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script STOPS (bring 'down') a single Docker container using a pre-written compose file <-]${DEF}"
    echo -e " -"
    echo -e " - SYNTAX: # dcd | dcr | dcp"
    echo -e " - SYNTAX: # dcd ${cyn}stack_name${DEF}"
    echo -e " - SYNTAX: # dcd ${cyn}-option${DEF}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn}-h │ --help ${DEF}| Displays this help message."
    echo -e " -     ${cyn}-a | --all  ${DEF}| Brings down all docker containers shown with the 'docker ps' command."
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu}[-> EXISTING DOCKER CONFIG FILES IN ${YLW}${configs_path}/${blu} <-]${DEF}"; }
  fnc_nothing_to_do(){ echo -e "${YLW} -> no configuration files exist${DEF}"; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_configs_list_all(){ IFS=$'\n' remove_list=("$(docker ps --format {{.Names}})"); }
  fnc_create_remove_list(){ remove_list=(`for stack in "${remove_list[@]}" ; do echo "$stack" ; done | sort -u`); }
  fnc_docker_compose_down(){ docker-compose -f ${compose_configs}/${remove_list[stack]}/${remove_list[stack]}${conftype}.yml down; }
  fnc_env_file_remove(){ [ -f "${compose_configs}/${stack}/.env" ] && rm -f "${compose_configs}/${stack}/.env"; }
  # fnc_script_outro(){ ; }

# option logic action determination
  case "${1}" in 
    ("") fnc_nothing_to_do ;;
    (-*) # validate entered option exists
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-a"|"--all") fnc_configs_list_all ;;
        (*) fnc_invalid_syntax ;;
      esac
      ;;
    (*) remove_list=("$@") ;;
  esac

# Perform scripted action(s)
  fnc_create_remove_list
  for stack in "${!remove_list[@]}"; do
    fnc_docker_compose_down
    fnc_env_file_remove
    sleep 1
  done