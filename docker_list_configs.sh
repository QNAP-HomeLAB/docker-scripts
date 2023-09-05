#!/bin/bash

# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# script variable definitions
  unset configs_folder_list IFS
  unset configs_list IFS
  unset configs_path IFS

# script help text
  fnc_help_list_configs(){
    echo -e "${blu:?}[-> This script lists the existing 'stackname.yml' files in the ${YLW:?}../swarm/${blu:?} or ${YLW:?}../compose/${blu:?} folder structure. <-]${DEF:?}"
    echo -e " -"
    echo -e " - SYNTAX: # dlg ${cyn:?}-option${DEF:?}"
    echo -e " - SYNTAX: # dccfg | dcg == 'dlg ${cyn:?}--compose${DEF:?}'"
    echo -e " - SYNTAX: # dwcfg | dwg == 'dlg ${cyn:?}--swarm${DEF:?}'"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}-h │ --help    ${DEF:?}│ Displays this help message."
    echo -e " -     ${cyn:?}-c │ --compose ${DEF:?}│ Displays stacks with config files in the ${YLW:?}..${docker_compose:-/opt/docker/compose}/${def:?} filepath."
    echo -e " -     ${cyn:?}-w │ --swarm   ${DEF:?}│ Displays stacks with config files in the ${YLW:?}..${docker_swarm:-/opt/docker/swarm}/${def:?} filepath."
    echo -e " -"
    echo -e " -   NOTE: a valid option from above is required for this script to function"
    echo
    exit 1 # Exit script after printing help
    }
  case "$1" in ("-h"|*"help"*) fnc_help_list_configs ;; esac

## function definitions
  # intro message for script
  fnc_intro_list_configs(){ echo -e "${blu:?}[-> EXISTING DOCKER ${cyn:?}${conftype:?}${blu:?} CONFIG FILES IN ${YLW:?}${configs_path}/${blu:?} <-]${DEF:?}"; }
  # outro message for script
  fnc_outro_list_configs(){
    # echo -e "[-- ${GRN:?} DISPLAYED LIST OF CONFIG FILES IN ${YLW:?}${configs_path}/ ${def:?} --]";
    echo;
    }
  # invalid syntax message
  fnc_invalid_syntax(){ echo -e "${YLW:?} >> INVALID OPTION SYNTAX, USE THE -${cyn:?}help${YLW:?} OPTION TO DISPLAY PROPER SYNTAX <<${DEF:?}"; exit 1; }
  # nothing to do message
  fnc_nothing_to_do(){ echo -e "${YLW:?} -> no configuration files exist${DEF:?}"; }
  # populate configs list array with docker config files in the '/opt/docker/${conftype}' folder
  fnc_list_config_folders(){
    IFS=$'\n' configs_folder_list=( $(cd "${configs_path}" && find . -maxdepth 1 -type d -not -path '*/\.*' | sort | sed 's/^\.\///g') );
    }
  # set script variables for Docker Compose configs
  fnc_type_compose(){
    conftype="compose";
    configs_path="${docker_compose:-/opt/docker/compose}";
    source "${docker_compose}"/.stackslist-compose.conf;
    }
  # set script variables for Docker Swarm configs
  fnc_type_swarm(){
    conftype="swarm";
    configs_path="${docker_swarm:-/opt/docker/swarm}";
    source "${docker_swarm}"/.stackslist-swarm.conf;
    }
  # clean up configs list array
  fnc_folder_list_cleanup(){
    if [[ "${configs_folder_list[i]}" = "." ]]; then
    unset "configs_folder_list[i]";
    fi;
    for i in "${!configs_folder_list[@]}"; do
      if [ i == "." ]; then unset "configs_folder_list[i]"; fi;
    done;
    }
  # populate the configs_list array
  fnc_list_config_files(){
    if [[ -f "${configs_path}/${configs_folder_list[i]}/${var_configs_file:-compose.yml}" ]];
    then configs_list="${configs_list} ${configs_folder_list[i]}";
    fi;
    }
  fnc_display_config_files(){
    # display config files list if any
    if [[ ! ${configs_list} ]]; then
      echo -e " -> ${YLW:?}no configuration files exist${DEF:?}";
    else
      echo -e " ->${cyn:?}${configs_list[*]}${DEF:?}";
    fi;
    echo;
    }

# determine configuration type to query
  case "$1" in
    ("-h"|"-help"|"--help")
      fnc_help_list_configs
      ;;
    ("-c"|"--compose")
      fnc_type_compose
      fnc_intro_list_configs
      ;;
    ("-s"|"-w"|"--swarm")
      fnc_type_swarm
      fnc_intro_list_configs
      ;;
    (*)
      fnc_invalid_syntax
      ;;
  esac

# common tasks for all config types
  fnc_list_config_folders
  # fnd_list_config_files
  fnc_display_config_files
  # fnc_outro_list_configs