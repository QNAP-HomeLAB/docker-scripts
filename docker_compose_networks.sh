#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.conf

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-  This script creates Docker ${blu:?}networks${def:?} required for compose and swarm containers by ${CYN:?}Drauku${blu:?}  -]${def:?}"
    echo -e " - ${blu:?}(modified from ${CYN:?}gkoerk's (RIP)${blu:?} famously awesome networks for stacks)${def:?}"
    echo -e " -"
    echo -e " -   SYNTAX: dnc ${cyn:?}-option${def:?}"
    echo -e " -     VALID OPTIONS:"
    echo -e " -       ${cyn:?}-c │ --create ${def:?}│ ${grn:?}Creates${def:?} the ${blu:?}{netproxy,netsocket}${def:?} docker networks"
    echo -e " -       ${cyn:?}-d │ --delete ${def:?}│ ${red:?}Deletes${def:?} the ${blu:?}{netproxy,netsocket}${def:?} docker networks"
  }
  fnc_script_intro(){ echo -e "${blu:?}[-  CREATE DOCKER NETWORKS REQUIRED FOR USE WITH DOCKER SOCKET AND A REVERSE PROXY  -]${def:?}"; }
  fnc_script_outro(){ echo -e "${GRN:?} -  DOCKER NETWORKS '${var_net_rproxy} & ${var_net_socket}' CREATED${def:?}"; echo; exit 1; }
  fnc_nothing_to_do(){ echo -e "${YLW:?} >> A valid option and container name(s) must be entered for this command to work (use ${cyn:?}--help ${YLW:?}for info)${def:?}"; }
  fnc_invalid_syntax(){ echo -e "${YLW:?} >> INVALID OPTION SYNTAX, USE THE ${cyn:?}-help${YLW:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; echo; exit 1; }
  fnc_invalid_input(){ echo -e "${YLW:?}INVALID INPUT${def:?}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }

# docker network create --driver "bridge" --opt "encrypted" --scope "local" --subnet "172.27.0.0/24" --gateway "172.27.0.254" --attachable "docker_socket"
# docker network create --driver "bridge" --opt "encrypted" --scope "local" --subnet "172.27.1.0/24" --gateway "172.27.1.254" --attachable "external_edge"
# docker network create --driver "bridge" --opt "encrypted" --scope "local" --subnet "172.27.2.0/24" --gateway "172.27.2.254" --attachable "reverse_proxy"
