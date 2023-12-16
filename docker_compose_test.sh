#!/bin/bash

source /opt/docker/scripts/.color_codes.conf
source /opt/docker/scripts/.vars_docker.env

#function definitions
    fnc_help_docker_compose_test(){
        echo -e "${blu:?}[-  This script displays the indicated compose file with variables/secrets filled in. -]${def:?}"
        echo -e " -"
        echo -e " - SYNTAX: # dcc | dct | dctest ${cyn:?}stack_name${def:?}"
        # echo -e " - SYNTAX: # dcd ${cyn:?}-option${def:?}"
        echo -e " -   VALID OPTIONS:"
        echo -e " -     ${cyn:?}-h │ --help   ${def:?}| Displays this help message."
        echo
        exit 1 # Exit script after printing help
    }
    case "$1" in ("-h"|*"help"*) fnc_help_docker_compose_test ;; esac

    fnc_intro_docker_compose_test(){ echo -e "${blu:?}[-  ${mgn:?}DISPLAYING${blu:?} COMPLETED COMPOSE FILE FOR ${cyn:?}stack_name${blu:?}  -]${def:?}"; }
    fnc_outro_docker_compose_test(){ echo -e "${blu:?}[-  ${cyn:?}\`docker compose config\`${def:?} display complete.  -]${def:?}"; }
    fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE ${cyn:?}-help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
    fnc_nothing_to_do(){ echo -e "${ylw:?} -> No compose or stack specified. Expected synatax: ${def:?}dcc ${cyn:?}stack_name${def:?}"; }

    fnc_docker_compose_test(){ docker compose -f "${docker_compose:?}/${1}/${var_configs_file:?}" config; }

    case "$1" in
        *) fnc_intro_docker_compose_test; fnc_docker_compose_test "${@}"; fnc_outro_docker_compose_test;;
        # "dct") fnc_intro_docker_compose_test; fnc_docker_compose_test "${@}"; fnc_outro_docker_compose_test;;
        # "dctest") fnc_intro_docker_compose_test; fnc_docker_compose_test "${@}"; fnc_outro_docker_compose_test;;
        # "") fnc_nothing_to_do;;
        # *) fnc_invalid_syntax;;
    esac