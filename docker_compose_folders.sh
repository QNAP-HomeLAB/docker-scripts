#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.script_vars.conf

# script variable definitions
  unset folder_list IFS; folder_list=("${@}");
  # unset args_list IFS; args_list=("${@}");

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script creates Docker configuration folders using the schema created by ${CYN}Drauku${blu} <-]${DEF}"
    echo -e " -     ${blu}(modified from ${CYN}gkoerk's (RIP)${blu} famously awesome folder structure for stacks)${DEF}"
    echo -e " -"
    echo -e " - Enter up to nine(9) container_names in a single command, separated by a 'space' character: "
    echo -e " -   SYNTAX: dcf ${cyn}compose_file1${DEF} ${cyn}compose_file2${DEF} ... ${cyn}compose_file9${DEF}"
    echo -e " -   SYNTAX: dcf ${cyn}-option${DEF}"
    echo -e " -     VALID OPTIONS:"
    echo -e " -       ${cyn}-c │ --create ${DEF}│ ${grn}Creates${def} ${YLW}{docker_appdata,docker_compose}/${cyn}compose_stack${DEF}"
    echo -e " -       ${cyn}-d │ --delete ${DEF}│ ${ylw}Deletes${def} ${YLW}{docker_appdata,docker_compose}/${cyn}compose_stack${DEF} & ${ylw}contents${DEF}"
    echo -e " -       ${cyn}-r │ --remove ${DEF}│ ${red}Removes${def} all sub-folders and files in ${YLW}{docker_appdata,docker_compose}/${cyn}compose_stack${DEF}"
    echo -e " -       ${cyn}-h │ --help   ${DEF}| Displays this help message."
    echo -e " -"
    echo -e " -   NOTE: The below folder structure is created for each 'compose_file' entered with this command:"
    echo -e " -       ${YLW}${docker_appdata}/${cyn}compose_file${DEF}"
    echo -e " -       ${YLW}${docker_compose}/${cyn}compose_file${DEF}"
    # echo -e " -       ${YLW}${compose_runtime}/${cyn}compose_stack${DEF}"
    # echo -e " -       ${YLW}/share/compose/secrets/${cyn}compose_stack${DEF}"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu}[-  CREATE DOCKER-COMPOSE FOLDER STRUCTURE FOR LISTED STACKS  -]${def}"; }
  fnc_script_outro(){ echo -e "${GRN} -  COMPOSE FOLDER STRUCTURE CREATED${DEF}"; echo; exit 1; }
  fnc_nothing_to_do(){ echo -e "${YLW} >> A valid option and container name(s) must be entered for this command to work (use ${cyn}--help ${YLW}for info)${DEF}"; }
  fnc_invalid_input(){ echo -e "${YLW} >> INVALID INPUT${DEF}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE ${cyn}-help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; echo; exit 1; }
  fnc_confirm_remove(){ echo -e "${ylw}Are you sure you want to ${red}REMOVE${ylw} files and/or folders for the listed container?${def}"; }
  # fnc_array_cleanup(){ folder_list=( $(for index in "${!args_list[@]}"; do echo -e "${args_list[$index + 1]}"; done) ); }
  # fnc_array_cleanup(){ while IFS=$'\n' read -r line; do folder_list+=("${line}"); done < <(for index in "${!args_list[@]}"; do echo -e "${args_list[${index} + 1]}"; done); }
  # fnc_file_search() { [[ $(find ./"${@}" -type f) ]]; }
  fnc_folder_create(){
    echo; exist=0;
    for stack in "${folder_list[@]}"; do
      if [ ! -d "${docker_appdata}/${stack}/" ];
        then install -o "${var_usr}" -g "${var_grp}" -m 664 -d "${docker_appdata}/${stack}";
        else echo -e "  > ${CYN}${docker_appdata}${cyn}/${stack}  ${ylw}ALREADY EXISTS ${DEF}"; exist=1;
      fi;
      if [ ! -f "${docker_appdata}/${stack}/${stack}-logs.yml" ];
        then install -m 660 "${var_template_file}" "${docker_appdata}/${stack}/${stack}-logs.yml";
        else echo -e "  > ${CYN}${docker_appdata}/${cyn}${stack}/${stack}-logs.yml ${ylw}ALREADY EXISTS${DEF}";
      fi;
      # if [[ "${stack}" = "[tT][rR][aA][eE][fF][iI][kK]" ]] && [ ! -f "${docker_appdata}/${stack}/certs/acme.json" ];
      #   then touch "${docker_appdata}/${stack}/certs/acme.json" && chmod 600 "${docker_appdata}/${stack}/acme.json";
      #   else echo -e "  > ${CYN}${docker_appdata}/${cyn}${stack}/certs/acme.json ${ylw}ALREADY EXISTS${DEF}";
      # fi;
      if [ ! -d "${docker_compose}/${stack}/" ];
        then install -o "${var_usr}" -g "${var_grp}" -m 664 -d "${docker_compose}/${stack}";
        else echo -e "  > ${CYN}${docker_compose}${cyn}/${stack}   ${ylw}ALREADY EXISTS ${DEF}"; exist=1;
      fi;
      if [ ! -f "${docker_compose}/${stack}/${stack}-compose.yml" ];
        # then install -m 664 "${var_template_file}" "${docker_compose}/${stack}/${stack}-compose.yml";
        then touch "${docker_compose}/${stack}/${stack}-compose.yml" && chmod 664 "${docker_compose}/${stack}/${stack}-compose.yml";
          { printf "# '%s' docker config file created for the homelab described here https://github.com/qnap-homelab\n---\n" "${stack}";
          } >> "${docker_compose}/${stack}/${stack}-compose.yml";
        else echo -e "  > ${CYN}${docker_compose}/${cyn}${stack}/${stack}-compose.yml ${ylw}ALREADY EXISTS${DEF}";
      fi;
      [ "${exist}" == "0" ] && echo -e "  > ${cyn}${stack} ${DEF}APPDATA AND COMPOSE FOLDERS ${grn}CREATED ${DEF}";
    done
    }

  fnc_folder_remove(){
    exist=1; fnc_confirm_remove;
    while read -r -p " [(Y)es/(N)o] " input; do
      case "${input}" in
        ([yY]|[yY][eE][sS])
          echo;
          for stack in "${folder_list[@]}"; do
            if [ -d "${docker_appdata}/${stack}" ]; then
              rm -rf "${docker_appdata:?}/${stack:?}"; # && echo -e "  > ${cyn}${stack} ${def}COMPOSE APPDATA FOLDER AND FILES ${ylw}REMOVED ${DEF}";
            else echo -e "  -- ${CYN}${docker_appdata}${cyn}/${stack}   ${ylw}NOT FOUND ${DEF}"; exist=0;
            fi
            if [ -d "${docker_compose}/${stack}" ]; then
              rm -rf "${docker_compose:?}/${stack:?}"; # && echo -e "  > ${cyn}${stack} ${def}COMPOSE CONFIGS FOLDER AND FILES ${ylw}REMOVED ${DEF}";
            else echo -e "  -> ${CYN}${docker_compose}${cyn}/${stack}   ${ylw}NOT FOUND ${DEF}"; exist=0;
            fi
            [ "${exist}" == "1" ] && echo -e "  > ${cyn}${stack} ${def}APPDATA AND COMPOSE FOLDERS AND FILES ${red}REMOVED ${DEF}";
          done
          break
        ;;
        ([nN]|[nN][oO]) break ;;
        (*) fnc_invalid_input ;;
      esac
    done
    }

  # fnc_folders_clean(){
  #   unset removed_content IFS;
  #   fnc_confirm_remove;
  #   while read -r -p " [(Y)es/(N)o] " input; do
  #     case "${input}" in
  #       ([yY]|[yY][eE][sS])
  #         echo;
  #         case "${folder_list[0]}" in
  #           ("-a") rm -rf "${docker_appdata:?}/${stack:?}"/* && removed_content="CONTAINER APPDATA" ;;
  #           ("-g") rm -rf "${docker_compose:?}/${stack:?}"/* && removed_content="CONTAINER CONFIGS" ;;
  #           ("-w") rm -rf "${docker_swarm:?}/${stack:?}"/* && removed_content="SWARM CONFIGS" ;;
  #         esac
  #         [ ! "${removed_content}" == "" ] && echo -e "  > ${cyn}${stack} ${def}${removed_content} ${ylw}CLEANED ${DEF}";
  #         ;;
  #       ([nN]|[nN][oO]) break ;;
  #       (*) fnc_invalid_input ;;
  #     esac
  #   done
  #   }

# output determination logic
  case "${1}" in
    ("") fnc_nothing_to_do ;;
    (-*) # validate and perform option
      case "${1}" in
        ("-h"|"--help"|"-help") fnc_help ;;
        ("-c"|"--create") unset "folder_list[0]"; fnc_folder_create "${folder_list[*]}" ;;
        ("-d"|"--delete"|"-r"|"--remove") unset "folder_list[0]"; fnc_folder_remove "${folder_list[*]}" ;;
        # ("-a"|"--appdata") unset "folder_list[0]"; fnc_folders_clean -a "${folder_list[*]}" ;;
        # ("-g"|"--configs") unset "folder_list[0]"; fnc_folders_clean -g "${folder_list[*]}" ;;
        # ("-w"|"--swarm") unset "folder_list[0]"; fnc_folders_clean -w "${folder_list[*]}" ;;
        (*) fnc_invalid_syntax ;;
      esac
    ;;
    (*) # default to create folder structure
      folder_list=("${@}"); fnc_folder_create "${folder_list[*]}" ;;
  esac
  echo
  # fnc_script_outro
