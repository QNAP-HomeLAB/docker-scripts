#!/bin/bash

# external variables used in this script
  blu='\e[94m'
  cyn='\e[96m'
  grn='\e[92m'
  red='\e[91m'
  ylw='\e[93m'
  def='\e[0m'

  docker_folder="/opt/docker"

# script help message check and display when called
  fnc_help_scripts_setup(){
    echo -e "${blu:?}[-> This script installs Docker HomeLab scripts from 'https://www.gitlab.com/qnap-homelab/docker-scripts'. <-]${def:?}"
        echo -e " -"
    echo -e " - SYNTAX: # dsup"
    echo -e " - SYNTAX: # dsup ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}-h │ --help      ${def:?}│ Displays this help message."
    # echo -e " -     ${cyn:?}-o | --overwrite ${def:?}│ Does not prompt for overwrite of scripts if they already exist."
    echo
    exit 1 # Exit script after printing help
    }
  case "$1" in ("-h"|*"help"*) fnc_help_scripts_setup ;; esac

# function definitions
  fnc_intro_scripts_setup(){ echo -e "${blu:?}[-> DOCKER HOMELAB TERMINAL SCRIPT INSTALLATION ${ylw:?}STARTING${blu:?} <-]${def:?}"; echo; }
  fnc_outro_scripts_setup(){ echo -e "${blu:?}[-> DOCKER HOMELAB TERMINAL SCRIPT INSTALLATION ${grn:?}COMPLETE${blu:?} <-]${def:?}"; echo; }
  fnc_invalid_input(){ echo -e "${ylw:?}INVALID INPUT${def:?}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
  # fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE ${cyn:?}-help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  # fnc_nothing_to_do(){ echo -e " >> ${ylw:?}DOCKER HOMELAB FILES ALREADY EXIST, AND WILL NOT BE OVERWRITTEN${def:?} << "; echo; }
  fnc_check_uid_gid(){
    # ask user to input `docker_uid` and `docker_gid` with defaults of 1000
    echo -e " If the UID: $(id -u) and GID: $(id -g) are correct for the docker user, enter them below."
    echo -e " Otherwise, check the UID and GID manually with the 'id docker' command."
    while read -r -p " - ${red:?}Exit${def:?} this script so you can look up the proper UID/GID? [(Y)es/(N)o] " input; do
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
    }

  fnc_create_directories(){
    [[ ! -d "${docker_folder}" ]] && "${var_sudo}"install -o "${docker_uid}" -g "${docker_gid}" -m 755 -d "${docker_folder}"
    "${var_sudo}"install -o "${docker_uid}" -g "${docker_gid}" -m 755 -d "${docker_folder}"/{appdata,compose,swarm}
    "${var_sudo}"install -o "${docker_uid}" -g "${docker_gid}" -m 770 -d "${docker_scripts}"
    "${var_sudo}"install -o "${docker_uid}" -g "${docker_gid}" -m 660 -d "${docker_secrets}"
    [[ -d "${docker_folder}" ]] && "${var_sudo}"chmod g+s "${docker_folder}"
    }

  fnc_download_scripts(){
    "${var_sudo}"wget -O - https://api.github.com/repos/qnap-homelab/docker-scripts/tarball/master | "${var_sudo}"tar -xzf - -C "${docker_scripts}" --strip=1;
    "${var_sudo}"chown -R "${docker_uid}":"${docker_uid}" -R "${docker_scripts}";
    "${var_sudo}"sed -i "s/var_usr=1000/var_usr=${docker_uid}/g" "${docker_scripts}"/.vars_docker.conf;
    "${var_sudo}"sed -i "s/var_grp=1000/var_grp=${docker_gid}/g" "${docker_scripts}"/.vars_docker.conf;
    }

  fnc_distro_specific_tasks(){
    # get distribution common name
    var_distro="$(awk -F'=' '/^ID=/ { gsub("\"","",$2); print tolower($2) } ' /etc/*-release 2> /dev/null)"
    # set docker subdirectory paths
    docker_scripts="${HOME}/docker/scripts"
    docker_secrets="${HOME}/docker/secrets"

    # check for `docker` folder and link or create if not present
    case ${var_distro} in
      ("qts"|"quts")
        case $(id -un) in
          ("admin")
            unset var_sudo
            if [[ ! -d "/share/docker" ]] ; then
              echo -e " ${red:?}ERROR${def:?}: You must first create the '${cyn:?}docker${def:?}' (${ylw:?}all lowercase${def:?}) Shared Folder in QTS before running this script."
              exit 1;
            fi
            ;;
          (*)
            var_sudo="sudo ";
            ;;
        esac
        fnc_create_directories
        # create symlink from docker_folder to /share/docker for qnap nas only
        [[ ! -d "${docker_folder}" ]] && ln -s "/share/docker" "/opt/docker"
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
        fnc_create_directories
        ;;
    esac
    # # create symlink from $HOME/docker to docker_folder
    # [[ ! -d "${docker_folder}" ]] && ln -s "/opt/docker" "$HOME/docker"
    }

# script intro message
  fnc_intro_scripts_setup

# script execution logic
  fnc_check_uid_gid
  fnc_distro_specific_tasks
  # fnc_create_directories
  fnc_download_scripts

# script completion message
  fnc_outro_scripts_setup