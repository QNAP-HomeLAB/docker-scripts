#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-> This script lists 'current state' for the indicated '${cyn:?}stackname_${cyn:?}servicename${blu:?}' <-]${def:?} "
    echo -e " -"
    echo -e " - SYNTAX: # dve ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn:?}-h │ --help ${def:?}| Displays this help message."
    echo -e " -"
    echo -e " - SYNTAX: # dve ${cyn:?}appname${def:?}"
    echo -e " - SYNTAX: # dve ${cyn:?}appname${def:?} ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn:?}-l │ --long ${def:?}| Displays '${cyn:?}docker service ps --no-trunk ${cyn:?}appname${def:?}' output with non-truncated entries."
    echo -e " -"
    echo -e " - NOTE: ${cyn:?}appname${def:?} MUST consist of '${cyn:?}stackname_${cyn:?}servicename${def:?}' as defined in the .yml file. ex: 'traefik_app' or 'traefik_whoami'"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE -${cyn:?}help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  fnc_service_basic(){ docker service ps "${1}"; }
  fnc_service_check(){ docker service ps "${1}" --format "{{.Error}}"; }
  fnc_service_short(){ docker service ps "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Ports}}"; }
  fnc_service_error(){ docker service ps "${1}" --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}"; }

# determine script output according to option entered
  case "${1}" in
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        (*) fnc_invalid_syntax ;;
      esac
    ;;
    (*)
      case "${2}" in
        ("-l"|"--long") fnc_service_basic "${1}" ;;
        (*)
          if [[ ! "$(fnc_service_check "${1}")" ]]
          then fnc_service_short "${1}"
          else fnc_service_error "${1}"
          fi
        ;;
      esac
    ;;
  esac
