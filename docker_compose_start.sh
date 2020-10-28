#!/bin/bash
# external variable sources
  source /share/docker/scripts/.script_vars.conf

# script variable definitions
  conftype="-compose"

# function definitions
  fnc_help(){
    echo -e " - ${blu}[-> This script STARTS 'up' a single Docker container using a pre-written compose file <-]${DEF}"
    echo -e " -"
    echo -e " - SYNTAX: # dcu | dcs | dct"
    echo -e " - SYNTAX: # dcu ${cyn}stack_name${DEF}"
    echo -e " - SYNTAX: # dcu ${cyn}-option${DEF}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn}-h │ --help ${DEF}| Displays this help message."
    echo -e " -     ${cyn}-a | --all  ${DEF}| Deploys all stacks with a config file inside the '${YLW}${compose_configs}/${DEF}' path."
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
          if [[ "${bounce_list[@]}" = "" ]]; then
            # populate list of configuration folders
            IFS=$'\n'; configs_folder_list=( $(cd "${compose_configs}" && find -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g') )
            # check that each existing folder has a .yml config file inside
            for i in "${!configs_folder_list[@]}"; do
              # remove '.' folder name from printed list
              if [[ "${configs_folder_list[i]}" = "." ]]
              then unset configs_folder_list[i]
              fi
              if [[ -f "${compose_configs}"/"${configs_folder_list[i]}"/"${configs_folder_list[i]}${conftype}.yml" ]]
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
  deploy_list=(`for stack in "${deploy_list[@]}" ; do echo "${stack}" ; done | sort -u`)
  for stack in "${!deploy_list[@]}"; do
    docker-compose -f ${compose_configs}/${deploy_list[stack]}/${deploy_list[stack]}${conftype}.yml up -d --remove-orphans
    # create '.env' file redirect if used
    # [ ! -e ${compose_configs}/${stack}/.env ] && ln -s ${variables_file} ${compose_configs}/${stack}/.env
    ln -sf ${variables_file} ${compose_configs}/${deploy_list[stack]}/.env
    sleep 1
  done