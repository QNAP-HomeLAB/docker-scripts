#!/bin/bash
# external variable sources
  source /share/docker/scripts/.script_vars.conf
  source /share/docker/swarm/.swarm_stacks.conf

# script variable definitions
  unset config_list IFS
  unset deploy_list IFS

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script deploys a single stack or a pre-defined list of Docker Swarm stack <-]${DEF}"
    echo -e " -"
    echo -e " - SYNTAX: # dsd ${cyn}stack_name${DEF}"
    echo -e " - SYNTAX: # dsd ${cyn}-option${DEF}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn}-a │ --all     ${DEF}│ Deploys all stacks with a corresponding .yml config file inside the '${YLW}${swarm_configs}/${DEF}' path."
    echo -e " -     ${cyn}-d │ --default ${DEF}│ Deploys the '${cyn}default${DEF}' array of stacks defined in '${YLW}${docker_vars}/${cyn}swarm_stacks.conf${DEF}'"
    echo -e " -     ${cyn}-p │ --preset  ${DEF}│ Deploys the '${cyn}preset${DEF}' array of stacks defined in '${YLW}${docker_vars}/${cyn}swarm_stacks.conf${DEF}'"
    echo -e " -     ${cyn}-h │ --help    ${DEF}│ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }
  fnc_deploy_all(){ IFS=$'\n'; deploy_list=( $(cd "${swarm_configs}" && find -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g') ); }
  fnc_deploy_bounce(){ IFS=$'\n'; deploy_list=("${bounce_list[@]}"); }
  fnc_deploy_preset(){ IFS=$'\n'; deploy_list=("${stacks_preset[@]}"); }
  fnc_deploy_default(){ IFS=$'\n'; deploy_list=("${stacks_default[@]}"); }
  fnc_deploy_list_cleanup(){ 
    if [[ ! "${bounce_list[@]}" ]]; then fnc_deploy_all
      for stack in "${!deploy_list[@]}"; do
        if [[ "${deploy_list[stack]}" = "." ]]; then unset deploy_list[stack]; fi
        if [[ -f "${swarm_configs}"/"${deploy_list[stack]}"/"${deploy_list[stack]}${conftype}.yml" ]]; then config_list="${config_list} ${deploy_list[stack]}"; fi
      done
      unset deploy_list IFS; IFS=$'\n'; deploy_list=("${config_list[@]}"); unset config_list IFS
    else fnc_deploy_bounce
    fi;
    }

# determine script output according to option entered
  case "${1}" in 
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-a"|"--all")
          if [[ "${bounce_list[@]}" = "" ]]; then
            IFS=$'\n'; deploy_list=( $(cd "${swarm_configs}" && find -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g') );
            for stack in "${!deploy_list[@]}"; do
              if [[ "${deploy_list[stack]}" = "." ]]; then unset deploy_list[stack]; fi
              if [[ -f "${swarm_configs}"/"${deploy_list[stack]}"/"${deploy_list[stack]}${conftype}.yml" ]];
                then config_list="${config_list} ${deploy_list[stack]}"
              fi
            done
            unset deploy_list IFS
            IFS=$'\n'; deploy_list=("${config_list[@]}");
            unset config_list IFS
          else fnc_deploy_bounce
          fi
          ;;
        ("-p"|"--preset") fnc_deploy_preset ;;
        ("-d"|"--default") fnc_deploy_default ;;
        (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1 ;;
      esac
      ;;
    (*) deploy_list=("$@") ;;
  esac

# remove duplicate entries in deploy_list
  # echo -e "${blu}[-> DEPLOYING LISTED STACK(S) <-]${DEF}"
  deploy_list=(`for stack in "${deploy_list[@]}" ; do echo "${stack}" ; done | sort -u`)
  if [[ ! "$(docker network ls --filter name="${var_traefik_network}" -q)" ]]; then
    docker network create --driver=overlay --subnet=172.1.1.0/22 --attachable "${var_traefik_network}"
    # Pause until 'network create' operation is finished
    while [[ ! "$(docker network ls --filter name="${var_traefik_network}" -q)" ]]; do sleep 1; done
    echo -e " -> '${cyn}${var_traefik_network}${DEF}' OVERLAY NETWORK ${grn}CREATED${DEF}"
    echo
  fi

# perform stack setup and deployment tasks
  for stack in "${deploy_list[@]}"; do
    # check if indicated stack configuration file exists, otherwise exit
    if [[ -f "${swarm_configs}"/"${stack}"/"${stack}.yml" ]]; then
      # echo -e "${CYN} -> DEPLOY '${cyn}${stack}${CYN}' STACK <-${DEF}"
      # check if required folders exist, create if missing
      if [[ ! -d "${swarm_appdata}"/"${stack}" || ! -d "${swarm_configs}"/"${stack}" ]]; then
        echo -e "Creating ${YLW}Required folders${DEF}"
        . ${docker_scripts}/docker_stack_folders.sh "${stack}"
      fi
      # check for required traefik files, create if missing
      if [[ "${stack}" = [tT][rR][aA][eE][fF][iI][kK] ]]; then
        # create required letsencrypt certificate file if not already made
        if [[ ! -f ${swarm_appdata}/traefik/acme.json ]]; then
          echo -e "Creating ${YLW}Required cert file${DEF}"
          mkdir -p ${swarm_appdata}/traefik
          touch ${swarm_appdata}/traefik/acme.json
          chmod 600 ${swarm_appdata}/traefik/acme.json
        fi
        # check if required log files exist, create if missing
        if [[ ! -f "${swarm_appdata}"/"${stack}"/access.log || ! -f "${swarm_appdata}"/"${stack}"/"${stack}".log ]]; then
          echo -e "Creating ${YLW}Required log file(s)${DEF}"
          touch "${swarm_appdata}"/"${stack}"/{access.log,"${stack}".log}
          chmod 600 "${swarm_appdata}"/"${stack}"/{access.log,"${stack}".log}
        fi
      fi
      # deploy the requested stack
      docker stack deploy "${stack}" -c "${swarm_configs}"/"${stack}"/"${stack}".yml
      sleep 1
      if [[ ! "$(docker service ls --filter name="${stack}" -q)" ]]; then
        echo -e " ${red}ERROR${DEF}: '${cyn}${stack}${DEF}' ${YLW}*NOT* DEPLOYED${DEF}"; echo
      else
        # Pause until stack is deployed
        while [ ! "$(docker service ls --filter label=com.docker.stack.namespace=$stack -q)" ]; 
        do sleep 1; done
        echo -e "${GRN} ++ '${cyn}$stack${GRN}' STACK ${grn}DEPLOYED${GRN} ++ ${DEF}"; echo
      fi
    else echo -e " ${red}ERROR${DEF}: '${cyn}${stack}${DEF}' ${YLW}CONFIG FILE DOES NOT EXIST${DEF}"; echo
    fi
  done

# print script complete message
  # echo
  # echo -e "${GRN}[>> STACK DEPLOY SCRIPT COMPLETE <<]${DEF}"
  # echo