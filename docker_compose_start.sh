#!/bin/bash

# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.conf

# script variable definitions
  conftype="-compose"
  unset bounce_list

# function definitions
  fnc_help(){
    echo -e " - ${blu}[-> This script STARTS 'up' a single Docker container using a pre-written compose file <-]${DEF}"
    echo -e " -"
    echo -e " - SYNTAX: # dcu | dcs | dct"
    echo -e " - SYNTAX: # dcu ${cyn}stack_name${DEF}"
    echo -e " - SYNTAX: # dcu ${cyn}-option${DEF}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn}-h │ --help ${DEF}| Displays this help message."
    echo -e " -     ${cyn}-a | --all  ${DEF}| Deploys all stacks with a config file inside the '${YLW}${docker_compose}/${DEF}' path."
    echo -e " -                         NOTE: config files must follow this naming format: '${cyn}stackname${CYN}-compose.yml${def}'"
    echo
    exit 1 # Exit script after printing help
    }

# option logic action determination
  case "${1}" in
    (-*) # validate entered option exists
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-a"|"--all")
          if [[ "${bounce_list[*]}" = "" ]]; then
            # populate list of configuration folders
            IFS=$'\n'; configs_folder_list=( "$(cd "${docker_compose}" && find . -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g')" )
            # check that each existing folder has a .yml config file inside
            for i in "${!configs_folder_list[@]}"; do
              # remove '.' folder name from printed list
              if [[ "${configs_folder_list[i]}" = "." ]]
              then unset "configs_folder_list[i]"
              fi
              if [[ -f "${docker_compose}"/"${configs_folder_list[i]}"/"${configs_folder_list[i]}${conftype}.yml" ]]
              then configs_list="${configs_list} ${configs_folder_list[i]}"
              fi
            done
            unset deploy_list IFS;
            IFS=$'\n'; deploy_list=( "${configs_list[@]}" )
            unset configs_list IFS;
          else IFS=$'\n'; deploy_list=( "${bounce_list[@]}" )
          fi
          ;;
        (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1 ;;
      esac
      ;;
    (*) deploy_list=("$@") ;;
  esac

# perform script main function
  deploy_list=( "$(for stack in "${deploy_list[@]}" ; do echo "${stack}" ; done | sort -u)" )
  for stack in "${!deploy_list[@]}"; do
    # create '.env' file redirect if used
    ln -sf "${var_script_vars}" "${docker_compose}/${deploy_list[stack]}/.env"
    docker compose -f "${docker_compose}/${deploy_list[stack]}/${deploy_list[stack]}${conftype}.yml" up -d --remove-orphans
    sleep 1
  done