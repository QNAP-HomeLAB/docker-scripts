#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.conf

# script variable definitions
  unset folder_list IFS; folder_list=("${@}");
  # unset args_list IFS; args_list=("${@}");

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script creates Docker configuration folders using the schema created by ${CYN}Drauku${blu} <-]${DEF}"
    echo -e " -     ${blu}(modified from ${CYN}gkoerk's (RIP)${blu} famously awesome folder structure for stacks)${DEF}"
    echo -e " -"
    echo -e " - Enter up to nine(9) container_names in a single command, separated by a 'space' character: "
    echo -e " -   SYNTAX: dcf ${cyn}appname1${DEF} ${cyn}appname2${DEF} ... ${cyn}appname9${DEF}"
    echo -e " -   SYNTAX: dcf ${cyn}-option${DEF}"
    echo -e " -     VALID OPTIONS:"
    echo -e " -       ${cyn}-c │ --create ${DEF}│ ${grn}Creates${def} ${mgn}{docker_appdata,docker_compose}/${cyn}appname${DEF}"
    echo -e " -       ${cyn}-d │ --delete ${DEF}│ ${ylw}Deletes${def} ${mgn}{docker_appdata,docker_compose}/${cyn}appname${DEF} & ${MGN}contents${DEF}"
    echo -e " -       ${cyn}-r │ --remove ${DEF}│ ${red}Removes${def} all sub-folders and files in ${mgn}{docker_appdata,docker_compose}/${cyn}appname${DEF}"
    echo -e " -       ${cyn}-h │ --help   ${DEF}| Displays this help message."
    echo -e " -"
    echo -e " -   NOTE: The below folder structure is created for each 'appname' entered with this command:"
    echo -e " -       ${mgn}${docker_appdata}/${cyn}appname${DEF}"
    echo -e " -       ${mgn}${docker_compose}/${cyn}appname${DEF}"
    # echo -e " -       ${mgn}${compose_runtime}/${cyn}appname${DEF}"
    # echo -e " -       ${mgn}/share/compose/secrets/${cyn}appname${DEF}"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu}[-  CREATE DOCKER COMPOSE FOLDER STRUCTURE FOR LISTED STACKS  -]${def}"; }
  fnc_script_outro(){ echo; exit 1; }
  fnc_invalid_input(){ echo -e "${YLW} >> INVALID INPUT${DEF}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE ${cyn}-help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}" && fnc_script_outro; }
  fnc_nothing_to_do(){ echo -e "${YLW} >> A valid option and container name(s) must be entered for this command to work (use ${cyn}--help ${YLW}for info)${DEF}"; }
  fnc_confirm_remove(){ echo -e "${ylw}Are you sure you want to ${red}DELETE / REMOVE${ylw} files and folders for the ${blu}\"${1}\"${ylw} container?\n  ${MGN}WARNING: ${red}THIS ACTION CANNOT BE UNDONE!${def}"; }
  # fnc_array_cleanup(){ folder_list=( $(for index in "${!args_list[@]}"; do echo -e "${args_list[$index + 1]}"; done) ); }
  # fnc_array_cleanup(){ while IFS=$'\n' read -r line; do folder_list+=("${line}"); done < <(for index in "${!args_list[@]}"; do echo -e "${args_list[${index} + 1]}"; done); }
  # fnc_file_search() { [[ $(find ./"${@}" -type f) ]]; }
  fnc_folder_create_message(){ echo -e "  > ${GRN}CREATED ${blu}${docker_compose}/${stack}${def} AND ${blu}${docker_appdata}/${stack}${def} FOLDERS AND TEMPLATES ${DEF}"; }
  fnc_folder_create(){
    echo; exist=0;
    for stack in "${folder_list[@]}"; do
      if [ ! -d "${docker_appdata}/${stack}/" ];
        then install -o "${var_usr}" -g "${var_grp}" -m 660 -d "${docker_appdata}/${stack}";
        else echo -e "  > ${CYN}${docker_appdata}${cyn}/${stack}  ${ylw}ALREADY EXISTS ${DEF}"; exist=1;
      fi;
      if [ ! -f "${docker_appdata}/${stack}/${stack}.log" ];
        then install -m 660 "${var_template_file}" "${docker_appdata}/${stack}/${stack}-logs.yml";
        # then touch "${docker_compose}/${stack}/${stack}.log" && chmod 660 "${docker_compose}/${stack}/${stack}.log";
        else echo -e "  > ${CYN}${docker_appdata}/${cyn}${stack}/${stack}-logs.yml ${ylw}ALREADY EXISTS${DEF}";
      fi;
      # if [[ "${stack}" = "[tT][rR][aA][eE][fF][iI][kK]" ]] && [ ! -f "${docker_appdata}/${stack}/certs/acme.json" ];
      #   then touch "${docker_appdata}/${stack}/certs/acme.json" && chmod 600 "${docker_appdata}/${stack}/acme.json";
      #   else echo -e "  > ${CYN}${docker_appdata}/${cyn}${stack}/certs/acme.json ${ylw}ALREADY EXISTS${DEF}";
      # fi;
      if [ ! -d "${docker_compose}/${stack}/" ];
        then install -o "${var_usr}" -g "${var_grp}" -m 664 -d "${docker_compose}/${stack}";
        else echo -e "  > ${CYN}${docker_compose}${cyn}/${stack}  ${ylw}ALREADY EXISTS ${DEF}"; exist=1;
      fi;
      if [ ! -f "${docker_compose}/${stack}/${stack}-compose.yml" ];
        # then install -m 664 "${var_template_file}" "${docker_compose}/${stack}/${stack}-compose.yml";
        then touch "${docker_compose}/${stack}/${stack}-compose.yml" && chmod 664 "${docker_compose}/${stack}/${stack}-compose.yml";
          { printf "# '%s' docker config file created for a homelab environment - https://github.com/qnap-homelab\n\n" "${stack}";
          } >> "${docker_compose}/${stack}/${stack}-compose.yml";
        else echo -e "  > ${CYN}${docker_compose}/${cyn}${stack}/${stack}-compose.yml ${ylw}ALREADY EXISTS${DEF}";
      fi;
      [ "${exist}" == "0" ] && fnc_folder_create_message;
      # echo "UID:${var_usr} GID:${var_grp}"; echo;
      chown -R "${var_usr}:${var_grp}" "${docker_compose}/${stack}"
      chown -R "${var_usr}:${var_grp}" "${docker_appdata}/${stack}"
    done
    }
  fnc_folder_remove_message(){ echo -e "  > ${RED}REMOVED ${blu}${docker_compose}/${stack}${def} AND ${blu}${docker_appdata}/${cyn}${stack}${def} FOLDERS AND FILES ${DEF}"; }
  fnc_folder_remove(){
    exist=1; fnc_confirm_remove "${*}" ;
    while read -r -p " [(Y)es/(N)o] " input; do
      case "${input}" in
        ([yY]|[yY][eE][sS])
          echo;
          for stack in "${folder_list[@]}"; do
            if [ -d "${docker_appdata}/${stack}" ]; then
              rm -rf "${docker_appdata:?}/${stack:?}" && echo -e "  > ${RED}REMOVED ${cyn}${stack} ${def}APPDATA FOLDER AND FILES ${DEF}";
            else echo -e "  -> ${ylw} INFO: ${CYN}${docker_appdata}${cyn}/${stack}   ${ylw}NOT FOUND ${DEF}"; exist=0;
            fi
            if [ -d "${docker_compose}/${stack}" ]; then
              rm -rf "${docker_compose:?}/${stack:?}" && echo -e "  > ${RED}REMOVED ${cyn}${stack} ${def}COMPOSE FOLDER AND FILES ${DEF}";
            else echo -e "  -> ${ylw} INFO: ${CYN}${docker_compose}${cyn}/${stack}   ${ylw}NOT FOUND ${DEF}"; exist=0;
            fi
            # [ "${exist}" == "1" ] && fnc_folder_remove_message;
          done
          break
        ;;
        ([nN]|[nN][oO]) break ;;
        (*) fnc_invalid_input ;;
      esac
    done
    }
  # fnc_folder_clean_message(){ echo -e "  > ${ylw}CLEANED ${cyn}${stack} ${def}${removed_content} ${DEF}"; }
  # fnc_folder_clean(){
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
  #         [ ! "${removed_content}" == "" ] && fnc_folder_clean_message;
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
        ("-h"|"--help"|"-help")
          fnc_help;
          ;;
        ("-c"|"--create")
          unset "folder_list[0]";
          fnc_folder_create "${folder_list[*]}";
          ;;
        ("-d"|"--delete"|"-r"|"--remove")
          unset "folder_list[0]";
          fnc_folder_remove "${folder_list[*]}";
          ;;
        # ("-a"|"--appdata")
        #   unset "folder_list[0]";
        #   fnc_folder_clean -a "${folder_list[*]}";
        #   ;;
        # ("-g"|"--configs")
        #   unset "folder_list[0]";
        #   fnc_folder_clean -g "${folder_list[*]}";
        #   ;;
        # ("-w"|"--swarm")
        #   unset "folder_list[0]";
        #   fnc_folder_clean -w "${folder_list[*]}";
        #   ;;
        (*)
          fnc_invalid_syntax;
          ;;
      esac
      ;;
    (*) # default to create folder structure
      folder_list=("${@}");
      fnc_folder_create "${folder_list[*]}";
      ;;
  esac

fnc_script_outro