#!/bin/bash
# external variable sources
  source /share/docker/scripts/.bash_colors.env

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script lists 'current state' for the indicated '${CYN}stackname_${cyn}servicename${blu}' <-]${def} "
    echo
    echo -e "SYNTAX: # dve -${cyn}option${def}"
    echo -e "  VALID OPTION(S):"
    echo -e "    -h │ -help   Displays this help message."
    echo
    echo -e "SYNTAX: # dve ${cyn}appname${def}"
    echo -e "SYNTAX: # dve ${cyn}appname${def} -${cyn}option${def}"
    echo -e "  VALID OPTION(S):"
    echo -e "    -l │ -long   Displays '${CYN}docker service ps --no-trunk ${cyn}appname${def}' output with non-truncated entries."
    echo
    echo -e "  NOTE: ${cyn}appname${def} MUST consist of '${CYN}stackname_${cyn}servicename${def}' as defined in the .yml file. ex: 'traefik_app' or 'traefik_whoami'"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_service_status(){ docker service ps "${1}"; }
  fnc_service_status_check(){ docker service ps "${1}" --format "{{.Error}}"; }
  fnc_service_status_short(){ docker service ps "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Ports}}"; }
  fnc_service_status_error(){ docker service ps "${1}" --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}"; }

# determine script output according to option entered
  case "${1}" in 
    (-*)
      case "${1}" in
        (""|"-h"|"-help"|"--help") fnc_help ;;
        (*) fnc_invalid_syntax ;;
      esac
    ;;
    (*)
      case "${2}" in
        ("-l"|"-long") fnc_service_status ;;
        (*)
          if [[ ! fnc_service_status_check ]]
          then fnc_service_status_short
          else fnc_service_status_error
          fi
        ;;
      esac
    ;;
  esac
