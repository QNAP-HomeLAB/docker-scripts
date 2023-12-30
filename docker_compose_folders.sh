#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# script variable definitions
  unset folder_list IFS; folder_list=("${@}");
  # unset args_list IFS; args_list=("${@}");
  ## chmod -R a-rwx,u=rwX,g+rX,o=rX # drwxr-x---
  appdata_permissions="660" # a-x,ug=rwX,o-rwx # -rw-rw----
  compose_permissions="664" # a-x,ug=rwX,o=rX  # -rw-rw-r--
  folders_permissions="775" # a-x,ug=rwX,o=rX  # drwxrwxr-x
  cert_permissions="600"    # a-rwx,u=rw # -rw-------

# install -o 1000 -g 1000 -m 775 -d /share/docker/{appdata,compose,secrets}/${1}
# install -o 1000 -g 1000 -m 664 /dev/null /share/docker/compose/${1}/compose.yml
# install -o 1000 -g 1000 -m 664 /dev/null /opt/docker/compose/$1/.env
# ln -sf /share/docker/compose/${1}/.env /share/docker/.docker.env

# find /opt/docker -type d -exec chmod 0755 {} \;
# find /opt/docker/compose -type f -exec chmod 0644 {} \;

# function definitions
  fnc_help_compose_folders(){
    echo -e "${blu:?}[-> This script creates Docker configuration folders using the schema created by ${cyn:?}Drauku${blu:?} <-]${def:?}"
    echo -e " -     ${blu:?}(modified from ${cyn:?}gkoerk's (RIP)${blu:?} famously awesome folder structure for stacks)${def:?}"
    echo -e " -"
    echo -e " - Enter up to nine(9) container_names in a single command, separated by a 'space' character: "
    echo -e " -   SYNTAX: dcf ${cyn:?}appname1${def:?} ${cyn:?}appname2${def:?} ... ${cyn:?}appname9${def:?}"
    echo -e " -   SYNTAX: dcf ${cyn:?}-option${def:?}"
    echo -e " -     VALID OPTIONS:"
    echo -e " -       ${cyn:?}-c │ --create      ${def:?}│ ${grn:?}Creates${def:?} ${cyn:?}{docker_appdata,docker_compose}/${mgn:?}appname${def:?}"
    echo -e " -       ${cyn:?}-d │ --delete      ${def:?}│ ${red:?}Deletes${def:?} all sub-folders and files in ${cyn:?}{docker_appdata,docker_compose}/${mgn:?}appname${def:?}"
    # echo -e " -       ${cyn:?}-r │ --replace     ${def:?}│ ${ylw:?}Replace${def:?} all folders and files in ${cyn:?}{docker_appdata,docker_compose}/${mgn:?}appname${def:?}"
    echo -e " -       ${cyn:?}-p │ --permissions ${def:?}│ ${blu:?}Updates${def:?} all folder permissions for listed ${mgn:?}appname(s)${def:?}"
    echo -e " -       ${cyn:?}-h │ --help        ${def:?}| Displays this help message."
    echo -e " -"
    echo -e " -   NOTE: The below folder structure is created for each 'appname' entered with this command:"
    echo -e " -       ${cyn:?}${docker_appdata:?}/${mgn:?}appname${def:?}"
    echo -e " -       ${cyn:?}${docker_compose:?}/${mgn:?}appname${def:?}"
    # echo -e " -       ${mgn:?}${compose_runtime}/${cyn:?}appname${def:?}"
    # echo -e " -       ${mgn:?}/share/compose/secrets/${cyn:?}appname${def:?}"
    echo
    exit 1 # Exit script after printing help
    }
  case "$1" in ("-h"|*"help"*) fnc_help_compose_folders ;; esac

  fnc_script_intro(){ echo; } # echo -e "${blu:?}[-  CREATE DOCKER COMPOSE FOLDER STRUCTURE FOR LISTED STACKS  -]${def:?}"; }
  fnc_script_outro(){ echo; exit 1; }
  fnc_nothing_to_do(){ echo -e "${ylw:?} >> A valid option and container name must be entered for this command to work (use ${cyn:?}--help ${ylw:?}for info) <<${def:?}"; }
  fnc_invalid_input(){ echo -e "${ylw:?} >> INVALID INPUT${def:?}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE ${cyn:?}-help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}" && fnc_script_outro; }
  # fnc_compose_comment(){ echo "# '${stack}' docker config file created for a homelab environment - https://github.com/qnap-homelab\n\n"; }
  fnc_compose_comment(){ printf "# '%s' docker config file created for a homelab environment - https://github.com/qnap-homelab\n\n" "${stack}"; }
  fnc_confirm_remove(){ echo -e "${ylw:?}Are you sure you want to ${red:?}DELETE / REMOVE${ylw:?} files and folders for the ${blu:?}\"${1}\"${ylw:?} container?\n  ${mgn:?}WARNING: ${red:?}THIS ACTION CANNOT BE UNDONE!${def:?}"; }
  # fnc_array_cleanup(){ folder_list=( $(for index in "${!args_list[@]}"; do echo -e "${args_list[$index + 1]}"; done) ); }
  # fnc_array_cleanup(){ while IFS=$'\n' read -r line; do folder_list+=("${line}"); done < <(for index in "${!args_list[@]}"; do echo -e "${args_list[${index} + 1]}"; done); }
  # fnc_file_search() { [[ $(find ./"${@}" -type f) ]]; }
  fnc_action_message(){ # call syntax: fnc_action_message "action" "color"
    echo -e "  -> ${blu:?}${docker_appdata:?}/${mgn:?}${stack}${def:?} AND ${blu:?}${docker_compose:?}/${mgn:?}${stack}${def:?} FOLDERS AND FILES ${2:?} ${1:?}${def:?}";
    }
  fnc_check_env(){
    if [[ ! -f "${docker_scripts}/.vars_docker.env" ]];
    then install -o $var_uid -g $var_gid -m $appdata_permissions "${docker_scripts}/.vars_docker.example" "${docker_scripts}/.vars_docker.env";
    fi;
    }
  fnc_check_sudo(){
    if [[ $(id -u) -ne 0 ]];
    then var_sudo="$(command -v sudo 2>/dev/null) ";
    else unset var_sudo;
    fi; }
  fnc_permissions_update(){
    fnc_check_sudo;
    for stack in "${folder_list[@]}"; do
      if [[ "${1}" = "--all" ]]; then
        # ${var_sudo}find "${docker_appdata}" -type f -exec chmod ${appdata_permissions} {} + -o -type d -exec chmod ${folders_permissions} {} +
        # ${var_sudo}find "${docker_compose}" -type f -exec chmod ${compose_permissions} {} + -o -type d -exec chmod ${folders_permissions} {} +
        ${var_sudo}chmod -R a-rwx,ug=rwX "${docker_appdata:?}/${stack}";
        ${var_sudo}chmod -R a-rwx,ug=rwX,o=rX "${docker_compose:?}/${stack}";
      else
        ## appdata folder and file permissions
        # ${var_sudo}chmod -R "${appdata_permissions}" "${docker_appdata:?}/${stack}";
        # ${var_sudo}chmod "${folders_permissions}" "${docker_appdata:?}/${stack}";
        ${var_sudo}chown -R "${var_uid:-1000}:${var_gid:-1000}" "${docker_appdata:?}/${stack}";
        ${var_sudo}chmod -R a-x,ug=rwX,o= "${docker_appdata:?}/${stack}";

        ## compose folder and file permissions
        # ${var_sudo}chmod -R "${compose_permissions}" "${docker_compose:?}/${stack}";
        # ${var_sudo}chmod "${folders_permissions}" "${docker_compose:?}/${stack}";
        ${var_sudo}chown -R "${var_uid:-1000}:${var_gid:-1000}" "${docker_compose:?}/${stack}";
        ${var_sudo}chmod -R a-x,ug=rwX,o=rX "${docker_compose:?}/${stack}";
      fi
      if [[ "${stack}" = "[tT][rR][aA][eE][fF][iI][kK]" ]]; then ${var_sudo}chmod "${cert_permissions}" "${docker_appdata:?}/${stack}/certs/acme.json"; fi;
    done;
    # echo -e "\n  ${ylw:?}UPDATED ${blu:?}${docker_appdata:?}/${mgn:?}${stack}${def:?} AND ${blu:?}${docker_compose:?}/${mgn:?}${stack}${def:?} FOLDERS AND FILE PERMISSIONS ${def:?}";
    fnc_action_message "FILE AND FOLDER PERMISSIONS UPDATED" "${ylw:?}"
  }
  fnc_folder_create(){
    exist=0;
    # echo;
    fnc_check_sudo;
    for stack in "${folder_list[@]}"; do
      if [ ! -d "${docker_appdata:?}/${stack}/" ];
        then ${var_sudo}install -o "${var_uid:-1000}" -g "${var_gid:-1000}" -m "${folders_permissions}" -d "${docker_appdata:?}/${stack}";
        else fnc_permissions_update "${folder_list[@]}"; fnc_action_message "ALREADY EXISTS" "${blu:?}${docker_appdata:?}/${mgn:?}${stack}${def:?}"; exist=1; # ((++exist));
      fi;
      if [ ! -f "${docker_appdata:?}/${stack}/${stack}.log" ];
        then ${var_sudo}install -m "${appdata_permissions}" /dev/null "${docker_appdata:?}/${stack}/${stack}-logs.yml";
        else fnc_action_message "ALREADY EXISTS" "${blu:?}${docker_appdata:?}/${mgn:?}${stack}${cyn:?}/${stack}-logs.yml${def:?}";
      fi;
      if [[ "${stack}" = "[tT][rR][aA][eE][fF][iI][kK]" ]] && [ ! -f "${docker_appdata:?}/${stack}/certs/acme.json" ];
        then ${var_sudo}install -m "${cert_permissions}" /dev/null "${docker_appdata:?}/${stack}/certs/acme.json";
        # then touch "${docker_appdata:?}/${stack}/certs/acme.json" && ${var_sudo}chmod "${cert_permissions}" "${docker_appdata:?}/${stack}/certs/acme.json";
        # else echo -e "  ${ylw:?}ALREADY EXISTS${def:?} > ${blu:?}${docker_appdata:?}/${mgn:?}${stack}${cyn:?}/certs/acme.json${def:?}";
      fi;
      if [ ! -d "${docker_compose:?}/${stack}/" ];
        then ${var_sudo}install -o "${var_uid:-1000}" -g "${var_gid:-1000}" -m "${folders_permissions}" -d "${docker_compose:?}/${stack}";
          if [ ! -f "${docker_compose:?}/${stack}/.env" ]; then ln -s "${var_script_vars:?}" "${docker_compose:?}/${stack}/.env"; fi;
        else fnc_permissions_update "${folder_list[@]}";
          echo -e "  ${ylw:?}ALREADY EXISTS ${def:?}-> ${blu:?}${docker_compose:?}${mgn:?}/${stack}${def:?}"; exist=1; # ((++exist));
      fi;
      if [ ! -f "${docker_compose:?}/${stack}/compose.yml" ];
        then ${var_sudo}install -o "${var_uid:-1000}" -g "${var_gid:-1000}" -m "${compose_permissions}" /dev/null "${docker_compose:?}/${stack}/compose.yml";
        # then touch "${docker_compose:?}/${stack}/compose.yml" && ${var_sudo}chmod "${compose_permissions}" "${docker_compose:?}/${stack}/compose.yml";
          # { printf "# '%s' docker config file created for a homelab environment - https://github.com/qnap-homelab\n\n" "${stack}";
          { fnc_compose_comment; } >> "${docker_compose:?}/${stack}/compose.yml";
        else echo -e "  ${ylw:?}ALREADY EXISTS ${def:?}-> ${blu:?}${docker_compose:?}/${mgn:?}${stack}${cyn:?}/compose.yml${def:?}";
      fi;
      [ "${exist}" == "0" ] && fnc_action_message "CREATED" "${grn:?}";
      # echo "UID:${var_uid} GID:${var_gid}"; echo;
      # ${var_sudo}chown -R "${var_uid:-1000}:${var_gid:-1000}" "${docker_compose:?}/${stack}"
      # ${var_sudo}chown -R "${var_uid:-1000}:${var_gid:-1000}" "${docker_appdata:?}/${stack}"
    done
    }
  # fnc_folder_remove_message(){ echo -e "  > ${red:?}REMOVED ${blu:?}${docker_compose:?}/${stack}${def:?} AND ${blu:?}${docker_appdata:?}/${mgn:?}${stack}${def:?} FOLDERS AND FILES ${def:?}"; }
  fnc_folder_remove(){
    exist=1; fnc_confirm_remove "${*}" ;
    while read -r -p " [(Y)es/(N)o] " input; do
      case "${input}" in
        ([yY]|[yY][eE][sS])
          echo;
          for stack in "${folder_list[@]}"; do
            if [ -d "${docker_appdata:?}/${stack}" ]; then
              ${var_sudo}rm -rf "${docker_appdata:?}/${stack:?}" #&& echo -e "  > ${red:?}REMOVED ${mgn:?}${stack} ${def:?}APPDATA FOLDER AND FILES ${def:?}";
            else echo -e "  -> ${ylw:?} INFO: ${blu:?}${docker_appdata:?}${mgn:?}/${stack}   ${ylw:?}NOT FOUND ${def:?}"; exist=0;
            fi
            if [ -d "${docker_compose:?}/${stack}" ]; then
              ${var_sudo}rm -rf "${docker_compose:?}/${stack:?}" #&& echo -e "  > ${red:?}REMOVED ${mgn:?}${stack} ${def:?}COMPOSE FOLDER AND FILES ${def:?}";
            else echo -e "  -> ${ylw:?} INFO: ${blu:?}${docker_compose:?}${mgn:?}/${stack}   ${ylw:?}NOT FOUND ${def:?}"; exist=0;
            fi
            [ "${exist}" == "1" ] && fnc_action_message "REMOVED" "${red:?}";
          done
          break
        ;;
        ([nN]|[nN][oO]) break ;;
        (*) fnc_invalid_input ;;
      esac
    done
    }
  # fnc_folder_clean_message(){ echo -e "  > ${ylw:?}CLEANED ${mgn:?}${stack} ${def:?}${content} ${def:?}"; }
  # fnc_folder_clean(){
  #   unset content IFS;
  #   fnc_confirm_remove;
  #   while read -r -p " [(Y)es/(N)o] " input; do
  #     case "${input}" in
  #       ([yY]|[yY][eE][sS])
  #         echo;
  #         case "${folder_list[0]}" in
  #           ("-a") ${var_sudo}rm -rf "${docker_appdata:?}/${stack:?}"/* && content="CONTAINER APPDATA" ;;
  #           ("-g") ${var_sudo}rm -rf "${docker_compose:?}/${stack:?}"/* && content="CONTAINER CONFIGS" ;;
  #           ("-w") ${var_sudo}rm -rf "${docker_swarm:?}/${stack:?}"/* && content="SWARM CONFIGS" ;;
  #         esac
  #         [ ! "${content}" == "" ] && fnc_folder_clean_message;
  #         ;;
  #       ([nN]|[nN][oO]) break ;;
  #       (*) fnc_invalid_input ;;
  #     esac
  #   done
  #   }

# script startup checks
  fnc_script_intro
  fnc_check_sudo
  fnc_check_env

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
        # ("-s"|"-w"|"--swarm")
        #   unset "folder_list[0]";
        #   fnc_folder_clean -w "${folder_list[*]}";
        #   ;;
        ("-p"|"-u"|"--perms"|"--update")
          case "${2}" in
            ("")
              unset "folder_list[0]";
              folder_list=( "$(IFS=$'\n'; cd "${docker_compose:?}" && find . -type d -not -path '*/\.*' | sed 's/^\.\///g')" )
              fnc_permissions_update "${folder_list[@]}";
          esac
          unset "folder_list[0]";
          fnc_permissions_update "${folder_list[@]}";
          ;;
        ("-r"|"--replace")
          unset "folder_list[0]";
          fnc_folder_remove "${folder_list[*]}";
          fnc_folder_create "${folder_list[*]}";
          ;;
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