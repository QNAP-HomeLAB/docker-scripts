#!/bin/bash
# external variable sources
  source /share/docker/scripts/.script_vars.conf

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script lists all docker ${cyn}networks${def} <-]${def} "
    echo -e " -"
    echo -e " - SYNTAX: # dln"
    echo -e " - SYNTAX: # dln ${cyn}-option${def}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn}-h │ --help ${def}│ Displays this help message"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu}[-> LISTING CURRENT DOCKER NETWORKS <-]${def}";}
  fnc_script_outro(){ echo; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE '--${cyn}help${YLW}' OPTION TO DISPLAY PROPER SYNTAX${DEF} <<"; exit 1; }
  fnc_docker_networks(){ docker network ls; }

# output determination logic
  case "${1}" in 
    ("")
      fnc_script_intro
      fnc_docker_networks
      fnc_script_outro
      ;;
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        (*) fnc_invalid_syntax ;;
      esac
  esac
