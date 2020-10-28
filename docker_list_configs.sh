#!/bin/bash
# external variable sources
  source /share/docker/scripts/.script_vars.conf
  source /share/docker/secrets/.swarm_stacks.conf

# script variable definitions
  unset configs_folder_list IFS
  unset configs_list IFS
  unset configs_path IFS
  unset conftype IFS

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script lists the existing 'stackname.yml' files in the ${YLW}../swarm/${blu} or ${YLW}../compose/${blu} folder structure. <-]${DEF}"
    echo -e " -"
    echo -e " - SYNTAX: # dlg ${cyn}-option${DEF}"
    echo -e " - SYNTAX: # dccfg | dcg == 'dlg ${cyn}--compose${DEF}'"
    echo -e " - SYNTAX: # dwcfg | dwg == 'dlg ${cyn}--swarm${DEF}'"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn}-h │ --help    ${DEF}│ Displays this help message."
    echo -e " -     ${cyn}-c │ --compose ${DEF}│ Displays stacks with config files in the ${YLW}..${compose_configs}/${def} filepath."
    echo -e " -     ${cyn}-w │ --swarm   ${DEF}│ Displays stacks with config files in the ${YLW}..${swarm_configs}/${def} filepath."
    echo -e " -"
    echo -e " -   NOTE: a valid option from above is required for this script to function"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu}[-> EXISTING DOCKER CONFIG FILES IN ${YLW}${configs_path}/${blu} <-]${DEF}"; }
  fnc_nothing_to_do(){ echo -e "${YLW} -> no configuration files exist${DEF}"; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_list_config_folders(){ IFS=$'\n' configs_folder_list=( $(cd "${configs_path}" && find -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g') ); }
  fnc_folder_list_cleanup(){ if [[ "${configs_folder_list[i]}" = "." ]]; then unset configs_folder_list[i]; fi; }
  fnc_list_config_files(){ if [[ -f "${configs_path}"/"${configs_folder_list[i]}"/"${configs_folder_list[i]}${conftype}.yml" ]]; then configs_list="${configs_list} ${configs_folder_list[i]}"; fi; }
  fnc_script_outro(){ if [[ ! ${configs_list} ]]; then echo -e " -> ${YLW}no configuration files exist${DEF}"; else echo -e " ->${cyn}${configs_list[@]}${DEF}"; fi; echo; }
  
# determine configuration type to query
  case "$1" in
    ("-h"|"-help"|"--help") fnc_help ;;
    ("-c"|"--compose") configs_path=${compose_configs}; conftype="-compose" ;;
    ("-s"|"-w"|"--swarm") configs_path=${swarm_configs}; unset conftype IFS ;;
    (*) fnc_invalid_syntax ;;
  esac

# descriptive script header
  fnc_script_intro
# populate list of configuration folders
  fnc_list_config_folders
# populate list of configuration files
  for i in "${!configs_folder_list[@]}"; do
    fnc_folder_list_cleanup
    fnc_list_config_files
  done
# display list of configuration files
  fnc_script_outro