#!/bin/bash

# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.conf

# function definitions
  fnc_script_intro(){ echo -e "${blu}[-> LISTING CURRENT DOCKER NETWORKS <-]${def}";}
  fnc_script_outro(){ echo; exit 1; }
  fnc_help(){
    echo -e "${blu}[-> This script allows the user to manage docker ${cyn}networks${def} <-]${def} "
    echo -e " -"
    echo -e " - SYNTAX: # dyn"
    echo -e " - SYNTAX: # dyn ${cyn}-option${def}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn}-h │ --help ${def}│ Displays this help message"
    fnc_script_outro
    }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE '${cyn}--help${YLW}' OPTION TO DISPLAY PROPER SYNTAX${DEF} <<" && fnc_script_outro; }
  fnc_network_list(){ docker network ls; }
  # fnc_network_check_dockersocket(){ docker network ls -q --filter name="${var_net_socket}"; }
  # fnc_network_check_proxynet(){ docker network ls -q --filter name="${var_net_rproxy}"; }
  fnc_network_check_by_name(){ docker network ls -q --filter name="${*}"; }
  fnc_network_swarm_verify(){
    unset increment IFS;
    while [[ ! "$(fnc_network_check_by_name "${var_net_socket}")" ]] || [[ ! "$(fnc_network_check_by_name "${var_net_rproxy}")" ]] || [[ ! "$(fnc_network_check_by_name "docker_gwbridge")" ]];
      do sleep 1;
      increment=$((increment+1));
      if [[ $increment -gt 10 ]];
        then fnc_swarm_error;
      fi;
    done;
    }
  fnc_network_create(){
    if [ "${scope}" = "swarm" ] && [ ! "$(fnc_network_check_by_name "ingress")" = "" ]; then docker network rm ingress; fi;
    if [ "${scope}" = "local" ] && [ ! "$(fnc_network_check_by_name "docker_gwbridge")" = "" ]; then docker network rm "docker_gwbridge"; fi;
    docker network create --driver "${driver}" --opt encrypted --scope "${scope}" --subnet "${var_subnet_socket}" --attachable "${var_net_socket}";
    docker network create --driver "${driver}" --opt encrypted --scope "${scope}" --subnet "${var_subnet_rproxy}" --attachable "${var_net_rproxy}";
    # docker network create --driver "${driver}" --opt encrypted --scope "${scope}" --subnet "${var_subnet_exedge}" --attachable "${var_net_exedge}";
    if [ "${scope}" = "swarm" ]; then docker network create --ingress --driver "${driver}" --opt encrypted --subnet "10.0.0.0/16" --gateway "10.0.0.254" ingress; fi;
    unset "${scope}";
    unset "${driver}";
    }
  fnc_network_remove(){
    docker network rm "${*}";
  }

# output determination logic
  case "${1}" in
    (""|"-l"|"--list")
      fnc_script_intro;
      fnc_network_list;
      fnc_script_outro;
      ;;
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help")
          fnc_help;
          ;;
        ("-c"|"--compose")
          driver="bridge"
          scope="local"
          fnc_network_create;
          ;;
        ("-d"|"-r"|"--delete"|"--remove")
          fnc_network_remove "${1}";
          ;;
        ("-w"|"-s"|"--swarm")
          driver="overlay"
          scope="swarm"
          fnc_network_create;
          ;;
        (*)
          fnc_invalid_syntax;
          ;;
      esac
      ;;
    (*)
      fnc_invalid_syntax;
      ;;
  esac