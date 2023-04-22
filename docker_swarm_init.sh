#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.conf

# script variable definitions
  unset deploy_list IFS

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script performs Docker Swarm initialization tasks on QNAP Container Station architecture. <-]${DEF}"
    echo -e " -"
    echo -e " - SYNTAX: # dwinit"
    echo -e " - SYNTAX: # dwinit ${cyn}-option${DEF}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn}stackname      ${DEF}│ Creates the Docker Swarm, then deploys the '${cyn}stackname${DEF}' swarm stack if a config file exists."
    echo -e " -     ${cyn}-a | --all     ${DEF}│ Creates the Docker Swarm, then deploys all stacks with a corresponding folder inside the '${YLW}${docker_swarm}/${DEF}' path."
    echo -e " -     ${cyn}-d | --default ${DEF}│ Creates the Docker Swarm, then deploys the 'default' array of stacks defined in '${YLW}${docker_vars}/${cyn}swarm_stacks.conf${DEF}'"
    echo -e " -     ${cyn}-p | --preset  ${DEF}│ Creates the Docker Swarm, then deploys the 'preset' array of stacks defined in '${YLW}${docker_vars}/${cyn}swarm_stacks.conf${DEF}'"
    echo -e " -     ${cyn}-h │ --help    ${DEF}│ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu}[-> INITIALIZE DOCKER SWARM AND INSTALL INDICATED STACKS <-]${def}"; }
  fnc_script_outro(){ echo -e "${GRN}[-> DOCKER SWARM INITIALIZATION SCRIPT COMPLETE <-]${DEF}"; echo; }
  fnc_invalid_input(){ echo -e "${YLW}INVALID INPUT${DEF}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_nothing_to_do(){ echo -e " >> ${YLW}SWARM STACKS WILL NOT BE DEPLOYED${DEF} << "; echo; }
  fnc_deploy_query(){ printf "Do you want to deploy the '-${cyn}default${DEF}' list of Docker Swarm stacks?"; }
  fnc_deploy_stack(){ if [ ! "${deploy_list}" ] || [ "${deploy_list}" = "-n" ]; then fnc_nothing_to_do; else sh "${docker_scripts}"/docker_stack_start.sh "${deploy_list}"; fi; }
  fnc_traefik_query(){ printf " - Should ${cyn}traefik${DEF} still be installed (${YLW}recommended${DEF})?"; }
  fnc_folder_creation(){ if [[ ! -d "${docker_folder}/{scripts,secrets,swarm,compose}" ]]; then mkdir -pm 600 "${docker_folder}"/{scripts,secrets,swarm/{appdata,configs},compose/{appdata,configs}}; fi; }
  fnc_folder_owner(){ chown -R ${var_user}:${var_group} ${swarm_folder}; echo "FOLDER OWNERSHIP UPDATED"; echo; }
  fnc_folder_auth(){ chmod -R 600 ${swarm_folder}; echo "FOLDER PERMISSIONS UPDATED"; echo; }
  fnc_swarm_init(){ docker swarm init --advertise-addr "${var_nas_ip}"; }
  fnc_swarm_verify(){ while [[ "$(docker stack ls)" != "NAME                SERVICES   ORCHESTRATOR" ]]; do sleep 1; done; }
  # fnc_swarm_check(){ while [[ ! "$(docker stack ls --format "{{.Name}}")" ]]; do sleep 1; done; }
  fnc_swarm_success(){ echo; echo -e " >> ${grn}DOCKER SWARM INITIALIZED SUCCESSFULLY${DEF} << "; echo; }
  fnc_swarm_error(){
    docker network ls
    echo
    echo -e " >> THE ABOVE LIST MUST INCLUDE THE '${cyn}docker_gwbridge${DEF}' AND '${cyn}${var_net_rproxy}${DEF}' NETWORKS"
    echo -e " >> IF EITHER OF THOSE NETWORKS ARE NOT LISTED, YOU MUST LEAVE, THEN RE-INITIALIZE THE SWARM"
    echo -e " >> IF YOU HAVE ALREADY ATTEMPTED TO RE-INITIALIZE, ASK FOR HELP HERE: ${mgn} https://discord.gg/KekSYUE ${def}"
    echo
    echo -e " >> ${YLW}DOCKER SWARM STACKS WILL NOT BE DEPLOYED${DEF} << "
    echo
    echo -e " -- ${RED}ERROR${DEF}: DOCKER SWARM SETUP WAS ${YLW}NOT SUCCESSFUL${DEF} -- "
    exit 1 # Exit script here
    }
# docker network rm ingress
# docker network create --driver overlay --opt encrypted --ingress --subnet 10.10.0.0/16 ingress
# docker network create --driver overlay --opt encrypted --scope swarm --subnet=172.0.0.0/16 --attachable docker_socket
# docker network create --driver overlay --opt encrypted --scope swarm --subnet=172.1.0.0/16 --attachable reverse_proxy
# docker network create --driver overlay --opt encrypted --scope swarm --subnet=172.2.0.0/16 --attachable external_edge
  fnc_network_init(){
    docker network rm ingress && docker network create --driver overlay --opt encrypted --ingress --subnet "10.10.0.0/16" ingress;
    docker network create --driver overlay --opt encrypted --scope swarm --subnet "${var_subnet_socket}" --attachable "${var_net_socket}";
    docker network create --driver overlay --opt encrypted --scope swarm --subnet "${var_subnet_rproxy}" --attachable "${var_net_rproxy}";
    docker network create --driver overlay --opt encrypted --scope swarm --subnet "${var_subnet_exedge}" --attachable "${var_net_exedge}";
  }
  fnc_network_check_dockersocket(){ docker network ls --filter name="${var_net_socket}" -q; }
  fnc_network_check_proxynet(){ docker network ls --filter name="${var_net_rproxy}" -q; }
  fnc_network_check_gwbridge(){ docker network ls --filter name=docker_gwbridge -q; }
  fnc_network_verify(){
    unset increment IFS;
    while [[ ! "$(fnc_network_check_proxynet)" ]] || [[ ! "$(fnc_network_check_gwbridge)" ]];
      do sleep 1;
      increment=$(($increment+1));
      if [[ $increment -gt 10 ]];
        then fnc_swarm_error;
      fi;
    done;
    }
  fnc_network_success(){ echo; echo -e " ++ ${grn}CREATED '${cyn}docker_gwbridge${grn}' AND '${cyn}${var_net_rproxy}${grn}' NETWORKS${DEF} ++ "; }

# fnc_script_intro

# determine script output according to option entered
  case "${1}" in
    "") fnc_deploy_query
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
    -*) # confirm entered option switch is valid
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-a"|"--all") deploy_list="${1}" ;;
        ("-d"|"--default") deploy_list="${1}" ;;
        ("-p"|"--preset") deploy_list="${1}" ;;
        ("-n"|"--none") deploy_list="-n" ;;
        (*) fnc_invalid_syntax ;;
      esac
      ;;
    *) deploy_list=("$@") ;;
  esac

fnc_folder_creation
# fnc_folder_owner
# fnc_folder_auth

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
#   docker swarm init --advertise-addr "${var_nas_ip}"

# # Required networks creation verification
#   docker network create --driver=overlay --subnet=${var_subnet_rproxy} --attachable ${var_net_rproxy}
#   increment=0; # reset the increment variable
#   while [[ "$(docker network ls --filter name=traefik -q)" = "" ]] || [[ "$(docker network ls --filter name=gwbridge -q)" = "" ]]; do
#     sleep 1;
#     increment=$(($increment+1));
#     if [[ $increment -gt 10 ]]; then # max 10 seconds wait for network to be created
#       docker network ls
#       echo
#       echo -e " ->> THE ABOVE LIST MUST INCLUDE THE '${cyn}docker_gwbridge${DEF}' AND '${cyn}traefik_public${DEF}' NETWORKS"
#       echo -e " ->> IF EITHER OF THOSE NETWORKS ARE NOT LISTED, YOU MUST LEAVE, THEN RE-INITIALIZE THE SWARM"
#       echo -e " ->> IF YOU HAVE ALREADY ATTEMPTED TO RE-INITIALIZE, ASK FOR HELP HERE: ${mgn} https://discord.gg/KekSYUE ${def}"
#       echo
#       echo -e " ->> ${YLW}DOCKER SWARM STACKS WILL NOT BE DEPLOYED${DEF} << "
#       echo
#       echo -e " --- ${RED}ERROR${DEF}: DOCKER SWARM SETUP WAS ${YLW}NOT SUCCESSFUL${DEF} -- "
#       exit 1 # Exit script here
#     fi
#   done
#   # while [[ "$(docker network ls --filter name=traefik_public -q)" = "" ]]; do sleep 1; done
#   # while [[ "$(docker network ls --filter name=docker_gwbridge -q)" = "" ]]; do sleep 1; done
#   echo
#   echo -e " ++ '${cyn}docker_gwbridge${DEF}' AND '${cyn}traefik_public${DEF}' NETWORKS ${GRN}CREATED${DEF} ++ "

#   # Pause until swarm is initialized
#   while [[ "$(docker stack ls)" != "NAME                SERVICES" ]]; do sleep 1; done
#   echo
#   echo -e " >> ${grn}SWARM INITIALIZED${DEF} << "
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
#           (*) echo -e " >> ${YLW}DOCKER SWARM STACKS WILL NOT BE DEPLOYED${DEF} << " ;;
#         esac
#         ;;
#     esac
#   else
#     . "${docker_scripts}"/docker_stack_start.sh "$1"
#   fi


  # if [[ "$1" = "" ]] ; then
  #   printf "Do you want to deploy the '-${cyn}default${DEF}' list of Docker Swarm stacks?"; read -r -p " [(Y)es/(N)o] " input
  #   case $input in
  #     ([yY]|[yY][eE][sS]) ;;
  #     ([nN]|[nN][oO])
  #       # Query if Traefik should still be deployed
  #       printf " - Should ${cyn}traefik${DEF} still be installed (${YLW}recommended${DEF})?"; read -r -p " [(Y)es/(N)o] " confirm
  #       case $input in
  #         ([yY]|[yY][eE][sS]) ;;
  #         ([nN]|[nN][oO]) ;;
  #         (*) echo -e "${YLW}INVALID INPUT${DEF}: Must be any case-insensitive variation of 'yes' or 'no'." ;;
  #       esac
  #       ;;
  #     (*) echo -e "${YLW}INVALID INPUT${DEF}: Must be any case-insensitive variation of 'yes' or 'no'." ;;
  #   esac
  #   echo
  # fi

