#!/bin/bash

# set variables used in this script
  docker_folder="/opt/docker"
  docker_scripts="${docker_folder}/scripts"
  docker_secrets="${docker_folder}/secrets"
  var_distro="$(awk -F'=' '/^ID=/ { gsub("\"","",$2); print tolower($2) } ' /etc/*-release 2> /dev/null)"

# script help message check and display when called
  fnc_help(){
    echo -e "\e[94m[-> This script installs Docker HomeLab scripts from 'https://www.gitlab.com/qnap-homelab/docker-scripts'. <-]\e[0m"
        echo -e " -"
    echo -e " - SYNTAX: # dsup"
    echo -e " - SYNTAX: # dsup \e[96m-option\e[0m"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     \e[96m-h │ --help      \e[0m│ Displays this help message."
    # echo -e " -     \e[96m-o | --overwrite \e[0m│ Does not prompt for overwrite of scripts if they already exist."
    echo
    exit 1 # Exit script after printing help
    }
  case "$1" in ("-h"|*"help"*) fnc_help ;; esac

# function definitions
  fnc_script_intro(){ echo -e "\e[94m[-> DOCKER HOMELAB TERMINAL SCRIPT INSTALLATION \e[93mSTARTING\e[94m <-]\e[0m"; echo; }
  fnc_script_outro(){ echo -e "\e[94m[-> DOCKER HOMELAB TERMINAL SCRIPT INSTALLATION \e[92mCOMPLETE\e[94m <-]\e[0m"; echo; }
  fnc_invalid_input(){ echo -e "\e[93mINVALID INPUT\e[0m: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
  # fnc_invalid_syntax(){ echo -e "\e[93m >> INVALID OPTION SYNTAX, USE THE \e[96m-help\e[93m OPTION TO DISPLAY PROPER SYNTAX <<\e[0m"; exit 1; }
  # fnc_nothing_to_do(){ echo -e " >> \e[93mDOCKER HOMELAB FILES ALREADY EXIST, AND WILL NOT BE OVERWRITTEN\e[0m << "; echo; }

# script intro message
  fnc_script_intro

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
        ln -s "/share/docker" "${docker_folder}" && chown "${docker_uid}:${docker_gid}" "${docker_folder}"
      fi
      ;;
    (*)
      case ${var_distro} in
        (""|"debian")
          unset var_sudo;
          ;;
        (*)
          var_sudo="sudo ";
          ;;
      esac
      if [ ! -d "${docker_folder}" ] ; then
        "${var_sudo}"install -o "${docker_uid}" -g "${docker_gid}" -m 755 "${docker_folder}"
      fi
      ;;
  esac
  [ -d "${docker_folder}" ] && "${var_sudo}"chmod g+s "${docker_folder}"

# docker sub-folder creation
  "${var_sudo}"mkdir -pm 664 "${docker_folder}"/{appdata,compose,scripts,secrets,swarm} && "${var_sudo}"chmod 660 -R "${docker_secrets}";
  "${var_sudo}"wget -O - https://api.github.com/repos/qnap-homelab/docker-scripts/tarball/master | "${var_sudo}"tar -xzf - -C "${docker_scripts}" --strip=1;
  "${var_sudo}"chown -R "${docker_uid}":"${docker_uid}" -R "${docker_folder}";
  "${var_sudo}"sed -i "s/var_usr=1000/var_usr=${docker_uid}/g" "${docker_scripts}"/.vars_docker.conf;
  "${var_sudo}"sed -i "s/var_grp=1000/var_grp=${docker_gid}/g" "${docker_scripts}"/.vars_docker.conf;

# script completion message
  fnc_script_outro