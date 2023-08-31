#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.conf

# sudo install -o 1000 -g 1000 -m 774 -d /share/docker/{appdata,compose}/dozzle
# sudo install -o 1000 -g 1000 -m 774 /dev/null /share/docker/compose/dozzle/compose.yml
# sudo install -o 1000 -g 1000 -m 774 /dev/null /share/docker/compose/dozzle/.env

# sudo install -o 1000 -g 1000 -m 774 -d /share/docker/appdata/dozzle


# script variable definitions
  unset folder_list IFS; folder_list=("${@}");
  # unset args_list IFS; args_list=("${@}");

# function definitions
  fnc_help_compose_folders(){
    echo -e "${blu:?}[-> This script creates Docker configuration folders using the schema created by ${CYN:?}Drauku${blu:?} <-]${def:?}"
    echo -e " -     ${blu:?}(modified from ${CYN:?}gkoerk's (RIP)${blu:?} famously awesome folder structure for stacks)${def:?}"
    echo -e " -"
    echo -e " - Enter up to nine(9) container_names in a single command, separated by a 'space' character: "
    echo -e " -   SYNTAX: dcf ${cyn:?}appname1${def:?} ${cyn:?}appname2${def:?} ... ${cyn:?}appname9${def:?}"
    echo -e " -   SYNTAX: dcf ${cyn:?}-option${def:?}"
    echo -e " -     VALID OPTIONS:"
    echo -e " -       ${cyn:?}-c │ --create ${def:?}│ ${grn:?}Creates${def:?} ${mgn:?}{docker_appdata,docker_compose}/${cyn:?}appname${def:?}"
    echo -e " -       ${cyn:?}-d │ --delete ${def:?}│ ${ylw:?}Deletes${def:?} ${mgn:?}{docker_appdata,docker_compose}/${cyn:?}appname${def:?} & ${MGN:?}contents${def:?}"
    echo -e " -       ${cyn:?}-r │ --remove ${def:?}│ ${red:?}Removes${def:?} all sub-folders and files in ${mgn:?}{docker_appdata,docker_compose}/${cyn:?}appname${def:?}"
    echo -e " -       ${cyn:?}-h │ --help   ${def:?}| Displays this help message."
    echo -e " -"
    echo -e " -   NOTE: The below folder structure is created for each 'appname' entered with this command:"
    echo -e " -       ${mgn:?}${docker_appdata}/${cyn:?}appname${def:?}"
    echo -e " -       ${mgn:?}${docker_compose}/${cyn:?}appname${def:?}"
    # echo -e " -       ${mgn:?}${compose_runtime}/${cyn:?}appname${def:?}"
    # echo -e " -       ${mgn:?}/share/compose/secrets/${cyn:?}appname${def:?}"
    echo
    exit 1 # Exit script after printing help
    }
  case "$1" in ("-h"|*"help"*) fnc_help_compose_folders ;; esac

  fnc_script_intro(){ echo -e "${blu:?}[-  CREATE DOCKER COMPOSE FOLDER STRUCTURE FOR LISTED STACKS  -]${def:?}"; }
  fnc_script_outro(){ echo; exit 1; }
  fnc_invalid_input(){ echo -e "${YLW:?} >> INVALID INPUT${def:?}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
  fnc_invalid_syntax(){ echo -e "${YLW:?} >> INVALID OPTION SYNTAX, USE THE ${cyn:?}-help${YLW:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}" && fnc_script_outro; }
  fnc_nothing_to_do(){ echo -e "${YLW:?} >> A valid option and container name(s) must be entered for this command to work (use ${cyn:?}--help ${YLW:?}for info)${def:?}"; }
  fnc_confirm_remove(){ echo -e "${ylw:?}Are you sure you want to ${red:?}DELETE / REMOVE${ylw:?} files and folders for the ${blu:?}\"${1}\"${ylw:?} container?\n  ${MGN:?}WARNING: ${red:?}THIS ACTION CANNOT BE UNDONE!${def:?}"; }
  # fnc_array_cleanup(){ folder_list=( $(for index in "${!args_list[@]}"; do echo -e "${args_list[$index + 1]}"; done) ); }
  # fnc_array_cleanup(){ while IFS=$'\n' read -r line; do folder_list+=("${line}"); done < <(for index in "${!args_list[@]}"; do echo -e "${args_list[${index} + 1]}"; done); }
  # fnc_file_search() { [[ $(find ./"${@}" -type f) ]]; }
  fnc_check_sudo_usage(){
    case "$(awk -F'=' '/^ID=/ { gsub("\"","",$2); print tolower($2) } ' /etc/*-release 2> /dev/null)" in
      ("qts"|"quts"|"debian")
        unset var_sudo IFS;
        case "$(id -un)" in
          ("admin"|"root")
            unset var_sudo IFS;
            ;;
          (*)
            var_sudo="sudo ";
            ;;
        esac
        ;;
      (*)
        var_sudo="sudo ";
        ;;
    esac
    }
  fnc_folder_create_message(){ echo -e "  > ${GRN:?}CREATED ${blu:?}${docker_compose}/${stack}${def:?} AND ${blu:?}${docker_appdata}/${stack}${def:?} FOLDERS AND TEMPLATES ${def:?}"; }
  fnc_folder_create(){
    echo; exist=0;
    fnc_check_sudo_usage;
    for stack in "${folder_list[@]}"; do
      if [ ! -d "${docker_appdata}/${stack}/" ];
        then "${var_sudo}"install -o "${var_uid}" -g "${var_gid}" -m 660 -d "${docker_appdata}/${stack}";
        else echo -e "  > ${CYN:?}${docker_appdata}${cyn:?}/${stack}  ${ylw:?}ALREADY EXISTS ${def:?}"; exist=1; # ((++exist));
      fi;
      if [ ! -f "${docker_appdata}/${stack}/${stack}.log" ];
        then "${var_sudo}"install -m 660 "${var_template_file}" "${docker_appdata}/${stack}/${stack}-logs.yml";
        # then touch "${docker_compose}/${stack}/${stack}.log" && "${var_sudo}"chmod 660 "${docker_compose}/${stack}/${stack}.log";
        else echo -e "  > ${CYN:?}${docker_appdata}/${cyn:?}${stack}/${stack}-logs.yml ${ylw:?}ALREADY EXISTS${def:?}";
      fi;
      # if [[ "${stack}" = "[tT][rR][aA][eE][fF][iI][kK]" ]] && [ ! -f "${docker_appdata}/${stack}/certs/acme.json" ];
      #   then touch "${docker_appdata}/${stack}/certs/acme.json" && "${var_sudo}"chmod 600 "${docker_appdata}/${stack}/acme.json";
      #   else echo -e "  > ${CYN:?}${docker_appdata}/${cyn:?}${stack}/certs/acme.json ${ylw:?}ALREADY EXISTS${def:?}";
      # fi;
      if [ ! -d "${docker_compose}/${stack}/" ];
        then "${var_sudo}"install -o "${var_uid}" -g "${var_gid}" -m 664 -d "${docker_compose}/${stack}";
        else echo -e "  > ${CYN:?}${docker_compose}${cyn:?}/${stack}  ${ylw:?}ALREADY EXISTS ${def:?}"; exist=1; # ((++exist));
      fi;
      if [ ! -f "${docker_compose}/${stack}/${stack}-compose.yml" ];
        # then "${var_sudo}"install -m 664 "${var_template_file}" "${docker_compose}/${stack}/${stack}-compose.yml";
        then touch "${docker_compose}/${stack}/${stack}-compose.yml" && "${var_sudo}"chmod 664 "${docker_compose}/${stack}/${stack}-compose.yml";
          { printf "# '%s' docker config file created for a homelab environment - https://github.com/qnap-homelab\n\n" "${stack}";
          } >> "${docker_compose}/${stack}/${stack}-compose.yml";
        else echo -e "  > ${CYN:?}${docker_compose}/${cyn:?}${stack}/${stack}-compose.yml ${ylw:?}ALREADY EXISTS${def:?}";
      fi;
      [ "${exist}" == "0" ] && fnc_folder_create_message;
      # echo "UID:${var_uid} GID:${var_gid}"; echo;
      "${var_sudo}"chown -R "${var_uid}:${var_gid}" "${docker_compose}/${stack}"
      "${var_sudo}"chown -R "${var_uid}:${var_gid}" "${docker_appdata}/${stack}"
    done
    }
  fnc_folder_remove_message(){ echo -e "  > ${RED:?}REMOVED ${blu:?}${docker_compose}/${stack}${def:?} AND ${blu:?}${docker_appdata}/${cyn:?}${stack}${def:?} FOLDERS AND FILES ${def:?}"; }
  fnc_folder_remove(){
    exist=1; fnc_confirm_remove "${*}" ;
    while read -r -p " [(Y)es/(N)o] " input; do
      case "${input}" in
        ([yY]|[yY][eE][sS])
          echo;
          for stack in "${folder_list[@]}"; do
            if [ -d "${docker_appdata}/${stack}" ]; then
              "${var_sudo}"rm -rf "${docker_appdata:?}/${stack:?}" && echo -e "  > ${RED:?}REMOVED ${cyn:?}${stack} ${def:?}APPDATA FOLDER AND FILES ${def:?}";
            else echo -e "  -> ${ylw:?} INFO: ${CYN:?}${docker_appdata}${cyn:?}/${stack}   ${ylw:?}NOT FOUND ${def:?}"; exist=0;
            fi
            if [ -d "${docker_compose}/${stack}" ]; then
              "${var_sudo}"rm -rf "${docker_compose:?}/${stack:?}" && echo -e "  > ${RED:?}REMOVED ${cyn:?}${stack} ${def:?}COMPOSE FOLDER AND FILES ${def:?}";
            else echo -e "  -> ${ylw:?} INFO: ${CYN:?}${docker_compose}${cyn:?}/${stack}   ${ylw:?}NOT FOUND ${def:?}"; exist=0;
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
  # fnc_folder_clean_message(){ echo -e "  > ${ylw:?}CLEANED ${cyn:?}${stack} ${def:?}${removed_content} ${def:?}"; }
  # fnc_folder_clean(){
  #   unset removed_content IFS;
  #   fnc_confirm_remove;
  #   while read -r -p " [(Y)es/(N)o] " input; do
  #     case "${input}" in
  #       ([yY]|[yY][eE][sS])
  #         echo;
  #         case "${folder_list[0]}" in
  #           ("-a") "${var_sudo}"rm -rf "${docker_appdata:?}/${stack:?}"/* && removed_content="CONTAINER APPDATA" ;;
  #           ("-g") "${var_sudo}"rm -rf "${docker_compose:?}/${stack:?}"/* && removed_content="CONTAINER CONFIGS" ;;
  #           ("-w") "${var_sudo}"rm -rf "${docker_swarm:?}/${stack:?}"/* && removed_content="SWARM CONFIGS" ;;
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