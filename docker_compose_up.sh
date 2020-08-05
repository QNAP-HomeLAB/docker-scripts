#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/scripts/.docker_vars.env

# Help message for script
helpFunction(){
  echo -e "${blu}[-> This script STARTS 'up' a single Docker container using a pre-written compose file <-]${DEF}"
  echo
  echo -e "SYNTAX: # dcu ${cyn}stack_name${DEF}"
  echo -e "SYNTAX: # dcu -${cyn}option${DEF}"
  echo -e "  VALID OPTIONS:"
  echo -e "        -${cyn}h${DEF} │ -${cyn}help${DEF}   Displays this help message."
  echo -e "        -${cyn}all${DEF}          Deploys all stacks with a config file inside the '${YLW}${compose_configs}/${DEF}' path."
  echo -e "                        NOTE: config files must follow this naming format: '${cyn}stackname${CYN}-compose.yml${def}'"
  echo
  exit 1 # Exit script after printing help
  }

# option logic action determination
  case "${1}" in 
    (-*) # validate entered option exists
      case "${1}" in
        ("-h"|"-help"|"--help") helpFunction ;;
        ("-all")
          if [[ "${bounce_list[@]}" = "" ]]; then
            configs_path=${compose_configs}; compose="-compose"
            # populate list of configuration folders
            IFS=$'\n' configs_folder_list=( $(cd "${configs_path}" && find -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g') );
            # check that each existing folder has a .yml config file inside
            for i in "${!configs_folder_list[@]}"; do
              # remove '.' folder name from printed list
              if [[ "${configs_folder_list[i]}" = "." ]]; then unset configs_folder_list[i]; fi
              if [[ -f "${configs_path}"/"${configs_folder_list[i]}"/"${configs_folder_list[i]}${compose}.yml" ]];
              then configs_list="${configs_list} ${configs_folder_list[i]}"
              fi
            done
            unset deploy_list IFS
            IFS=$'\n' deploy_list=( "${configs_list[@]}" );
            unset configs_list IFS
          else IFS=$'\n' deploy_list=( "${bounce_list[@]}" );
          fi
          ;;
        (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1 ;;
      esac
      ;;
    (*) deploy_list=("$@") ;;
  esac

# perform script main function
  # create '.env' file redirect if used
  # ln -sf "${docker_vars}"/"${variables_file}" "${compose_configs}"/"${stack}"/.env
  # sleep 1
  deploy_list=(`for stack in "${deploy_list[@]}" ; do echo "${stack}" ; done | sort -u`)
  for stack in "${!deploy_list[@]}"; do
    # docker-compose -f /share/docker/compose/configs/"${deploy_list[stack]}"/"${deploy_list[stack]}"-compose.yml up -d
    docker-compose -f "${compose_configs}"/"${deploy_list[stack]}"/"${deploy_list[stack]}"-compose.yml up -d
  done
