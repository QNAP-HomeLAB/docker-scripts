#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/.bash_colors.env

# Help message for script
helpFunction(){
  echo -e "${blu}[-> This script lists logs for the indicated '${CYN}stackname_${cyn}servicename${blu}' <-]${def} "
  echo
  echo -e "SYNTAX: # dvl -${cyn}option${def}"
  echo -e "  VALID OPTION(S):"
  echo -e "    -h │ -help   Displays this help message."
  echo
  echo -e "SYNTAX: # dvl ${cyn}appname${def}"
  echo -e "SYNTAX: # dvl ${cyn}appname${def} -${cyn}option${def}"
  echo -e "  VALID OPTION(S):"
  echo -e "    -l │ -long   Displays '${CYN}docker service ps --no-trunk ${cyn}appname${def}' output with non-truncated entries."
  echo
  echo -e "  NOTE: ${cyn}appname${def} MUST consist of '${CYN}stackname_${cyn}servicename${def}' as defined in the .yml file. ex: 'traefik_app' or 'traefik_whoami'"
  echo
  exit 1 # Exit script after printing help
  }

# determine script output according to option entered
  case "${1}" in 
    (-*)
      case "${1}" in
        (""|"-h"|"-help"|"--help") helpFunction ;;
        (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1 ;;
      esac
    ;;
    (*)
      case "${2}" in
        ("-l"|"-long") docker service logs --no-trunc "${1}" ;;
        (*) docker service logs "${1}" ;;
      esac
    ;;
  esac
