#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/scripts/.docker_vars.env
  source /share/docker/swarm/swarm_vars.env
  unset deploy_list IFS

# Help message for script
helpFunction(){
  echo -e "${blu}[-> This script performs Docker Swarm initialization tasks on QNAP Container Station architecture. <-]${DEF}"
  echo
  echo -e "  SYNTAX: # dwinit"
  echo -e "  SYNTAX: # dwinit -${cyn}option${DEF}"
  echo -e "    VALID OPTIONS:"
  echo -e "      ${cyn}stackname${DEF}  │ Creates the Docker Swarm, then deploys the '${cyn}stackname${DEF}' swarm stack if a config file exists."
  echo -e "      -${cyn}all${DEF}       │ Creates the Docker Swarm, then deploys all stacks with a corresponding folder inside the '${YLW}${swarm_configs}/${DEF}' path."
  echo -e "      -${cyn}listed${DEF}    │ Creates the Docker Swarm, then deploys the 'listed' array of stacks defined in '${YLW}${docker_vars}/${cyn}swarm_stacks.conf${DEF}'"
  echo -e "      -${cyn}default${DEF}   │ Creates the Docker Swarm, then deploys the 'default' array of stacks defined in '${YLW}${docker_vars}/${cyn}swarm_stacks.conf${DEF}'"
  echo -e "      -${cyn}h${DEF} │ -${cyn}help${DEF} │ Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# determine script output according to option entered
  if [ "${1}" == "" ]; then # confirm possible stacks to be deployed with swarm initialization
      printf "Do you want to deploy the '-${cyn}default${DEF}' list of Docker Swarm stacks?";
      while read -r -p " [(Y)es/(N)o] " input; do
        case "${input}" in 
          ([yY]|[yY][eE][sS]) deploy_list="-default"; break ;;
          ([nN]|[nN][oO]) printf " - Should ${cyn}traefik${DEF} still be installed (${YLW}recommended${DEF})?"; 
              while read -r -p " [(Y)es/(N)o] " confirm; do
                case "${confirm}" in 
                  ([yY]|[yY][eE][sS]) deploy_list="traefik"; break ;;
                  ([nN]|[nN][oO]) break ;;
                  *) echo -e "${YLW}INVALID INPUT${DEF}: Must be any case-insensitive variation of '(Y)es' or '(N)o'." ;;
                esac
              done
            break ;;
          *) echo -e "${YLW}INVALID INPUT${DEF}: Must be any case-insensitive variation of '(Y)es' or '(N)o'." ;;
        esac
      done
      echo
  else
    case "${1}" in 
      (-*) # confirm entered option switch is valid
        case "${1}" in
          (""|"-h"|"-help"|"--help") helpFunction ;;
          ("-all") deploy_list="${1}" ;;
          ("-listed") deploy_list="${1}" ;;
          ("-default") deploy_list="${1}" ;;
          *) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX${DEF} <<"; exit 1 ;;
        esac
        ;;
      *) deploy_list=("$@") ;;
    esac
  fi

# Swarm folder creation
  if [[ ! -f "${docker_folder}/{scripts,secrets,swarm,compose}" ]];
  then mkdir -pm 600 "${docker_folder}"/{scripts,secrets,swarm/{appdata,configs},compose/{appdata,configs}};
  fi

# Swarm initialization
  docker swarm init --advertise-addr "${var_nas_ip}"

# Required networks creation verification
  docker network create --driver=overlay --subnet=172.1.1.0/22 --attachable ${var_traefik_network}
  # while [[ "$(docker network ls --filter name=${var_traefik_network} -q)" = "" ]]; do sleep 1; done
  # while [[ "$(docker network ls --filter name=docker_gwbridge -q)" = "" ]]; do sleep 1; done
  increment=0; # reset the increment variable
  while [[ "$(docker network ls --filter name=traefik -q)" = "" ]] || [[ "$(docker network ls --filter name=gwbridge -q)" = "" ]]; do 
    sleep 1;
    increment=$(($increment+1));
    if [[ $increment -gt 10 ]]; # max 10 seconds wait for network to be created
    then docker network ls
      echo
      echo -e " >> THE ABOVE LIST MUST INCLUDE THE '${cyn}docker_gwbridge${DEF}' AND '${cyn}${var_traefik_network}${DEF}' NETWORKS"
      echo -e " >> IF EITHER OF THOSE NETWORKS ARE NOT LISTED, YOU MUST LEAVE, THEN RE-INITIALIZE THE SWARM"
      echo -e " >> IF YOU HAVE ALREADY ATTEMPTED TO RE-INITIALIZE, ASK FOR HELP HERE: ${mgn} https://discord.gg/KekSYUE ${def}"
      echo
      echo -e " >> ${YLW}DOCKER SWARM STACKS WILL NOT BE DEPLOYED${DEF} << "
      echo
      echo -e " -- ${RED}ERROR${DEF}: DOCKER SWARM SETUP WAS ${YLW}NOT SUCCESSFUL${DEF} -- "
      exit 1 # Exit script here
    fi
  done
  echo
  echo -e " ++ '${cyn}docker_gwbridge${DEF}' AND '${cyn}${var_traefik_network}${DEF}' NETWORKS ${GRN}CREATED${DEF} ++ "

  # Pause until swarm is initialized
  while [[ "$(docker stack ls)" != "NAME                SERVICES" ]]; do sleep 1; done
  echo
  echo -e " >> ${grn}SWARM INITIALIZED${DEF} << "
  echo

# stack deployment
  if [ ! "${deploy_list}" ];
  then echo -e " >> ${YLW}SWARM STACKS WILL NOT BE DEPLOYED${DEF} << "; echo;
  else sh "${docker_scripts}"/docker_stack_deploy.sh "${deploy_list}";
  fi

# Script completion message
  echo -e "${GRN}[>> DOCKER SWARM SETUP SCRIPT COMPLETE <<]${DEF}"
  echo