#!/bin/bash
# external variable sources
  source /share/docker/scripts/.script_vars.conf

# script variable definitions
  unset folder_list args_list IFS; 
  args_list=("${@}");

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script creates Docker configuration folders using the schema created by ${CYN}Drauku${blu} <-]${DEF}"
    echo -e " -     ${blu}(modified from ${CYN}gkoerk's (RIP)${blu} famously awesome folder structure for stacks)${DEF}"
    echo -e " -"
    echo -e " - Enter up to nine(9) container_names in a single command, separated by a 'space' character: "
    echo -e " -   SYNTAX: dcf ${cyn}compose_file1${DEF} ${cyn}compose_file2${DEF} ... ${cyn}compose_file9${DEF}"
    echo -e " -   SYNTAX: dcf ${cyn}-option${DEF}"
    echo -e " -     VALID OPTIONS:"
    echo -e " -       ${cyn}-c │ --create ${DEF}│ ${grn}Creates${def} ${YLW}{compose_appdata,compose_configs}/${cyn}compose_stack${DEF}"
    echo -e " -       ${cyn}-d │ --delete ${DEF}│ ${ylw}Deletes${def} ${YLW}{compose_appdata,compose_configs}/${cyn}compose_stack${DEF} & ${ylw}contents${DEF}"
    echo -e " -       ${cyn}-r │ --remove ${DEF}│ ${red}Removes${def} all sub-folders and files in ${YLW}{compose_appdata,compose_configs}/${cyn}compose_stack${DEF}"
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
  fnc_script_intro(){ echo -e "${blu}[-  CREATE DOCKER-COMPOSE FOLDER STRUCTURE FOR LISTED STACKS  -]${def}"; }
  fnc_script_outro(){ echo -e "${GRN} -  COMPOSE FOLDER STRUCTURE CREATED${DEF}"; echo; exit 1; }
  fnc_nothing_to_do(){ echo -e "${YLW} >> A valid option and container name(s) must be entered for this command to work (use ${cyn}--help ${YLW}for info)${DEF}"; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE ${cyn}-help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; echo; exit 1; }
  fnc_invalid_input(){ echo -e "${YLW}INVALID INPUT${DEF}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
  fnc_query_remove_all(){ printf "Are you sure you want to ${red}REMOVE${def} listed containers folders and/or files?"; }
  fnc_array_cleanup(){ folder_list=(`for index in "${!args_list[@]}"; do echo -e "${args_list[$index + 1]}"; done` ); }
  fnc_file_search() { [[ $(find ./"${@}" -type f) ]]; }

  fnc_folder_create(){ 
    echo; exist=0;
    for stack in "${folder_list[@]}"; do 
      if [ ! -d "${compose_appdata}/${stack}" ]; 
      then install -o ${var_usr} -g ${var_grp} -m 664 -d "${compose_appdata}/${stack}"; 
        # echo -e "  > ${cyn}"${stack}" ${YLW}COMPOSE APPDATA FOLDER ${ylw}CREATED ${DEF}";
      else echo -e "  > ${CYN}"${compose_appdata}${cyn}/${stack}"   ${ylw}ALREADY EXISTS ${DEF}"; exist=1;
      fi;
      if [ ! -d "${compose_configs}/${stack}" ]; 
      then install -o ${var_usr} -g ${var_grp} -m 664 -d "${compose_configs}/${stack}"; 
        # echo -e "  > ${cyn}"${stack}" ${YLW}COMPOSE CONFIGS FOLDER ${ylw}CREATED ${DEF}";
      else echo -e "  > ${CYN}"${compose_configs}${cyn}/${stack}"   ${ylw}ALREADY EXISTS ${DEF}"; exist=1;
      fi;
      if [ ! -f "${compose_configs}/${stack}/${stack}-compose.yml" ]; 
      then install -o ${var_usr} -g ${var_grp} -m 664 "${compose_folder}/compose-template.yml" "${compose_configs}/${stack}/${stack}-compose.yml"; 
        # echo -e "${ylw}  > ${CYN}${compose_appdata}/${cyn}"${stack}"/"${stack}"-compose.yml ${ylw}created${DEF}"; 
      else echo -e "${ylw}  > ${CYN}${compose_appdata}/${cyn}"${stack}"/"${stack}"-compose.yml ${ylw}already exists${DEF}"; 
      fi;
      [ $exist == "0" ] && echo -e "  > ${cyn}"${stack}" ${YLW}COMPOSE FOLDER SET ${ylw}CREATED ${DEF}";
    done
  }

  fnc_folder_clean(){
    echo; exist=0;
    while read -r -p " [(Y)es/(N)o] " input; do
      case "${input}" in 
        ([yY]|[yY][eE][sS]) 
          echo;
          for stack in "${folder_list[@]}"; do 
            if [ -f "${compose_appdata}/${stack}/*" ]; 
            then rm -rf "${compose_appdata}/${stack}/*";
            else echo -e "  > ${CYN}"${compose_appdata}${cyn}/${stack}"   ${ylw}NO FILES FOUND ${DEF}"; exist=0;
            fi 
            if [ -f "${compose_configs}/${stack}/*" ]; 
            then rm -rf "${compose_configs}/${stack}/*";
            else echo -e "  > ${CYN}"${compose_configs}${cyn}/${stack}/*"   ${ylw}NO FILES FOUND ${DEF}"; exist=0;
            fi
            [ $exist == "1" ] && echo -e "  > ${cyn}"${stack}" ${YLW}CONTAINER FILES ${ylw}CLEANED ${DEF}";
          done
          break
        ;;
        ([nN]|[nN][oO]) break ;;
        (*) fnc_invalid_input ;;
      esac
    done
  }

  fnc_folder_delete(){ 
    echo; exist=1;
    for stack in "${folder_list[@]}"; do 
      if [ -d "${compose_appdata}/${stack}" ]; 
      then rmdir "${compose_appdata}/${stack}"; # echo -e "  > ${cyn}"${stack}" ${YLW}COMPOSE APPDATA FOLDER ${ylw}DELETED ${DEF}";
      else echo -e "  > ${CYN}"${compose_appdata}${cyn}/${stack}"   ${ylw}NOT FOUND ${DEF}"; exist=0;
      fi; 
      if [ -d "${compose_configs}/${stack}" ]; 
      then rmdir "${compose_configs}/${stack}"; # echo -e "  > ${cyn}"${stack}" ${YLW}COMPOSE CONFIGS FOLDER ${ylw}DELETED ${DEF}";
      else echo -e "  > ${CYN}"${compose_configs}${cyn}/${stack}"   ${ylw}NOT FOUND ${DEF}"; exist=0;
      fi; 
      [ $exist == "1" ] && echo -e "  > ${cyn}"${stack}" ${YLW}COMPOSE FOLDER SET ${ylw}REMOVED ${DEF}";
    done
  }

  fnc_folder_remove(){ 
    exist=1; fnc_query_remove_all; 
    while read -r -p " [(Y)es/(N)o] " input; do
      case "${input}" in 
        ([yY]|[yY][eE][sS]) 
          echo;
          for stack in "${folder_list[@]}"; do 
            if [ -d "${compose_appdata}/${stack}" ]; 
            then rm -rf "${compose_appdata}/${stack}"; # echo -e "  > ${cyn}"${stack}" ${YLW}COMPOSE APPDATA FOLDER AND FILES ${ylw}REMOVED ${DEF}";
            else echo -e "  > ${CYN}"${compose_appdata}${cyn}/${stack}"   ${ylw}NOT FOUND ${DEF}"; exist=0;
            fi 
            if [ -d "${compose_configs}/${stack}" ]; 
            then rm -rf "${compose_configs}/${stack}"; # echo -e "  > ${cyn}"${stack}" ${YLW}COMPOSE CONFIGS FOLDER AND FILES ${ylw}REMOVED ${DEF}";
            else echo -e "  > ${CYN}"${compose_configs}${cyn}/${stack}"   ${ylw}NOT FOUND ${DEF}"; exist=0;
            fi
            [ $exist == "1" ] && echo -e "  > ${cyn}"${stack}" ${YLW}COMPOSE FOLDER SET AND FILES ${ylw}REMOVED ${DEF}";
          done
          break
        ;;
        ([nN]|[nN][oO]) break ;;
        (*) fnc_invalid_input ;;
      esac
    done
  }

# output determination logic
  case "${1}" in 
    ("") fnc_nothing_to_do ;;
    (-*) # validate and perform option
      case "${1}" in
        ("-h"|"--help"|"-help") fnc_help ;;
        ("-c"|"--create") fnc_array_cleanup "${args_list}"; fnc_folder_create "${folder_list}"; echo ;;
        ("-d"|"--delete") fnc_array_cleanup "${args_list}"; fnc_folder_delete "${folder_list}"; echo ;;
        ("-r"|"--remove") fnc_array_cleanup "${args_list}"; fnc_folder_remove "${folder_list}"; echo ;;
        (*) fnc_invalid_syntax ;;
      esac
    ;;
    (*) # default to create folder structure
      folder_list=("${@}"); fnc_folder_create "${folder_list}"; echo ;;
  esac

  # fnc_script_outro