#!/bin/bash
# external variable sources
  source /share/docker/scripts/.script_vars.conf

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script lists logs for the indicated '${CYN}stackname_${cyn}servicename${blu}' <-]${def} "
    echo -e " -"
    echo -e " - SYNTAX: # dvl ${cyn}-option${def}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn}-h │ --help ${def}| Displays this help message."
    echo -e " -"
    echo -e " - SYNTAX: # dvl ${cyn}appname${def}"
    echo -e " - SYNTAX: # dvl ${cyn}appname${def} ${cyn}-option${def}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn}-l │ --long ${def}| Displays '${CYN}docker service ps --no-trunk ${cyn}appname${def}' output with non-truncated entries."
    echo
    echo -e " -   NOTE: ${cyn}appname${def} MUST consist of '${CYN}stackname_${cyn}servicename${def}' as defined in the .yml file. ex: 'traefik_app' or 'traefik_whoami'"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_service_logs(){ docker service logs "${1}"; }
  fnc_service_logs_long(){ docker service logs --no-trunc "${1}"; }

# determine script output according to option entered
  case "${1}" in 
    ("") fnc_invalid_syntax ;;
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        (*) fnc_invalid_syntax ;;
      esac
    ;;
    (*)
      case "${2}" in
        ("-l"|"--long") fnc_service_logs_long ;;
        (*) fnc_service_logs ;;
      esac
    ;;
  esac
