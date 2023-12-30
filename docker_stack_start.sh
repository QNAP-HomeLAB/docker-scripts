#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env
  # source /opt/docker/swarm/stackslist-swarm.conf

# script variable definitions
  unset config_list IFS
  unset deploy_list IFS

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-> This script deploys a single stack or a pre-defined list of Docker Swarm stack <-]${def:?}"
    echo -e " -"
    echo -e " - SYNTAX: # dsd ${cyn:?}stack_name${def:?}"
    echo -e " - SYNTAX: # dsd ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}-a │ --all     ${def:?}│ Deploys all stacks with a corresponding .yml config file inside the '${ylw:?}${docker_swarm}/${def:?}' path."
    echo -e " -     ${cyn:?}-d │ --default ${def:?}│ Deploys the '${cyn:?}default${def:?}' array of stacks defined in '${ylw:?}${docker_vars}/${cyn:?}swarm_stacks.conf${def:?}'"
    echo -e " -     ${cyn:?}-p │ --preset  ${def:?}│ Deploys the '${cyn:?}preset${def:?}' array of stacks defined in '${ylw:?}${docker_vars}/${cyn:?}swarm_stacks.conf${def:?}'"
    echo -e " -     ${cyn:?}-h │ --help    ${def:?}│ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }
  fnc_deploy_all(){ IFS=$'\n'; deploy_list=( $(cd "${docker_swarm}" && find -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g') ); }
  fnc_deploy_bounce(){ IFS=$'\n'; deploy_list=("${bounce_list[@]}"); }
  fnc_deploy_preset(){ IFS=$'\n'; deploy_list=("${stacks_preset[@]}"); }
  fnc_deploy_default(){ IFS=$'\n'; deploy_list=("${stacks_default[@]}"); }
  fnc_deploy_list_cleanup(){
    if [[ ! "${bounce_list[*]}" ]]; then fnc_deploy_all
      for stack in "${!deploy_list[@]}"; do
        if [[ "${deploy_list[stack]}" = "." ]]; then unset deploy_list[stack]; fi
        if [[ -f "${docker_swarm}/${deploy_list[stack]}/${deploy_list[stack]}${conftype}.yml" ]]; then config_list="${config_list} ${deploy_list[stack]}"; fi
      done
      unset deploy_list IFS; IFS=$'\n'; deploy_list=("${config_list[@]}"); unset config_list IFS
    else fnc_deploy_bounce
    fi;
    }

# determine script output according to option entered
  case "${1}" in
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help")
          fnc_help
          ;;
        ("-a"|"--all")
          if [[ "${bounce_list[*]}" = "" ]]; then
            IFS=$'\n'; deploy_list=( $(cd "${docker_swarm}" && find -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g') );
            for stack in "${!deploy_list[@]}"; do
              if [[ "${deploy_list[stack]}" = "." ]]; then unset deploy_list[stack]; fi
              if [[ -f "${docker_swarm}/${deploy_list[stack]}/${deploy_list[stack]}${conftype}.yml" ]];
                then config_list="${config_list} ${deploy_list[stack]}"
              fi
            done
            unset deploy_list IFS
            IFS=$'\n'; deploy_list=("${config_list[@]}");
            unset config_list IFS
          else fnc_deploy_bounce
          fi
          ;;
        ("-p"|"--preset")
          fnc_deploy_preset
          ;;
        ("-d"|"--default")
          fnc_deploy_default
          ;;
        (*)
          echo -e "${ylw:?} >> INVALID OPTION SYNTAX -- USE THE -${cyn:?}help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1 ;;
      esac
      ;;
    (*)
      deploy_list=("$@")
      ;;
  esac

# remove duplicate entries in deploy_list
  # echo -e "${blu:?}[-> DEPLOYING LISTED STACK(S) <-]${def:?}"
  deploy_list=(`for stack in "${deploy_list[@]}" ; do echo "${stack}" ; done | sort -u`)
  if [[ ! "$(docker network ls --filter name="${var_net_rproxy}" -q)" ]]; then
    docker network create --driver=overlay --subnet=${var_subnet_rproxy} --attachable ${var_net_rproxy}
    # Pause until 'network create' operation is finished
    while [[ ! "$(docker network ls --filter name=${var_net_rproxy} -q)" ]]; do sleep 1; done
    echo -e " -> '${cyn:?}${var_net_rproxy}${def:?}' OVERLAY NETWORK ${grn:?}CREATED${def:?}"
    echo
  fi

# perform stack setup and deployment tasks
  for stack in "${deploy_list[@]}"; do
    # check if indicated stack configuration file exists, otherwise exit
    if [[ -f "${docker_swarm}/${stack}/${conftype}.yml" ]]; then
      # echo -e "${cyn:?} -> DEPLOY '${cyn:?}${stack}${cyn:?}' STACK <-${def:?}"
      # check if required folders exist, create if missing
      if [[ ! -d "${docker_appdata}/${stack}" || ! -d "${docker_swarm}/${stack}" ]]; then
        echo -e "Creating ${ylw:?}Required folders${def:?}"
        . "${docker_scripts}/docker_stack_folders.sh" "${stack}"
      fi
      # check for required traefik files, create if missing
      if [[ "${stack}" = [tT][rR][aA][eE][fF][iI][kK] ]]; then
        # create required letsencrypt certificate file if not already made
        if [[ ! -f "${docker_appdata}/traefik/acme.json" ]]; then
          echo -e "Creating ${ylw:?}Required cert file${def:?}"
          mkdir -p "${docker_appdata}/traefik"
          touch "${docker_appdata}/traefik/acme.json"
          chmod 600 "${docker_appdata}/traefik/acme.json"
        fi
        # check if required log files exist, create if missing
        if [[ ! -f "${docker_appdata}/${stack}/access.log" || ! -f "${docker_appdata}/${stack}/${stack}.log" ]]; then
          echo -e "Creating ${ylw:?}Required log file(s)${def:?}"
          touch "${docker_appdata}/${stack}/{access.log,${stack}.log"}
          chmod 600 "${docker_appdata}/${stack}/{access.log,${stack}.log"}
        fi
      fi
      # deploy the requested stack
      # docker stack deploy "${stack}" -c "${docker_swarm}/${stack}/${conftype}.yml" --prune
      docker stack deploy "${stack}" -c "${docker_swarm}/${stack}/${conftype}.yml" --prune
      sleep 1
      if [[ ! "$(docker service ls --filter name="${stack}" -q)" ]]; then
        echo -e " ${red:?}ERROR${def:?}: '${cyn:?}${stack}${def:?}' ${ylw:?}*NOT* DEPLOYED${def:?}"; echo
      else
        # Pause until stack is deployed
        while [ ! "$(docker service ls --filter label=com.docker.stack.namespace=$stack -q)" ];
        do sleep 1; done
        echo -e "${grn:?} ++ '${cyn:?}$stack${grn:?}' STACK ${grn:?}DEPLOYED${grn:?} ++ ${def:?}"; echo
      fi
    else echo -e " ${red:?}ERROR${def:?}: '${cyn:?}${stack}${def:?}' ${ylw:?}CONFIG FILE DOES NOT EXIST${def:?}"; echo
    fi
  done

# print script complete message
  # echo
  # echo -e "${grn:?}[>> STACK DEPLOY SCRIPT COMPLETE <<]${def:?}"
  # echo