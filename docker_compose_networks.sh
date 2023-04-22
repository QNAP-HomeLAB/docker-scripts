#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.script_vars.env
  # source /opt/docker/.docker_vars.env

# function definitions
  fnc_help(){
    echo -e "${blu}[-  This script creates Docker ${blu}networks${DEF} required for compose and swarm containers by ${CYN}Drauku${blu}  -]${DEF}"
    echo -e " - ${blu}(modified from ${CYN}gkoerk's (RIP)${blu} famously awesome networks for stacks)${DEF}"
    echo -e " -"
    echo -e " -   SYNTAX: dnc ${cyn}-option${DEF}"
    echo -e " -     VALID OPTIONS:"
    echo -e " -       ${cyn}-c │ --create ${DEF}│ ${grn}Creates${def} the ${blu}{netproxy,netsocket}${DEF} docker networks"
    echo -e " -       ${cyn}-d │ --delete ${DEF}│ ${red}Deletes${def} the ${blu}{netproxy,netsocket}${DEF} docker networks"
  }
  fnc_script_intro(){ echo -e "${blu}[-  CREATE DOCKER NETWORKS REQUIRED FOR USE WITH DOCKER SOCKET AND A REVERSE PROXY  -]${def}"; }
  fnc_script_outro(){ echo -e "${GRN} -  DOCKER NETWORKS '${var_net_rproxy} & ${var_net_socket}' CREATED${DEF}"; echo; exit 1; }
  fnc_nothing_to_do(){ echo -e "${YLW} >> A valid option and container name(s) must be entered for this command to work (use ${cyn}--help ${YLW}for info)${DEF}"; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE ${cyn}-help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; echo; exit 1; }
  fnc_invalid_input(){ echo -e "${YLW}INVALID INPUT${DEF}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }

# docker network create --driver "bridge" --opt "encrypted" --scope "local" --subnet "172.127.0.0/24" --attachable "docker_socket"
# docker network create --driver "bridge" --opt "encrypted" --scope "local" --subnet "172.127.1.0/24" --attachable "reverse_proxy"