#!/bin/bash
# external variable sources
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/scripts/.docker_vars.env

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script creates ${CYN}Drauku's${blu} folder structure for the listed stack(s). <-]${DEF}"
    echo -e "      ${blu}(modified from ${CYN}gkoerk's${blu} famously awesome folder structure for stacks.)${DEF}"
    echo
    echo -e "  Enter up to nine(9) compose_files in a single command, separated by a 'space' character: "
    echo -e "    SYNTAX: dcf ${cyn}compose_file1${DEF} ${cyn}compose_file2${DEF} ... ${cyn}compose_file9${DEF}"
    echo -e "    SYNTAX: dcf -${cyn}option${DEF}"
    echo -e "      VALID OPTIONS:"
    echo -e "        -${cyn}h${DEF} │ --${cyn}help${DEF}   Displays this help message."
    echo
    echo -e "    The below folder structure is created for each 'compose_file' entered with this command:"
    echo -e "        ${YLW}${compose_appdata}/${cyn}compose_file${DEF}"
    echo -e "        ${YLW}${compose_configs}/${cyn}compose_file${DEF}"
    # echo -e "        ${YLW}${compose_runtime}/${cyn}compose_file${DEF}"
    # echo -e "        ${YLW}/share/compose/secrets/${cyn}compose_file${DEF}"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu}[-> CREATE DOCKER COMPOSE FOLDER STRUCTURE FOR LISTED STACKS <-]${def}"; }
  fnc_script_outro(){ echo -e "${GRN} -> COMPOSE FOLDER STRUCTURE CREATED${DEF}"; }
  fnc_nothing_to_do(){ echo -e "${YLW} -> between 1 and 9 names must be entered for this command to work${DEF}"; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_compose_appdata_folders(){ mkdir -p ${compose_appdata}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}; }
  fnc_compose_configs_folders(){ mkdir -p ${compose_configs}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}; }
  fnc_compose_runtime_folders(){ mkdir -p ${compose_runtime}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}; }
  fnc_compose_secrets_folders(){ mkdir -p ${compose_secrets}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}; }
  fnc_folder_ownership_update(){ chown -R ${var_user}:${var_group} ${compose_folder}; echo "FOLDER OWNERSHIP UPDATED"; echo; }

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
      fnc_compose_appdata_folders
      fnc_compose_configs_folders
      # fnc_compose_runtime_folders; # disabled due to not being used
      # fnc_compose_secrets_folders; # disabled due to not being used

      # Change all compose folders to the 'dockuser' 'user:group' values
      # fnc_folder_ownership_update;
      ;;
  esac

# Print script complete message
  # fnc_script_outro;
  # echo