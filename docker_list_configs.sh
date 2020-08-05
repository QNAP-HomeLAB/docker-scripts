#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/scripts/.docker_vars.env
  source /share/docker/swarm/swarm_stacks.conf
  unset configs_folder_list IFS
  unset configs_list IFS
  unset configs_path IFS
  unset compose IFS

# Help message for script
  helpFunction(){
    echo -e "${blu}[-> This script lists the existing 'stackname.yml' files in the ${YLW}../swarm/${blu} or ${YLW}../compose/${blu} folder structure. <-]${DEF}"
    echo
    echo -e "  SYNTAX: # dlg -${cyn}option${DEF}"
    echo -e "  SYNTAX: # dccfg"
    echo -e "  SYNTAX: # dwcfg"
    echo -e "    VALID OPTIONS:"
    echo -e "      -${cyn}h${DEF} │ -${cyn}help${DEF}       │ Displays this help message."
    echo -e "      -${cyn}c${DEF} │ -${cyn}compose${DEF}    │ Displays stacks with config files in the ${YLW}..${compose_configs}/${def} filepath."
    echo -e "      -${cyn}s${DEF} │ -${cyn}w${DEF} │ -${cyn}swarm${DEF} │ Displays stacks with config files in the ${YLW}..${swarm_configs}/${def} filepath."
    echo -e "    NOTE: a valid option from above is required for this script to function"
    echo
    exit 1 # Exit script after printing help
    }

# determine configuration type to query
  case "$1" in
    (""|"-h"|"-help"|"--help") helpFunction ;;
    # ("-c"|"-compose") configs_path="/share/docker/compose/configs"; compose="-compose" ;;
    ("-c"|"-compose") configs_path=${compose_configs}; compose="-compose" ;;
    ("-s"|"-w"|"-swarm") configs_path=${swarm_configs} ;;
    (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX${DEF} <<"; exit 1 ;;
  esac

# descriptive script header
  echo -e "${blu}[-> EXISTING DOCKER CONFIG FILES IN ${YLW}${configs_path}/${blu} <-]${DEF}"
# populate list of configuration folders
  IFS=$'\n' configs_folder_list=( $(cd "${configs_path}" && find -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g') );
# remove '.' folder name from printed list
  for i in "${!configs_folder_list[@]}"; do
    if [[ "${configs_folder_list[i]}" = "." ]]; then unset configs_folder_list[i]; fi
    if [[ -f "${configs_path}"/"${configs_folder_list[i]}"/"${configs_folder_list[i]}${compose}.yml" ]];
    then configs_list="${configs_list} ${configs_folder_list[i]}"
    fi
  done

# display list of configuration folders
  if [[ ! ${configs_list} ]];
  then echo -e " -> ${YLW}no configuration files exist${DEF}"
  else echo -e " ->${cyn}${configs_list[@]}${DEF}"
  fi
  echo
