#!/bin/bash

# external variables used in this script
red=$'\033[38;2;255;000;000m'; export red
orn=$'\033[38;2;255;075;075m'; export orn
ylw=$'\033[38;2;255;255;000m'; export ylw
grn=$'\033[38;2;000;170;000m'; export grn
cyn=$'\033[38;2;085;255;255m'; export cyn
blu=$'\033[38;2;000;120;255m'; export blu
prp=$'\033[38;2;085;085;255m'; export prp
mgn=$'\033[38;2;255;085;255m'; export mgn
wht=$'\033[38;2;255;255;255m'; export wht
blk=$'\033[38;2;025;025;025m'; export blk
def=$'\033[m'; export def

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
fnc_intro_scripts_setup(){ echo; echo -e "${blu:?}[-> DOCKER HOMELAB TERMINAL SCRIPT INSTALLATION ${ylw:?}STARTING${blu:?} <-]${def:?}"; echo; }
fnc_outro_scripts_setup(){ echo; echo -e "${blu:?}[-> DOCKER HOMELAB TERMINAL SCRIPT INSTALLATION ${grn:?}COMPLETE${blu:?} <-]${def:?}"; echo; }
fnc_invalid_input(){ echo -e "${ylw:?}INVALID INPUT${def:?}: Must be any case-insensitive variation of '(Y)es' or '(N)o'."; }
    # fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE ${cyn:?}-help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
    # fnc_nothing_to_do(){ echo -e " >> ${ylw:?}DOCKER HOMELAB FILES ALREADY EXIST, AND WILL NOT BE OVERWRITTEN${def:?} << "; echo; }
fnc_check_sudo(){
    ## check if user id is 0, if not, set var_sudo
    user_id=$(id -u) || { echo "Error getting user id"; exit 1; }
    if [[ $user_id -ne 0 ]];
    then var_sudo="$(command -v sudo 2>/dev/null)";
    else unset var_sudo;
    fi;
    }
fnc_variable_input(){
    unset docker_uid docker_gid exit_code
    docker_uid=$(id -u docker 2>/dev/null) || { echo "Error getting docker user id"; return 1; }
    docker_gid=$(id -g docker 2>/dev/null) || { echo "Error getting docker group id"; return 1; }
    ## ask user to input `docker_uid` and `docker_gid` with defaults of 1000
    # echo -e " Currently configured 'docker' user ID: ${orn:?}${docker_uid}${def:?} and docker group ID: ${orn:?}${docker_gid}${def}"
    while read -p " ${mgn:?}Confirm${def:?} the 'docker' user ID: ${orn:?}${docker_uid:-UNKNOWN}${def:?} and docker group ID: ${orn:?}${docker_gid:-UNKNOWN}${def}?  [Y]es - continue / (N)o - manual entry : " input; do
        case "${input}" in
            [yY]|[yY][eE][sS]|"")
                break ;;
            [nN]|[nN][oO])
                echo -e " If you want to set the UID and GID manually, enter below, otherwise enter 'n' to exit the script."
                read -p " Enter the UID of the docker user [1000]: " input_uid
                case "${input_uid}" in
                    [nN]|[nN][oO])
                        exit_code=1
                        break ;;
                    "")
                        docker_uid=1000 ;;
                    *)
                        if [[ ${input_uid} =~ ^[0-9]+$ ]];
                        then docker_uid="${input_uid}"
                        else fnc_invalid_input
                        fi ;;
                esac
                read -p " Enter the GID of the docker user [1000]: " input_gid
                case "${input_gid}" in
                    [nN]|[nN][oO])
                        exit_code=1
                        break ;;
                    "")
                        docker_gid=1000 ;;
                    *)
                        if [[ "${input_gid}" =~ ^[0-9]+$ ]]
                        then docker_gid="${input_gid}"
                        else fnc_invalid_input
                        fi ;;
                esac ;;
            *)
                fnc_invalid_input ;;
        esac
    done;
    if [[ exit_code -eq 1 ]]; then
        echo -e "\n Look up the correct UID/GID with the '${cyn:?}id -u docker${def:?}' and '${cyn:?}id -g docker${def:?}' commands.\n"
        exit 1
    fi

    ## ask user to confirm the docker path, updates according to user input
    while read -p " Currently configured 'docker' directory is ${cyn:?}${docker_dir}${def:?}  Is this correct?  [Y]es / (N)o " input; do
        case "${input}" in
            [yY]|[yY][eE][sS]|"")
                break ;;
            [nN]|[nN][oO])
                read -p " Enter the Docker directory [${docker_dir}]: " input_dkdir ;;
            *)
                fnc_invalid_input ;;
        esac
    done

    # docker subfolder path variables
    docker_dir="${input_dkdir:-$docker_dir}"; export docker_dir
    docker_folder="${docker_folder:-$HOME/docker}"; export docker_folder
    docker_appdata="${docker_folder}/appdata"; export docker_appdata
    docker_compose="${docker_folder}/compose"; export docker_compose
    docker_scripts="${docker_folder}/scripts"; export docker_scripts
    docker_secrets="${docker_folder}/secrets"; export docker_secrets
    docker_swarm="${docker_folder}/swarm"; export docker_swarm

    ## ask user to confirm media data path, updates according to user input
    while read -p " Currently configured Media (Data) path is ${cyn:?}${input_data:-$data_dir}${def:?}  Is this correct?  [Y]es / (N)o " input; do
        case "${input}" in
            [yY]|[yY][eE][sS]|"")
                break ;;
            [nN]|[nN][oO])
                read -p " Enter the Media (Data) path [${data_dir}]: " input_data ;;
            *)
                fnc_invalid_input ;;
        esac
    done
    data_dir="${input_data:-$data_dir}"; export data_dir
    }
fnc_create_directory(){
    dir_path="${1}";
    permissions="${2:-755}";
    if [[ -z "${dir_path}" ]]; then
        echo -e " ${red:?}ERROR${def:?}: Missing required argument for 'fnc_create_directory' function."; return 1;
    fi
    if [[ ! -d "${dir_path}" ]]; then ${var_sudo:-} install -o "${docker_uid}" -g "${docker_gid}" -m "${permissions}" -d "${dir_path}"; fi
    }
fnc_docker_dir_setup(){
    # fnc_check_sudo

    ## folder and file permissions
    perms_cert='a-rwx,u=rwX,g=,o='; export perms_cert # 600 # -rw-rw----
    perms_conf='a-rwx,u+rwX,g=rwX,o=rX'; export perms_conf # 664 # -rw-rw-r--
    perms_data='a-rwx,u+rwX,g=rwX,o='; export perms_data # 660 # -rw-rw----
    perms_main='a=rwX,o-w'; export perms_main # 775 # -rwxrwxr-x

    # if [[ ! -d "${docker_folder}" ]]; then
    #     ${var_sudo:-} install -o "${docker_uid}" -g "${docker_gid}" -m 755 -d "${docker_folder}"
    #     ${var_sudo:-} chmod g+s "${docker_folder}"
    # fi
    # if [[ ! -d "${docker_appdata}" ]]; then ${var_sudo:-} install -o "${docker_uid}" -g "${docker_gid}" -m 755 -d "${docker_appdata}"; fi
    # if [[ ! -d "${docker_compose}" ]]; then ${var_sudo:-} install -o "${docker_uid}" -g "${docker_gid}" -m 755 -d "${docker_compose}"; fi
    # if [[ ! -d "${docker_scripts}" ]]; then ${var_sudo:-} install -o "${docker_uid}" -g "${docker_gid}" -m 776 -d "${docker_scripts}"; fi
    # if [[ ! -d "${docker_secrets}" ]]; then ${var_sudo:-} install -o "${docker_uid}" -g "${docker_gid}" -m 660 -d "${docker_secrets}"; fi
    # if [[ ! -d "${docker_swarm}" ]]; then ${var_sudo:-} install -o "${docker_uid}" -g "${docker_gid}" -m 755 -d "${docker_swarm}"; fi
    fnc_create_directory "${docker_folder}" "${perms_main}" # 755
    ${var_sudo:-} chmod g+s "${docker_folder}"
    fnc_create_directory "${docker_appdata}" "${perms_data}" # 660
    fnc_create_directory "${docker_compose}" "${perms_conf}" # 664
    fnc_create_directory "${docker_swarm}" "${perms_conf}" # 664
    fnc_create_directory "${docker_scripts}" "${perms_main}" # 775
    fnc_create_directory "${docker_secrets}" "${perms_data}" # 660
    ## create symlink from $HOME/docker to $docker_folder
    if [[ ! -d "$HOME/docker" ]]; then ln -s "${docker_folder}" "$HOME/docker"; fi
    ## update the docker_dir variable in this script
    ${var_sudo:-} sed -i "s|docker_dir=/opt/docker|docker_dir=${docker_folder}|g" "${docker_scripts}/docker_scripts_setup.sh";
    }
    fnc_download_scripts(){
    # fnc_check_sudo
    # download all script files from the qnap-homelab repo to the $docker_scripts directory
    ${var_sudo:-} wget -qO - https://api.github.com/repos/qnap-homelab/docker-scripts/tarball/master | ${var_sudo:-} tar -xzf - -C "${docker_scripts}" --strip=1
    echo -e " ${grn:?}Successfully${def:?} downloaded docker helper scripts."

    # copy .vars_docker.example to .vars_docker.env
    ${var_sudo:-} install -o "${docker_uid}" -g "${docker_gid}" -m "${perms_conf}" "${docker_scripts}/.vars_docker.example" "${docker_scripts}/.vars_docker.env";

    ## update .vars_docker.env with variables input or changed via user input in this script
    ${var_sudo:-} sed -i "s|var_uid=1000|var_uid=${docker_uid}|g" "${docker_scripts}/.vars_docker.env";
    ${var_sudo:-} sed -i "s|var_gid=1000|var_gid=${docker_gid}|g" "${docker_scripts}/.vars_docker.env";
    ${var_sudo:-} sed -i "s|data_dir=/mnt/data|data_dir=${data_dir}|g" "${docker_scripts}/.vars_docker.env";
    ${var_sudo:-} sed -i "s|docker_dir=/opt/docker|docker_dir=${docker_dir}|g" "${docker_scripts}/.vars_docker.env";

    # fix ownership of all files and folders inside $docker_scripts
    ${var_sudo:-} chown -R "${docker_uid}":"${docker_gid}" -R "${docker_scripts}";
    }
    fnc_script_prep(){
    ## get distribution common name
    var_distro="$(awk -F'=' '/^ID=/ { gsub("\"","",$2); print tolower($2) } ' /etc/*-release 2> /dev/null)"
    ## check for `docker` folder and link or create if not present
    case ${var_distro} in
        "qts"|"quts")
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
        data_dir=/share/Multimedia
        docker_dir=/share/docker
        fnc_variable_input
        fnc_docker_dir_setup
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
      *)
        data_dir=/mnt/data
        docker_dir=/opt/docker
        fnc_variable_input
        fnc_docker_dir_setup
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
        ${var_sudo:-} install -o "${docker_uid}" -g "${docker_gid}" -m 755 "${docker_folder}";
    fi
    # ## create symlink from $HOME/docker to docker_folder
    # if [[ -d "${docker_folder}" ]] && [[ ! -d "$HOME/docker" ]]; then ln -s "${docker_folder}" "$HOME/docker"; fi
    }

## script intro message
    fnc_intro_scripts_setup

## script execution logic
    fnc_check_sudo
    fnc_script_prep
    fnc_download_scripts

## script completion message
    fnc_outro_scripts_setup
