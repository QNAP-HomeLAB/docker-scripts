#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# script variable definitions
  unset deploy_list IFS

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-> This script performs Docker Swarm initialization tasks on QNAP Container Station architecture. <-]${def:?}"
    echo -e " -"
    echo -e " - SYNTAX: # dwinit"
    echo -e " - SYNTAX: # dwinit ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}stackname      ${def:?}│ Creates the Docker Swarm, then deploys the '${cyn:?}stackname${def:?}' swarm stack if a config file exists."
    echo -e " -     ${cyn:?}-a | --all     ${def:?}│ Creates the Docker Swarm, then deploys all stacks with a corresponding folder inside the '${ylw:?}${docker_swarm}/${def:?}' path."
    echo -e " -     ${cyn:?}-d | --default ${def:?}│ Creates the Docker Swarm, then deploys the 'default' array of stacks defined in '${ylw:?}${docker_vars}/${cyn:?}swarm_stacks.conf${def:?}'"
    echo -e " -     ${cyn:?}-p | --preset  ${def:?}│ Creates the Docker Swarm, then deploys the 'preset' array of stacks defined in '${ylw:?}${docker_vars}/${cyn:?}swarm_stacks.conf${def:?}'"
    echo -e " -     ${cyn:?}-h │ --help    ${def:?}│ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu:?}[-> INITIALIZE DOCKER SWARM AND INSTALL INDICATED STACKS <-]${def:?}"; }
  fnc_script_outro(){ echo -e "${grn:?}[-> DOCKER SWARM INITIALIZATION SCRIPT COMPLETE <-]${def:?}"; echo; }
  fnc_invalid_input(){ echo -e "${ylw:?}INVALID INPUT${def:?}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE -${cyn:?}help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  fnc_nothing_to_do(){ echo -e " >> ${ylw:?}SWARM STACKS WILL NOT BE DEPLOYED${def:?} << "; echo; }
  fnc_deploy_query(){ echo -e "Do you want to deploy the '-${cyn:?}default${def:?}' list of Docker Swarm stacks?"; }
  fnc_deploy_stack(){ if [ ! "${deploy_list}" ] || [ "${deploy_list}" = "-n" ]; then fnc_nothing_to_do; else sh "${docker_scripts}"/docker_stack_start.sh "${deploy_list}"; fi; }
  fnc_traefik_query(){ echo -e " - Should ${cyn:?}traefik${def:?} still be installed (${ylw:?}recommended${def:?})?"; }
  fnc_folder_creation(){ if [[ ! -d "${docker_folder}/{scripts,secrets,swarm,compose}" ]]; then mkdir -pm 600 "${docker_folder}"/{scripts,secrets,swarm/{appdata,configs},compose/{appdata,configs}}; fi; }
  fnc_folder_owner(){ chown -R ${var_user}:${var_group} ${swarm_folder}; echo "FOLDER OWNERSHIP UPDATED"; echo; }
  fnc_folder_auth(){ chmod -R 600 ${swarm_folder}; echo "FOLDER PERMISSIONS UPDATED"; echo; }
  fnc_swarm_init(){ docker swarm init --advertise-addr "${var_host_ip}"; }
  fnc_swarm_verify(){ while [[ "$(docker stack ls)" != "NAME                SERVICES   ORCHESTRATOR" ]]; do sleep 1; done; }
  # fnc_swarm_check(){ while [[ ! "$(docker stack ls --format "{{.Name}}")" ]]; do sleep 1; done; }
  fnc_swarm_success(){ echo; echo -e " >> ${grn:?}DOCKER SWARM INITIALIZED SUCCESSFULLY${def:?} << "; echo; }
  fnc_swarm_error(){
    docker network ls
    echo
    echo -e " >> THE ABOVE LIST MUST INCLUDE THE '${cyn:?}docker_gwbridge${def:?}' AND '${cyn:?}${var_net_rproxy}${def:?}' NETWORKS"
    echo -e " >> IF EITHER OF THOSE NETWORKS ARE NOT LISTED, YOU MUST LEAVE, THEN RE-INITIALIZE THE SWARM"
    echo -e " >> IF YOU HAVE ALREADY ATTEMPTED TO RE-INITIALIZE, ASK FOR HELP HERE: ${mgn:?} https://discord.gg/KekSYUE ${def:?}"
    echo
    echo -e " >> ${ylw:?}DOCKER SWARM STACKS WILL NOT BE DEPLOYED${def:?} << "
    echo
    echo -e " -- ${red:?}ERROR${def:?}: DOCKER SWARM SETUP WAS ${ylw:?}NOT SUCCESSFUL${def:?} -- "
    exit 1 # Exit script here
    }
  fnc_network_gwbridge(){
    docker network rm docker_gwbridge
    docker network create --driver bridge --scope local --opt encrypted --subnet 172.20.0.0/16 --gateway 172.20.0.254 \
    --opt com.docker.network.bridge.enable_icc=false \
    --opt com.docker.network.bridge.enable_ip_masquerade=true \
    --opt com.docker.network.bridge.name=docker_gwbridge \
    docker_gwbridge
  }
# docker network rm ingress
# docker network create --driver overlay --opt encrypted --ingress --subnet 10.27.0.0/16 --gateway 10.27.0.254 ingress
# docker network create --driver overlay --opt encrypted --scope swarm --subnet=172.27.0.0/16 --gateway=172.27.0.254 --attachable docker_socket
# docker network create --driver overlay --opt encrypted --scope swarm --subnet=172.27.1.0/16 --gateway=172.27.1.254 --attachable external_edge
# docker network create --driver overlay --opt encrypted --scope swarm --subnet=172.27.2.0/16 --gateway=172.27.2.254 --attachable reverse_proxy
  fnc_network_init(){ # copy fnc_network_check from docker/scripts/docker_system_network.sh
    docker network rm ingress && docker network create --driver overlay --opt encrypted --ingress --subnet "${var_subnet_ingress}" --gateway "${var_gateway_ingress}" ${var_net_ingress};
    docker network create --driver overlay --opt encrypted --scope swarm --subnet "${var_subnet_socket}" --gateway "${var_gateway_socket}" --attachable "${var_net_socket}";
    docker network create --driver overlay --opt encrypted --scope swarm --subnet "${var_subnet_rproxy}" --gateway "${var_gateway_rproxy}" --attachable "${var_net_rproxy}";
    docker network create --driver overlay --opt encrypted --scope swarm --subnet "${var_subnet_exedge}" --gateway "${var_gateway_exedge}" --attachable "${var_net_exedge}";
  }
  fnc_network_check_dockersocket(){ docker network ls --filter name="${var_net_socket}" -q; }
  fnc_network_check_proxynet(){ docker network ls --filter name="${var_net_rproxy}" -q; }
  fnc_network_check_gwbridge(){ docker network ls --filter name=docker_gwbridge -q; }
  fnc_network_verify(){
    unset increment IFS;
    while [[ ! "$(fnc_network_check_proxynet)" ]] || [[ ! "$(fnc_network_check_gwbridge)" ]];
      do sleep 1;
      increment=$((increment+1)); # should it be '$increment++'?
      if [[ $increment -gt 10 ]];
        then fnc_swarm_error;
      fi;
    done;
    }
  fnc_network_success(){ echo; echo -e " ++ ${grn:?}CREATED '${cyn:?}docker_gwbridge${grn:?}' AND '${cyn:?}${var_net_rproxy}${grn:?}' NETWORKS${def:?} ++ "; }

# fnc_script_intro

# determine script output according to option entered
  case "${1}" in
    ("") fnc_deploy_query
      while read -r -p " [(Y)es/(N)o] " input; do
        case "${input}" in
          ([yY]|[yY][eE][sS]) deploy_list="--default"; break ;;
          ([nN]|[nN][oO]) fnc_traefik_query
            while read -r -p " [(Y)es/(N)o] " confirm; do
              case "${confirm}" in
                ([yY]|[yY][eE][sS]) deploy_list="traefik"; break ;;
                ([nN]|[nN][oO]) break ;;
                (*) fnc_invalid_input ;;
              esac
            done
            break ;;
          (*) fnc_invalid_input ;;
        esac
      done
      echo
      ;;
    (-*) # confirm entered option switch is valid
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-a"|"--all") deploy_list="${1}" ;;
        ("-d"|"--default") deploy_list="${1}" ;;
        ("-p"|"--preset") deploy_list="${1}" ;;
        ("-n"|"--none") deploy_list="-n" ;;
        (*) fnc_invalid_syntax ;;
      esac
      ;;
    (*) deploy_list=("$@") ;;
  esac

fnc_folder_creation
# fnc_folder_owner
# fnc_folder_auth

# must remove and recreate docker_gwbridge before swarm init to make it encrypted
# fnc_network_gwbridge
fnc_swarm_init
fnc_swarm_verify

fnc_network_init
fnc_network_verify
fnc_network_success

fnc_swarm_success

fnc_deploy_stack

fnc_script_outro



## from docker_scripts_setup:


# # Swarm initialization
#   #echo -e " -> INITIALIZING SWARM <- "
#   docker swarm init --advertise-addr "${var_host_ip}"

# # Required networks creation verification
#   docker network create --driver=overlay --subnet=${var_subnet_rproxy} --attachable ${var_net_rproxy}
#   increment=0; # reset the increment variable
#   while [[ "$(docker network ls --filter name=traefik -q)" = "" ]] || [[ "$(docker network ls --filter name=gwbridge -q)" = "" ]]; do
#     sleep 1;
#     increment=$(($increment+1));
#     if [[ $increment -gt 10 ]]; then # max 10 seconds wait for network to be created
#       docker network ls
#       echo
#       echo -e " ->> THE ABOVE LIST MUST INCLUDE THE '${cyn:?}docker_gwbridge${def:?}' AND '${cyn:?}traefik_public${def:?}' NETWORKS"
#       echo -e " ->> IF EITHER OF THOSE NETWORKS ARE NOT LISTED, YOU MUST LEAVE, THEN RE-INITIALIZE THE SWARM"
#       echo -e " ->> IF YOU HAVE ALREADY ATTEMPTED TO RE-INITIALIZE, ASK FOR HELP HERE: ${mgn:?} https://discord.gg/KekSYUE ${def:?}"
#       echo
#       echo -e " ->> ${ylw:?}DOCKER SWARM STACKS WILL NOT BE DEPLOYED${def:?} << "
#       echo
#       echo -e " --- ${red:?}ERROR${def:?}: DOCKER SWARM SETUP WAS ${ylw:?}NOT SUCCESSFUL${def:?} -- "
#       exit 1 # Exit script here
#     fi
#   done
#   # while [[ "$(docker network ls --filter name=traefik_public -q)" = "" ]]; do sleep 1; done
#   # while [[ "$(docker network ls --filter name=docker_gwbridge -q)" = "" ]]; do sleep 1; done
#   echo
#   echo -e " ++ '${cyn:?}docker_gwbridge${def:?}' AND '${cyn:?}traefik_public${def:?}' NETWORKS ${grn:?}CREATED${def:?} ++ "

#   # Pause until swarm is initialized
#   while [[ "$(docker stack ls)" != "NAME                SERVICES" ]]; do sleep 1; done
#   echo
#   echo -e " >> ${grn:?}SWARM INITIALIZED${def:?} << "
#   echo

# # Stack deployment
#   if [[ "$1" = "" ]]; then
#     case "${input}" in
#       ([yY]|[yY][eE][sS])
#         . "${docker_scripts}"/docker_stack_start.sh -default
#         ;;
#       ([nN]|[nN][oO])
#         case "${confirm}" in
#           ([yY]|[yY][eE][sS])
#             . "${docker_scripts}"/docker_stack_start.sh traefik
#           ;;
#           (*) echo -e " >> ${ylw:?}DOCKER SWARM STACKS WILL NOT BE DEPLOYED${def:?} << " ;;
#         esac
#         ;;
#     esac
#   else
#     . "${docker_scripts}"/docker_stack_start.sh "$1"
#   fi


  # if [[ "$1" = "" ]] ; then
  #   printf "Do you want to deploy the '-${cyn:?}default${def:?}' list of Docker Swarm stacks?"; read -r -p " [(Y)es/(N)o] " input
  #   case $input in
  #     ([yY]|[yY][eE][sS]) ;;
  #     ([nN]|[nN][oO])
  #       # Query if Traefik should still be deployed
  #       printf " - Should ${cyn:?}traefik${def:?} still be installed (${ylw:?}recommended${def:?})?"; read -r -p " [(Y)es/(N)o] " confirm
  #       case $input in
  #         ([yY]|[yY][eE][sS]) ;;
  #         ([nN]|[nN][oO]) ;;
  #         (*) echo -e "${ylw:?}INVALID INPUT${def:?}: Must be any case-insensitive variation of 'yes' or 'no'." ;;
  #       esac
  #       ;;
  #     (*) echo -e "${ylw:?}INVALID INPUT${def:?}: Must be any case-insensitive variation of 'yes' or 'no'." ;;
  #   esac
  #   echo
  # fi

