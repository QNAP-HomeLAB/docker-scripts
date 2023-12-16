#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-> This script displays '${cyn:?}docker image${blu:?}' information. <-]${def:?} "
    echo -e " -"
    echo -e " - SYNTAX: # dimage"
    echo -e " - SYNTAX: # dimage ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn:?}-a │ --all  ${def:?}│ "
    echo -e " -     ${cyn:?}-h │ --help ${def:?}│ Displays this help message"
    echo
    exit 1 # Exit script after printing help
    }
