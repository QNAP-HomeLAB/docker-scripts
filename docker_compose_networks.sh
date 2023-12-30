#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-  This script creates Docker ${blu:?}networks${def:?} required for compose and swarm containers by ${cyn:?}Drauku${blu:?}  -]${def:?}"
    echo -e " - ${blu:?}(modified from ${cyn:?}gkoerk's (RIP)${blu:?} famously awesome networks for stacks)${def:?}"
    echo -e " -"
    echo -e " -   SYNTAX: dnc ${cyn:?}-option${def:?}"
    echo -e " -     VALID OPTIONS:"
    echo -e " -       ${cyn:?}-c │ --create ${def:?}│ ${grn:?}Creates${def:?} the ${blu:?}{netproxy,netsocket}${def:?} docker networks"
    echo -e " -       ${cyn:?}-d │ --delete ${def:?}│ ${red:?}Deletes${def:?} the ${blu:?}{netproxy,netsocket}${def:?} docker networks"
    echo -e " -       ${cyn:?}-l │ --list   ${def:?}│ ${red:?}Lists${def:?} the current docker networks"
    echo
  }
  case "${1}" in ("-h"|*"help"*) fnc_help ;; esac
  fnc_script_intro(){ echo -e "${blu:?}[-  CREATE DOCKER NETWORKS REQUIRED FOR USE WITH DOCKER SOCKET AND A REVERSE PROXY  -]${def:?}"; }
  fnc_script_outro(){ echo -e "${grn:?} -  DOCKER NETWORKS '${var_net_rproxy} & ${var_net_socket}' CREATED${def:?}"; echo; exit 1; }
  fnc_nothing_to_do(){ echo -e "${ylw:?} >> A valid option and container name(s) must be entered for this command to work (use ${cyn:?}--help ${ylw:?}for info)${def:?}"; }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE ${cyn:?}-help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; echo; exit 1; }
  fnc_invalid_input(){ echo -e "${ylw:?}INVALID INPUT${def:?}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }

  fnc_create_networks() {
    docker network create --driver "bridge" --opt "encrypted" --scope "local" --subnet "172.27.0.0/24" --gateway "172.27.0.254" --attachable "docker_socket"
    docker network create --driver "bridge" --opt "encrypted" --scope "local" --subnet "172.27.1.0/24" --gateway "172.27.1.254" --attachable "external_edge"
    docker network create --driver "bridge" --opt "encrypted" --scope "local" --subnet "172.27.2.0/24" --gateway "172.27.2.254" --attachable "reverse_proxy"
  }
  fnc_delete_networks() {
    docker network rm "docker_socket"
    docker network rm "external_edge"
    docker network rm "reverse_proxy"
  }
  fnc_list_networks() {
    docker network ls
  }

case "${1}" in
  "-c"|"--create")
    fnc_create_networks ;;
  "-d"|"--delete")
    fnc_delete_networks ;;
  "-l"|"--list"|"")
    fnc_list_networks ;;
  *)
    fnc_nothing_to_do ;;
esac