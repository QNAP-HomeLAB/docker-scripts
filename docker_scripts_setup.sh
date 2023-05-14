#!/bin/bash

# set variables used in this script
  docker_folder="/opt/docker"
  docker_secrets="${docker_folder}/secrets"
  docker_scripts="${docker_folder}/scripts"
  # var_distro="$(uname -r | grep -o '[^-]\+$')"
  var_distro="$(awk -F'=' '/^ID=/ { gsub("\"","",$2); print tolower($2) } ' /etc/*-release 2> /dev/null)"
  var_git_link="https://raw.githubusercontent.com/QNAP-HomeLAB/docker-scripts/master"

# script help message check and display when called
  fnc_help(){
    echo -e "${blu:?}[-> This script installs Docker HomeLab scripts from 'https://www.gitlab.com/qnap-homelab/docker-scripts'. <-]${DEF:?}"
        echo -e " -"
    echo -e " - SYNTAX: # dsup"
    echo -e " - SYNTAX: # dsup ${cyn:?}-option${DEF:?}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}-h │ --help      ${DEF:?}│ Displays this help message."
    # echo -e " -     ${cyn:?}-o | --overwrite ${DEF:?}│ Does not prompt for overwrite of scripts if they already exist."
    echo
    exit 1 # Exit script after printing help
    }
  case "$1" in ("-h"|*"help"*) fnc_help ;; esac

# function definitions
  fnc_script_intro(){ echo -e "${blu:?}[-> DOCKER HOMELAB TERMINAL SCRIPT INSTALLATION ${ylw:?}STARTING${blu:?} <-]${def:?}"; echo; }
  fnc_script_outro(){ echo -e "${blu:?}[-> DOCKER HOMELAB TERMINAL SCRIPT INSTALLATION ${grn:?}COMPLETE${blu:?} <-]${def:?}"; echo; }
  fnc_invalid_input(){ echo -e "${YLW:?}INVALID INPUT${DEF:?}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
  # fnc_invalid_syntax(){ echo -e "${YLW:?} >> INVALID OPTION SYNTAX, USE THE ${cyn:?}-help${YLW:?} OPTION TO DISPLAY PROPER SYNTAX <<${DEF:?}"; exit 1; }
  # fnc_nothing_to_do(){ echo -e " >> ${YLW:?}DOCKER HOMELAB FILES ALREADY EXIST, AND WILL NOT BE OVERWRITTEN${DEF:?} << "; echo; }

# script intro message
  fnc_script_intro

# warning to modify UID and GID if "dockeruser" was not the first user created during initiailization
  # echo -e "${YLW:?} >> WARNING: Modify the UID and GID if 'dockeruser' was not the first user created during initiailization << ${DEF:?}"

# ask user to input `docker_uid` and `docker_gid` with defaults of 1000
  echo -e " If the UID: $(id -u) and GID: $(id -g) are correct for the docker user, enter them below."
  echo -e " Otherwise, check the UID and GID manually with the 'id docker' command."
  while read -r -p " - Exit this script so you can look up the proper UID/GID? [(Y)es/(N)o] " input; do
    case "${input}" in
      ([yY]|[yY][eE][sS])
        exit 1;
        ;;
      ([nN]|[nN][oO])
        read -pr " Enter the UID of the docker user: " docker_uid && docker_uid="${docker_uid:1000}";
        read -pr " Enter the GID of the docker user: " docker_gid && docker_gid="${docker_gid:1000}";
        ;;
      (*)
        fnc_invalid_input
        ;;
    esac
  done;


# check for `/opt/docker` folder and link or create if not present
  case ${var_distro} in
    ("qts"|"quts")
      unset var_sudo
      if [ ! -d "/share/docker" ] ; then
        echo -e " ERROR: You must first create the 'docker/' Shared Folder in QTS before running this script."
        exit 1;
      fi
      if [ ! -d "${docker_folder}" ] ; then
        ln -s "/share/docker" "${docker_folder}"
        chown "${docker_uid:1000}:${docker_gid:1000}" "${docker_folder}"
      fi
      ;;
    (*)
      case ${var_distro} in
        (""|"debian")
          unset var_sudo;
          ;;
        (*)
          var_sudo="sudo "
          ;;
      esac
      if [ ! -d "${docker_folder}" ] ; then
        "${var_sudo}"install -o "${docker_uid:1000}" -g "${docker_gid:1000}" -m 755 "${docker_folder}"
      fi
      ;;
  esac
  [ -d "${docker_folder}" ] && "${var_sudo}"chmod g+s "${docker_folder}"

# # check for `.color_codes.conf` file and download if not present
#   if [ ! -f "${docker_scripts}/.color_codes.conf" ] ; then
#     # curl -s https://raw.githubusercontent.com/QNAP-HomeLAB/docker-scripts/master/.color_codes.conf -o /share/docker/scripts/.color_codes.conf
#     "${var_sudo}"wget -O "${docker_scripts}/.color_codes.conf" "${var_git_link}/.color_codes.conf"
#     "${var_sudo}"chown "${docker_uid:1000}:${docker_uid:1000}" "${docker_scripts}/.color_codes.conf" && "${var_sudo}"chmod 664 "${docker_scripts}/.color_codes.conf"
#   fi
# # check for `.vars_docker.conf` file and download if not present
#   if [ ! -f "${docker_scripts}/.vars_docker.conf" ] ; then
#     # curl -s https://raw.githubusercontent.com/QNAP-HomeLAB/docker-scripts/master/.vars_docker.conf -o /share/docker/scripts/.vars_docker.conf
#     "${var_sudo}"wget -O "${docker_scripts}/.vars_docker.conf" "${var_git_link}/.vars_docker.conf"
#     "${var_sudo}"chown "${docker_uid:1000}:${docker_uid:1000}" "${docker_scripts}/.vars_docker.conf" && "${var_sudo}"chmod 664 "${docker_scripts}/.vars_docker.conf"
#     sed -i "s/var_usr=1000/var_usr=${docker_uid:1000}/g" /share/docker/scripts/.vars_docker.conf
#     sed -i "s/var_grp=1000/var_grp=${docker_gid:1000}/g" /share/docker/scripts/.vars_docker.conf
#   fi

# # external variable sources
#   source "${docker_scripts}/.color_codes.conf"
#   source "${docker_scripts}/.vars_docker.conf"

# docker sub-folder creation
  "${var_sudo}"mkdir -pm 664 "${docker_folder}"/{appdata,compose,scripts,secrets,swarm} && "${var_sudo}"chmod 660 "${docker_secrets}";
  "${var_sudo}"wget -O - https://api.github.com/repos/qnap-homelab/docker-scripts/tarball/master | "${var_sudo}"tar -xzf - -C "${docker_scripts}" --strip=1;
  "${var_sudo}"chown "${docker_uid:1000}":"${docker_uid:1000}" -R "${docker_folder}";
  "${var_sudo}"sed -i "s/var_usr=1000/var_usr=${docker_uid:1000}/g" "${docker_scripts}"/.vars_docker.conf;
  "${var_sudo}"sed -i "s/var_grp=1000/var_grp=${docker_gid:1000}/g" "${docker_scripts}"/.vars_docker.conf;

  # "${var_sudo}"mkdir -pm 660 "${docker_folder:/opt/docker}"/{appdata,compose,scripts,secrets,swarm};
  # "${var_sudo}"chown "${var_usr:1000}":"${var_grp:1000}" -R "${docker_folder:/opt/docker}";
  # ls "$PWD/dir1" "$PWD/dir2" "$PWD/dir3" >/dev/null 2>&1 && echo All there

  # if [ ! -f "${docker_folder}/scripts" ]; then
  #   mkdir -pm 600 "${docker_folder}"/{scripts,secrets,swarm/{appdata,configs},compose/{appdata,configs}};
  #   setfacl -Rdm g:docker:rwx "${docker_folder}";
  #   chmod -R 600 "${docker_folder}";
  # fi

# Script completion message
  fnc_script_outro