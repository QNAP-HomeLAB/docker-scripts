#!/bin/bash

# external variables used in this script
  blu=$'\e[94m'
  cyn=$'\e[96m'
  grn=$'\e[92m'
  red=$'\e[91m'
  ylw=$'\e[93m'
  def=$'\e[0m'
  # red="$(printf "\033[38;2;255;000;000m")"; export red
  # orn="$(printf "\033[38;2;255;075;075m")"; export orn
  # ylw="$(printf "\033[38;2;255;255;000m")"; export ylw
  # grn="$(printf "\033[38;2;000;170;000m")"; export grn
  # cyn="$(printf "\033[38;2;085;255;255m")"; export cyn
  # blu="$(printf "\033[38;2;000;120;255m")"; export blu
  # prp="$(printf "\033[38;2;085;085;255m")"; export prp
  # mgn="$(printf "\033[38;2;255;085;255m")"; export mgn
  # wht="$(printf "\033[38;2;255;255;255m")"; export wht
  # blk="$(printf "\033[38;2;025;025;025m")"; export blk
  # def="$(printf "\033[m")"; export def

## default docker folder, updates according to script inputs below
docker_dir="/opt/docker"

  export docker_folder="${docker_folder:-$docker_dir}"
  export docker_scripts="${docker_folder}/scripts"
  export docker_appdata="${docker_folder}/appdata"
  export docker_compose="${docker_folder}/compose"
  export docker_secrets="${docker_folder}/secrets"
  export docker_swarm="${docker_folder}/swarm"

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

## function definitions
  fnc_intro_scripts_setup(){ echo -e "${blu:?}[-> DOCKER HOMELAB TERMINAL SCRIPT INSTALLATION ${ylw:?}STARTING${blu:?} <-]${def:?}"; echo; }
  fnc_outro_scripts_setup(){ echo -e "${blu:?}[-> DOCKER HOMELAB TERMINAL SCRIPT INSTALLATION ${grn:?}COMPLETE${blu:?} <-]${def:?}"; echo; }
  fnc_invalid_input(){ echo -e "${ylw:?}INVALID INPUT${def:?}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
  # fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE ${cyn:?}-help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  # fnc_nothing_to_do(){ echo -e " >> ${ylw:?}DOCKER HOMELAB FILES ALREADY EXIST, AND WILL NOT BE OVERWRITTEN${def:?} << "; echo; }
  fnc_check_sudo(){
    ## check if user id is 0, if not, set var_sudo
    if [[ $(id -u) -ne 0 ]];
    then var_sudo="$(command -v sudo 2>/dev/null) ";
    else unset var_sudo;
    fi;
    }
  fnc_variable_input(){
    unset docker_uid docker_gid
    ## ask user to input `docker_uid` and `docker_gid` with defaults of 1000
    echo -e " If User ID: $(id -u) and Group ID: $(id -g) are correct for the docker user, enter them below."
    echo -e " Otherwise, check the UID and GID manually with the '${mgn:?}id docker${def:?}' command after exiting this script."
    while read -p " - ${red:?}Exit${def:?} this script so you can look up the proper UID/GID?  (Y)es / [N]o " input; do
      case "${input}" in
        ([yY]|[yY][eE][sS])
          exit 1;
          ;;
        ([nN]|[nN][oO]|"")
          read -p " Enter the UID of the docker user: " docker_uid && docker_uid="${docker_uid:-1000}";
          read -p " Enter the GID of the docker user: " docker_gid && docker_gid="${docker_gid:-1000}";
          ;;
        (*)
          fnc_invalid_input
          ;;
      esac
    done;
    while read -p " Currently configured Docker directory is ${cyn:?}${docker_folder}${def:?}  Is this correct?  [Y]es / (N)o " input; do
      case "${input}" in
        ([yY]|[yY][eE][sS]|"")
          return;
          ;;
        ([nN]|[nN][oO])
          read -p " Enter the Docker directory: " docker_folder && docker_folder="${docker_folder:-$docker_dir}";
          ;;
        (*)
          fnc_invalid_input
          ;;
      esac
    done
    }
  fnc_create_directories(){
    # fnc_check_sudo
    if [[ ! -d "${docker_folder}" ]]; then
      ${var_sudo}install -o "${docker_uid}" -g "${docker_gid}" -m 755 -d "${docker_folder}"
      ${var_sudo}chmod g+s "${docker_folder}"
      ${var_sudo}install -o "${docker_uid}" -g "${docker_gid}" -m 755 -d "${docker_folder}"/{appdata,compose,swarm}
      ${var_sudo}install -o "${docker_uid}" -g "${docker_gid}" -m 776 -d "${docker_scripts}"
      ${var_sudo}install -o "${docker_uid}" -g "${docker_gid}" -m 660 -d "${docker_secrets}"
    fi
    ## create symlink from $HOME/docker to $docker_folder
    if [[ ! -d "{$HOME}"/docker ]]; then ln -s "${docker_folder}" "${HOME}"/docker; fi
    ## update the docker_dir variable in this script
    ${var_sudo}sed -i "s|docker_dir=/opt/docker|docker_dir=${docker_folder}|g" "${docker_scripts}/docker_scripts_setup.sh";
    }
  fnc_download_scripts(){
    # fnc_check_sudo
    ${var_sudo}wget -O - https://api.github.com/repos/qnap-homelab/docker-scripts/tarball/master | ${var_sudo}tar -xzf - -C "${docker_scripts}" --strip=1;
    ${var_sudo}chown -R "${docker_uid}":"${docker_gid}" -R "${docker_scripts}";
    ${var_sudo}sed -i "s/var_uid=1000/var_uid=${docker_uid}/g" "${docker_scripts}/.vars_docker.env";
    ${var_sudo}sed -i "s/var_gid=1000/var_gid=${docker_gid}/g" "${docker_scripts}/.vars_docker.env";
    }
  fnc_distro_specific_tasks(){
    ## get distribution common name
    var_distro="$(awk -F'=' '/^ID=/ { gsub("\"","",$2); print tolower($2) } ' /etc/*-release 2> /dev/null)"
    ## check for `docker` folder and link or create if not present
    case ${var_distro} in
      ("qts"|"quts")
        unset exit_code
        if [[ ! -d "/share/docker" ]] ; then
          echo -e " ${red:?}ERROR${def:?}: You must first create the '${cyn:?}docker${def:?}' (${ylw:?}all lowercase${def:?}) Shared Folder in QTS before running this script."
          exit_code=1;
        fi
        if [[ ! -f "/opt/etc/profile" ]] ; then
          echo -e " ${red:?}ERROR${def:?}: You must install the '${cyn:?}entware-std${def:?}' from myqnap.org before running this script."
          exit_code=1;
        fi
        if [[ exit_code -eq 1 ]]; then exit 1; fi
        fnc_create_directories
        ## create symlink from docker_folder to /share/docker for qnap nas only
        if [[ -d "/share/docker" ]] && [[ ! -d "${docker_folder}" ]]; then ln -s "/share/docker" "${docker_folder}"; fi
        # [[ -d "${docker_folder}" ]] && ln -s "/share/docker" "${docker_folder}"
        ## check if /opt/etc/profile automatically loads docker scripts
        source="/opt/docker/scripts/docker_commands_list.sh";
        line="[ -f ${source} ] && . ${source}";
        file="/opt/etc/profile";
        grep -qxF "${line}" "${file}" || echo "${line}" >> "${file}";
        # ln -s "${file}" "${docker_scripts}"/.profile ## create a symlink to /opt/etc/profile
        ;;
      (*)
        fnc_create_directories
        ;;
    esac
    ## check if ~/.bashrc automatically loads docker scripts
    source="${docker_scripts}/docker_commands_list.sh";
    line="[ -f ${source} ] && . ${source}";
    file="$HOME/.bashrc";
    grep -sqxF "${line}" "${file}" || echo "${line}" >> "${file}";
    # create /opt/docker if not present
    if [ ! -d "${docker_folder}" ] ; then
      # fnc_check_sudo
      ${var_sudo}install -o "${docker_uid}" -g "${docker_gid}" -m 755 "${docker_folder}";
    fi
    ## create symlink from $HOME/docker to docker_folder
    if [[ -d "${docker_folder}" ]] && [[ ! -d "$HOME/docker" ]]; then ln -s "${docker_folder}" "$HOME/docker"; fi
    }

## script intro message
  fnc_intro_scripts_setup

## script execution logic
  fnc_variable_input
  fnc_check_sudo
  fnc_distro_specific_tasks
  fnc_download_scripts

## script completion message
-  fnc_outro_scripts_setu-p