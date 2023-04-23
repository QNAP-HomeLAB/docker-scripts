#!/bin/bash

# warning to modify UID and GID if "dockeruser" was not the first user created during initiailization
  # echo -e "${YLW} >> WARNING: Modify the UID and GID if 'dockeruser' was not the first user created during initiailization << ${DEF}"

# ask user to input `docker_uid` and `docker_gid` with defaults of 1000
  echo -e " If the docker UID: $(id -u) and GID: $(id -g) are correct, enter them below."
  echo -e " Otherwise, check them manually with the 'id docker' command."
  read -p " Enter the UID of the docker user: " docker_uid
  read -p " Enter the GID of the docker user: " docker_gid

# check for `/opt/docker` folder and link or create if not present
  case $(uname -r | grep -o '[^-]\+$') in
    "qnap")
      if [[ ! -d "/share/docker" ]] ; then
        echo -e " You must first create the 'docker/' Shared Folder in QTS before running this script."
        exit 1;
      fi
      if [[ ! -d "/opt/docker" ]] ; then
        ln -s "/share/docker" "/opt/docker"
        chown "${docker_uid}:${docker_gid}" "/opt/docker"
        chmod g+s "/opt/docker"
      fi
    ;;
    *)
      if [[ ! -d "/opt/docker" ]] ; then
        sudo install -o "${docker_uid}" -g "${docker_gid}" -m 755 "/opt/docker"
        sudo chmod g+s "/opt/docker"
      fi
    ;;
  esac

# script help message check and display when called
  fnc_help(){
    echo -e "${blu}[-> This script installs Docker HomeLab scripts from 'https://www.gitlab.com/qnap-homelab/docker-scripts'. <-]${DEF}"
        echo -e " -"
    echo -e " - SYNTAX: # dsup"
    echo -e " - SYNTAX: # dsup ${cyn}-option${DEF}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn}-h │ --help      ${DEF}│ Displays this help message."
    echo -e " -     ${cyn}-o | --overwrite ${DEF}│ Does not prompt for overwrite of scripts if they already exist."
    echo
    exit 1 # Exit script after printing help
    }
  case "$1" in ("-h"|*"help") fnc_help ;; esac
  # if [[ "$1" = "-h" ]] || [[ "$1" = "-help" ]] || [[ "$1" = "--help" ]] ; then fnc_help; fi

# function definitions
  fnc_script_intro(){ echo -e "${ylw}[-> DOCKER HOMELAB TERMINAL SCRIPT INSTALLATION ${blu}STARTING${ylw} <-]${def}"; }
  fnc_script_outro(){ echo -e "${ylw}[-> DOCKER HOMELAB TERMINAL SCRIPT INSTALLATION ${grn}COMPLETE${ylw} <-]${def}"; echo; }
  fnc_invalid_input(){ echo -e "${YLW}INVALID INPUT${DEF}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_nothing_to_do(){ echo -e " >> ${YLW}DOCKER HOMELAB FILES ALREADY EXIST, AND WILL NOT BE OVERWRITTEN${DEF} << "; echo; }

# check for `.vars_docker.conf` file and download if not present
  if [[ ! -f /opt/docker/scripts/.vars_docker.conf ]] ; then
    curl -s https://gitlab.com/qnap-homelab/docker-scripts/.vars_docker.conf -o /share/docker/scripts/.vars_docker.conf
    sed -i "s/var_usr=1000/var_usr=${docker_uid}/g" /share/docker/scripts/.vars_docker.conf
    sed -i "s/var_grp=1000/var_grp=${docker_gid}/g" /share/docker/scripts/.vars_docker.conf
  fi

# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.conf

# command header
  echo -e "${blu}[-> DOCKER HOMELAB HELPER SCRIPT INSTALLATION <-]${DEF}"

# docker sub-folder creation
  if [[ ! -f "${docker_folder}/{appdata,compose,scripts,secrets,swarm}" ]]; then
    # mkdir -pm 600 "${docker_folder}"/{scripts,secrets,swarm/{appdata,configs},compose/{appdata,configs}};
    mkdir -pm 660 "${docker_folder}/{appdata,compose,scripts,secrets,swarm}";
    # setfacl -Rdm g:dockuser:rwx "${docker_folder}";
    # chmod -R 600 "${docker_folder}";
  fi
  chown "${var_usr}":"${var_grp}" -R "${docker_folder}"

# Script completion message
  fnc_script_outro
  echo