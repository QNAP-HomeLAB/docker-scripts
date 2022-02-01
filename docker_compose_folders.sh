#!/bin/bash
# external variable sources
  source /share/docker/scripts/.script_vars.conf

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script creates Docker configuration folders using the schema created by ${CYN}Drauku${blu} <-]${DEF}"
    echo -e " -     ${blu}(modified from ${CYN}gkoerk's (RIP)${blu} famously awesome folder structure for stacks)${DEF}"
    echo -e " -"
    echo -e " - Enter up to nine(9) container_names in a single command, separated by a 'space' character: "
    echo -e " -   SYNTAX: dcf ${cyn}compose_file1${DEF} ${cyn}compose_file2${DEF} ... ${cyn}compose_file9${DEF}"
    echo -e " -   SYNTAX: dcf ${cyn}-option${DEF}"
    echo -e " -     VALID OPTIONS:"
    # echo -e " -       ${cyn}-d │ --delete ${DEF}│ ${red}Deletes${def} all sub-folders and files in ${YLW}${compose_appdata}/${cyn}compose_stack${DEF} & ${YLW}${compose_configs}/${cyn}compose_stack${DEF}"
    # echo -e " -       ${cyn}-r │ --reset  ${DEF}│ ${red}Deletes${def} all files contained in ${YLW}${compose_appdata}/${cyn}compose_stack${DEF}"
    echo -e " -       ${cyn}-h │ --help   ${DEF}| Displays this help message."
    echo -e " -"
    echo -e " -   NOTE: The below folder structure is created for each 'compose_file' entered with this command:"
    echo -e " -       ${YLW}${compose_appdata}/${cyn}compose_file${DEF}"
    echo -e " -       ${YLW}${compose_configs}/${cyn}compose_file${DEF}"
    # echo -e " -       ${YLW}${compose_runtime}/${cyn}compose_stack${DEF}"
    # echo -e " -       ${YLW}/share/compose/secrets/${cyn}compose_stack${DEF}"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu}[-> CREATE DOCKER-COMPOSE FOLDER STRUCTURE FOR LISTED STACKS <-]${def}"; }
  fnc_script_outro(){ echo -e "${GRN} -> COMPOSE FOLDER STRUCTURE CREATED${DEF}"; echo; }
  fnc_nothing_to_do(){ echo -e "${YLW} -> a valid option followed by container names must be entered for this command to work${DEF}"; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_create_folders(){ 
    folder_list=("$@")
    echo -e "${folder_list[@]}"
    echo -e "${appdata_folder}"
    echo -e "${configs_folder}"
    for stack in "${folder_list[@]}"; do
      if [ ! -d ${appdata_folder}/${folder_list[stack]} ]; then mkdir -p ${appdata_folder}/${folder_list[stack]}; fi
      if [ ! -d ${configs_folder}/${folder_list[stack]} ]; then mkdir -p ${configs_folder}/${folder_list[stack]}; fi
      echo -e " -> ${GRN}${folder_list[stack]} FOLDER CREATED ${DEF}"
    done
  }
  fnc_folder_ownership_update(){ chown -R ${var_usr}:${var_grp} ${compose_folder}; echo -e " -> ${GRN}FOLDER OWNERSHIP UPDATED ${DEF}"; echo; }

# output determination logic
  case "${1}" in 
    ("") fnc_nothing_to_do ;;
    (-*) # validate and perform option
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        (*) fnc_invalid_syntax ;;
      esac
    ;;
    (*) # Create folder structure
      appdata_folder=${compose_appdata}
      configs_folder=${compose_configs}
      fnc_create_folders
      # fnc_compose_appdata_folders
      # fnc_compose_configs_folders
      fnc_folder_ownership_update
      # fnc_script_outro
      ;;
  esac