#!/bin/bash
####################################################################################################
##########
# Place this file in ${HOME}/docker/ and name it dk_functions.sh
# A quick and easy way to do this is to run one of these download commands:
# git archive --remote=https://github.com/QNAP-HomeLAB/docker-scripts.git HEAD:common/dk_functions.sh ${HOME}/docker/functions/common/dk_functions.sh | tar -xvf -
# wget -qN 'https://raw.githubusercontent.com/QNAP-HomeLAB/docker-scripts/functions/common/dk_functions.sh' -O ${HOME}/docker/common/dk_functions.sh
# curl -s 'https://raw.githubusercontent.com/QNAP-HomeLAB/docker-scripts/functions/common/dk_functions.sh' > ${HOME}/docker/common/dk_functions.sh
####################################################################################################

########## --> **** UPDATE THE FOLLOWING VARIABLES FOR YOUR ENVIRONMENT **** <-- ##########

export dk_usr="docker" ## default is `docker`
export dk_grp="docker" ## default is `docker`
export dk_dir="${HOME:-"/opt"}/docker" ## default is `${HOME}/docker`

net_prefix_docker_socket="172.27.0" ## DO NOT include the 4th octet
net_prefix_external_edge="172.27.1" ## DO NOT include the 4th octet
net_prefix_internal_only="172.27.2" ## DO NOT include the 4th octet
net_prefix_reverse_proxy="172.27.3" ## DO NOT include the 4th octet
net_prefix_gwbridge="10.20.0" ## DO NOT include the 4th octet
net_prefix_ingress="10.21.0" ## DO NOT include the 4th octet

#https://raw.githubusercontent.com/qnap-homelab/docker-scripts/master"
git_url_common="https://raw.githubusercontent.com/QNAP-HomeLAB/docker-scripts/functions/common"
git_url_local="https://raw.githubusercontent.com/qnap-homelab/docker-local/master"
git_url_swarm="https://raw.githubusercontent.com/qnap-homelab/docker-swarm/master"

####################################################################################################
##############################  NOTHING BELOW HERE SHOULD BE CHANGED  ##############################
####################################################################################################

## docker folder schema
#  $HOME
#   └── docker
#       ├── common
#       │   ├── .docker.env
#       │   ├── color_codes.conf
#       │   ├── dk_vars.example
#       │   ├── dk_functions.sh
#       │   └── secrets
#       |       ├── my_secret_password.secret
#       │       └── ...
#       ├── local
#       |   ├── appdata
#       |   │   ├── appname
#       |   │   └── ...
#       |   └── configs
#       |       ├── appname
#       |       └── ...
#       └── swarm
#           ├── appdata
#           │   ├── appname
#           │   └── ...
#           └── configs
#               ├── appname
#               └── ...

#################### docker directories setup ####################

    ## array declarations for docker sub-paths and files
    declare -Agx dk; dk=(
        [path]="${dk_dir}"
        [file]="compose.yml"
        [build]="${dk_dir}/build"
        [local]="${dk_dir}/local"
        [swarm]="${dk_dir}/swarm"
        [common]="${dk_dir}/common"
        [secrets]="${dk_dir}/common/secrets"
        [example]="${dk_dir}/common/docker-example.env"
        [env]="${dk_dir}/common/.docker.env"
    )
    dk_dir="${HOME}/docker"
    declare -Agx dk_build; dk_build=(
        [path]="${dk[build]}"
        [data]="${dk[build]}/appdata"
        [conf]="${dk[build]}/configs"
        [fast]="${dk[build]}/runtime"
        [file]="compose.yml"
    )
    echo -e "DEBUG: 'dk_build' [00] \n
        dk_build[path]: '${dk_build[path]}' \n
        dk_build[conf]: '${dk_build[conf]}' \n
        dk_build[data]: '${dk_build[data]}' \n
        dk_build[fast]: '${dk_build[fast]}' \n
        dk_build[file]: '${dk_build[file]}' \n"
    declare -Agx dk_local; dk_local=(
        [path]="${dk[local]}"
        [data]="${dk[local]}/appdata"
        [conf]="${dk[local]}/configs"
        [fast]="${dk[local]}/runtime"
        [file]="compose.yml"
    )
    declare -Agx dk_swarm; dk_swarm=(
        [path]="${dk[swarm]}"
        [data]="${dk[swarm]}/appdata"
        [conf]="${dk[swarm]}/configs"
        [fast]="${dk[swarm]}/runtime"
        [file]="compose.yml"
    )

    ## configuration types
    dk_scopes=("build" "local" "swarm")

    ## docker common path
    export dk_common="${dk_dir}/common"

    ## docker secrets path
    export dk_secrets="${dk_common}/secrets"

    export dk_env_example="${dk_common}/docker-example.env"
    export dk_env_file="${dk_secrets}/.docker.env"
    export compose_filename="compose.yml"

    ## alias to easily source this file
    dk_fnc_file="${dk_common}/dk_functions.sh"
    dk_script_dir="$(dirname "${dk_fnc_file}")"
    dk_fnc_file="${dk_script_dir}/${dk_fnc_file##*/}"
    # if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    #     export dk_fnc_file="${BASH_SOURCE[0]}"
    # fi
    alias dkfnc='source ${dk_fnc_file}'

    ## docker build folders
    export build_path="${dk_dir}/build"
    export build_appdata="${build_path}/appdata"
    export build_configs="${build_path}/configs"
    export build_runtime="${build_path}/runtime"
    export build_compose="compose.yml"

    ## docker compose local
    export local_path="${dk_dir}/local"
    export local_appdata="${local_path}/appdata"
    export local_configs="${local_path}/configs"
    export local_runtime="${local_path}/runtime"
    export local_compose="compose.yml"

    ## docker swarm configs folders
    export swarm_path="${dk_dir}/swarm"
    export swarm_appdata="${swarm_path}/appdata"
    export swarm_configs="${swarm_path}/configs"
    export swarm_runtime="${swarm_path}/runtime"
    export swarm_compose="compose.yml"

    # dk_appdata=("${build_appdata}" "${local_appdata}" "${swarm_appdata}")
    # dk_configs=("${build_configs}" "${local_configs}" "${swarm_configs}")

    ## assign docker UID and GID variables
    dk_uid=$(id -u "${dk_usr:-docker}"); export dk_uid #&& echo "DEBUG: docker UID: '${dk_uid}'"
    dk_gid=$(id -g "${dk_usr:-docker}"); export dk_gid #&& echo "DEBUG: docker GID: '${dk_gid}'"

    ## folder and file permissions
    perms_cert='a-rwx,u=rwX,g=,o='; export perms_cert # 600 # -rw-rw----
    perms_conf='a-rwx,u+rwX,g=rwX,o=rX'; export perms_conf # 664 # -rw-rw-r--
    perms_data='a-rwx,u+rwX,g=rwX,o='; export perms_data # 660 # -rw-rw----
    perms_main='a=rwX,o-w'; export perms_main # 775 # -rwxrwxr-x

    # might want to consolidate these with scope config vars above
    set_scope_vars(){
        # echo "DEBUG: 'set_scope_vars' [00] <config_type> '${config_type}'"
        # Check if config_type is empty and if the first element of operands is one of the valid scopes
        if [[ " ${dk_scopes[*]} " =~ ${opds[0]} ]]; then
            # If the condition is true, set config_type to the first element of opds
            config_type="${opds[0]}"
            # Remove the first element from the opds array using array slicing
            opds=("${opds[@]:1}")
        fi
        # echo "DEBUG: 'set_scope_vars' [01] <config_type> '${config_type}' <opds> '${opds[*]}'"
        case "${config_type}" in
            "build" )
                export appdata_path="${build_appdata}"
                export configs_path="${build_configs}"
                export runtime_path="${build_runtime}"
                export compose_file="${build_compose}"
                ;;
            "local" )
                export appdata_path="${local_appdata}"
                export configs_path="${local_configs}"
                export runtime_path="${local_runtime}"
                export compose_file="${local_compose}"
                ;;
            "swarm" )
                export appdata_path="${swarm_appdata}"
                export configs_path="${swarm_configs}"
                export runtime_path="${swarm_runtime}"
                export compose_file="${swarm_compose}"
                ;;
            * )
                msg_error "INVALID CONFIG TYPE ${cyn:-}'${config_type}'${def:-}" "Please inform the script maintainer."
                return
                ;;
        esac
        # echo "DEBUG: 'set_scope_vars' [02] <appdata_path> '${appdata_path}' <configs_path> '${configs_path}'"
        }

    ## check if sudo is needed for some commands used in these custom docker functions
    if [ "$(id -u)" -ne 0 ]; then var_sudo="$(command -v sudo 2>/dev/null)"; else var_sudo=""; fi #unset var_sudo; fi

#################### message functions ####################

    ## source ${HOME}/.bash_env if it exists and has not already been sourced
    if [ -z "${def:-}" ]; then src="${HOME}/.bash_env"; if [ -f "${src}" ]; then . "${src}"; fi; fi

    msg_alert(){ echo -e "${orn:-} ALERT ${def:-}>> ${ylw:-}${1:-HERE_BE_DRAGONS}${def:-} >> ${2:-this_action_is_final}${def:-} <<"; echo; return; }
    msg_error(){ echo -e "${red:-} ERROR ${def:-}>> ${mgn:-}${1:-INVALID_ENTRY}${def:-} >> ${2:-please_notify_the_script_author}${def:-} <<"; echo; return; }
    msg_info(){ echo -e "${cyn:-} INFO ${def:-}>> ${blu:-}${1:-ACTION_INCOMPLETE}${def:-} >> ${2:-something_is_not_quite_right}${def:-} <<"; echo; return; }
    msg_failure(){ echo -e "${red:-} FAILURE ${def:-}>> ${mgn:-}${1:-OPERATION_FAILURE}${def:-} >> ${2:-operation_failed}${def:-} <<"; echo; return; }
    msg_success(){ echo -e "${grn:-} SUCCESS ${def:-}>> ${mgn:-}${1:-OPERATION_SUCCESS}${def:-} >> ${2:-operation_succeeded}${def:-} <<"; echo; return; }
    msg_warning(){ echo -e "${ylw:-} WARNING ${def:-}>> ${mgn:-}${1:-OPERATION_UNKNOWN}${def:-} >> ${2:-please_check_valid_option_flags}${def:-} <<"; echo; return; }

#################### general directory functions ####################

    fnc_dir_create(){ ## USAGE: fnc_dir_create <directory> <permissions>
        # ${var_sudo:-} install -o "${dk_uid}" -g "${dk_gid}" -m "$2" -d "$1"; fi; }
        # echo "DEBUG: 'fnc_dir_create' [00] <arguments> '${*}'"
        if [[ ! -d "${1}" ]]; then perms_conf="${2}"; fnc_install_cmd "-d ${1}"; fi; }

    fnc_find_and_move_file(){ ## USAGE: fnc_find_and_move_file <filename> <target_dir> [search_dir]
        local target_file="${1}"
        local target_dir="${2}"
        local search_dir="${3:-.}"
        local find_results; find_results=$(find "${search_dir}" -type f -iname "${target_file}")
        if [[ -n "${find_results}" ]]; then
            ${var_sudo:-} mv "${find_results}" "${target_dir}"
            msg_success "File found" "Moved ${target_file} to ${target_dir}"
        else msg_failure "File not found" "${target_file} not found in ${search_dir} or subdirectories"
        fi
    }

    fnc_install_cmd(){ ## USAGE: fnc_install_cmd <source> <target>
        # echo "DEBUG: 'fnc_install_cmd' [00] <arguments> '${*}'"
        ${var_sudo:-} install -o "${dk_uid}" -g "${dk_gid}" -m "${perms_conf}" ${1} ${2}; }

    ## separate option from operands
    # fnc_strip_option(){ local list="$1[@]"; local apps=( "${!list}" ); apps=( "${apps[@]:1}" ); } # remove first arg
    fnc_extract_option(){ ## USAGE: fnc_extract_option $@
        # echo "DEBUG: 'fnc_extract_option' [00] <arguments> '${*}'"
        ## initialize arrays
        local arguments=("$@")
        local operands=()
        local opds=()
        local options=()
        local optn=()
        ## iterate through arguments
        # echo -e "\n fnc_extract_option arguments: $*"
        for arg in "${arguments[@]}"; do
        # for arg in $*; do
            if [[ ${arg} = "." ]]; then
                continue
            elif [[ ${arg} == -?* ]]; then
                options+=("${arg}")
            else
                operands+=("${arg}")
            fi
        done
        ## validate option count
        if [[ ${#options[@]} -gt 1 ]]; then
            msg_error "More than one option found." "Check \`--help\` for usage syntax."
            return 1
        else ## export arrays
            optn=("${options[@]}") #echo "optn: ${options[*]}"
            opds=("${operands[@]}") #echo "opds: ${operands[*]}"
        fi
        # echo "DEBUG: 'fnc_extract_option' [01] <optn> '${optn[*]}' <opds> '${opds[*]}'"
        # fnc_extract_option(){
        #     local opt
        #     while getopts ":abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ" opt "$@"; shift "$((OPTIND-1))"; do echo; done
        }

    ## Download file if it doesn't exist already, then optionally create a symlink
    fnc_file_download(){ ## USAGE: fnc_file_download <url> <filepath> [symlink]
        # echo -e "\n fnc_file_download opds: $*"
        fnc_extract_option "$@"
        local file_url="${opds[0]}" #echo "file_url: $file_url"
        local filename="${opds[1]}" #echo "filename: $filename"
        local filelink="${opds[2]}" #echo "filelink: $filelink"
        # local file_url="${1}"
        # local filename="${2}"
        # local filelink="${3}"
        # echo -e " DEBUG: 'fnc_file_download' file_url: '${file_url}'"
        # echo -e " DEBUG: 'fnc_file_download' filename: '${filename}'"
        # echo -e " DEBUG: 'fnc_file_download' filelink: '${filelink}'"

        if [[ -f "${filename}" ]]; then
            case "${optn[0]}" in
                "-f" | "--force" )
                    local var_force="-N" # local var_force="-qN"
                    # wget -N "$file_url" -O "${filename}"
                    ;;
                * )
                    # msg_info "File \`${filename}\` already exists." "Use option \`--force\` to overwrite."
                    return
                    ;;
            esac
        elif ! wget "${var_force}" --show-progress "${file_url}" -O "${filename}"; then
            msg_failure "DOWNLOAD FAILED" "check url: ${file_url}"
            return 1
        fi
        if [ -n "${filelink}" ]; then
            fnc_install_cmd "${filename}" "${filelink}"
            # ${var_sudo:-} install -o "${dk_uid}" -g "${dk_gid}" -m "${perms_conf}" "${filename}" "${filelink}"
        fi
        }

#################### initial setup functions ####################

    fnc_symlink_create(){ ## USAGE: fnc_symlink_create <symlink> <target>
        # echo "DEBUG: 'fnc_symlink_create' [00] <arguments> '${*}'"
        local symlink="$1"
        local target="$2"
        if [ ! -f "${symlink}" ]; then ln -s "${target}" "${symlink}"; fi
        }

    fnc_initial_setup(){ ## USAGE: fnc_initial_setup
        ## create docker data and config directories if they do not exist
        fnc_dir_create "${dk_dir}" "${perms_data}"
        ## if necessary, create ${HOME}/docker symlink and update $dk_dir
        if [[ "${dk_dir}" != "${HOME}/docker" ]]; then
            fnc_symlink_create "${HOME}/docker" "${dk_dir}"
            dk_dir="${HOME}/docker"
        fi
        ## create docker data and config directories if they do not exist
        fnc_dir_create "${dk_common}" "${perms_data}"
        fnc_dir_create "${dk_secrets}" "${perms_data}"
        fnc_dir_create "${local_appdata}" "${perms_data}"
        fnc_dir_create "${local_configs}" "${perms_conf}"
        fnc_dir_create "${swarm_appdata}" "${perms_data}"
        fnc_dir_create "${swarm_configs}" "${perms_conf}"

        ## move dk_functions.sh to ${HOME}/docker/shared
        fnc_find_and_move_file "dk_functions.sh" "${dk_common}"

        ## download .bash_env if it does not exist
        if [[ ! -f "${HOME}/.bash_env" ]]; then
            curl -s 'https://raw.githubusercontent.com/QNAP-HomeLAB/docker-scripts/master/.bash_env' > "${HOME}/.bash_env"
            # fnc_file_download "https://raw.githubusercontent.com/drauku/bash-scripts/master/.bash_env" "${HOME}/.bash_env"
        fi

        fnc_file_download "https://raw.githubusercontent.com/drauku/bash-scripts/master/docker.env.example" "${dk_env_example}" "${dk_env_file}"
        ## add ${HOME}/.dk_env to ${HOME}/.profile if it does not exist
        if ! grep -q "${dk_env_file}" "${HOME}/.profile"; then
            echo "src=${dk_env_file}; if [ -f \"\${src}\" ]; then . \"\${src}\"; fi" >> "${HOME}/.profile"
        fi

        ## create the $HOME/.dk_fnc symlink if it does not exist
        fnc_symlink_create "${HOME}/.dk_fnc" "${dk_fnc_file}"

        ## add ${HOME}/.dk_fnc to ${HOME}/.profile if it does not exist
        if ! grep -q "${dk_fnc_file}" "${HOME}/.profile"; then
            echo "src=${dk_fnc_file}; if [ -f \"\${src}\" ]; then . \"\${src}\"; fi" >> "${HOME}/.profile"
        fi

        ## create blank .docker.env if download + symlink operation fails
        if [[ ! -f "$dk_env_file" ]]; then
            fnc_install_cmd "/dev/null" "$dk_env_file"
            # ${var_sudo:-} install -o "${dk_uid}" -g "${dk_gid}" -m "${perms_data}" /dev/null "$dk_env_file"
        fi
        }

    ## initial setup task check
    if [[ ! -f "${dk_fnc_file}" ]]; then fnc_initial_setup; fi

    # initialize(){
        fnc_file_download "${git_url_common}/color_codes.conf" "${HOME}/.bash_env"
        fnc_file_download "${git_url_common}/dk_vars.example" "${dk_env_example}" "${dk_env_file}"

    #     # if [ ! -f "$filename" ]; then
    #     #     if ! wget "$file_url" -O "$filename"
    #     #     then msg_failure "Failed to download" "$file_url"; return 1
    #     #     fi
    #     # fi

    #     ## create blank .docker.env if download fails
        # if [ ! -f "${dk_env_file}" ]; then ${var_sudo:-} install -o "${dk_uid}" -g "${dk_gid}" -m "${perms_data}" /dev/null "$dk_env_file"; fi
        if [ ! -f "${dk_env_file}" ]; then
            fnc_install_cmd "/dev/null" "$dk_env_file"
            msg_warning "INITIAL CHECKS" "No docker .env file found, created blank \`${dk_env_file}\`."
        fi
    # }

    # fnc_check_app(){ if test -z "$1"; then msg_warning "No application name specified." "Application name required."; return; fi; }
    #     # echo; echo " > Application name must be specified. Nothing to do."; echo; return; fi; }

#################### syntax verification functions ####################
    fnc_verify_action(){ ## USAGE: fnc_verify_action <message>
        msg_alert "" "$1"
        while read -r -p " >> CONTINUE? y/[N] << " input; do
            echo
            case "${input:-N}" in
                [yY]|[yY][eE][sS] )
                    return 0
                    ;;
                [nN]|[nN][oO] )
                    return 1
                    ;;
                * )
                    msg_failure "Invalid input" "Please enter 'y' or 'n'"
                    return 1
                    ;;
            esac
        done
        }

    fnc_check_dir(){
        if test ! -d "$1"; then
            msg_warning "Docker container directory does not exist." "Use \`${cyn:-}dcf $1${def:-}\` / \`${cyn:-}dwf $1${def:-}\` to create."
            return
        fi
        }
        # echo -e " > \`$1\` docker container directory does not exist <"; return 1; fi; }

    fnc_appname_validate(){
        # fnc_appname_validate "$1"
        if test -z "$1"; then
            msg_warning "No application name specified." "Application name required."
            return 1
        elif [[ ${1:0:1} =~ ^[_-]+$ ]] || [[ ! ${1} =~ ^[a-zA-Z0-9_-]+$ ]]; then
            msg_warning "Invalid application name." "Only alphanumeric characters, underscores, and hyphens allowed."
            return 1
        elif [[ " ${dk_scopes[*]} " =~ ${1} ]]; then
            msg_warning "Invalid application name." "Name used must not be one of the following: \`${cyn:-}${dk_scopes[*]}${def:-}\`."
            return 1
        else return 0 # container name only contains valid name and characters
        fi
        }

    fnc_verify_swarm_active(){
        if docker info | grep -q "Swarm: inactive"; then
            msg_warning "Docker swarm does not exist." "Use \`${cyn:-}dwinit${def:-}\` to create."
            return 1
        elif docker info | grep -q "Swarm: active"; then
            return 0
        fi
        }

    ## TODO: function code suggested by Cody AI but is NOT YET VERIFIED TO WORK
    # validate_ip4-codyai() {
    #     # Matches 0.0.0.0 to 255.255.255.255
    #     ip_regex='^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'

    #     # Extract from subnet variable
    #     ip="${net_prefix_docker_socket%/*}"
    #     mask="${net_prefix_docker_socket#*/}"
    #     if [[ ! $ip =~ $ip_regex ]]; then
    #         echo "Invalid IP: $ip"
    #         return 1
    #     fi

    #     if [[ $mask -lt 0 ]] || [[ $mask -gt 32 ]]; then
    #         echo "Invalid mask: $mask"
    #         return 1
    #     fi

    #     # Convert mask to binary string
    #     mask_bin=$(echo "obase=2; $mask" | bc)

    #     # Prefix with 1's, remaining with 0's
    #     mask_bin=$(printf "%032d" "$mask_bin")

    #     # Convert to hex
    #     mask_hex=$(echo "ibase=2;$mask_bin" | bc)

    #     # Get network and broadcast addresses
    #     network_hex=$(echo "ibase=16; $ip & $mask_hex" | bc)
    #     broadcast_hex=$(echo "ibase=16; $ip | $mask_hex" | bc)

    #     # Convert hex back to decimal IP
    #     network_ip=$(echo "obase=A;$network_hex" | bc)
    #     broadcast_ip=$(echo "obase=A;$broadcast_hex" | bc)

    #     if [[ $ip != $(echo "$network_ip <= $ip <= $broadcast_ip" | bc) ]]; then
    #         echo "IP $ip out of subnet range"
    #         return 1
    #     fi
    #     }
    ## TODO: function code suggested by ChatGPT 3.5, but not yet verified
    # validate_ip4-chatgpt() {
    #     local ip_regex='^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])'

    #     if [[ -z $net_prefix_docker_socket ]]; then
    #         echo "Error: net_prefix_docker_socket is not provided."
    #         return 1
    #     fi

    #     local ip="${net_prefix_docker_socket%/*}"
    #     local mask="${net_prefix_docker_socket#*/}"

    #     if [[ ! $ip =~ $ip_regex ]]; then
    #         echo "Invalid IP: $ip"
    #         return 1
    #     fi

    #     if [[ $mask -lt 0 || $mask -gt 32 ]]; then
    #         echo "Invalid mask: $mask"
    #         return 1
    #     fi

    #     ## the code line just below uses 'bitwise' operators, and the `<<` doesn't work in this shell
    #     # local mask_bin=$((2**$mask - 1 << (32 - $mask)))
    #     ## rewritten without 'bitwise' operators:
    #     local mask_bin=$(( ((1 << $mask) - 1) * (1 << (32 - $mask)) ))
    #     local network_ip=$(( $ip & $mask_bin ))
    #     local broadcast_ip=$(( $ip | ~$mask_bin ))

    #     if [[ $ip -lt $network_ip || $ip -gt $broadcast_ip ]]; then
    #         echo "IP $ip out of subnet range"
    #         return 1
    #     fi
    # }

#################### general docker functions ####################

    ## TODO: compare this function with the equivalent function from /docker/scripts/docker_configs_list.sh
    fnc_configs_list(){ ## USAGE: fnc_configs_list <config_type>
        fnc_extract_option "$@"
        set_scope_vars "${config_type}"
        # Initialize an empty array
        config_list=()
        ## find config dirs or files
        case "${optn[0]}" in
            -d|--dir*|--folder)
                # Use a while loop to read each directory into the array
                while IFS= read -r -d '' dir; do config_list+=("$dir")
                done < <(find "${configs_path}" -maxdepth 1 -type d -not -path '/.*' -print0)
                # Print the contents of the array for verification
                printf '%s\n' "${config_list[@]}"
                ## the below code doesn't work with old versions under bash v4
                # config_list=($(find "${configs_path}" -maxdepth 1 -type d -not -path '/.*')) # old versions of bash don't support mapfile
                # mapfile -t config_list < <(find "${configs_path}" -maxdepth 1 -type d -not -path '*/\.*')
                ;;
            * )
                # Use a while loop to read each file into the array
                while IFS= read -r -d '' file; do config_list+=("$file")
                done < <(find "${configs_path}" -maxdepth 2 -type f -name "${compose_file}" -print0)
                # Print the contents of the array for verification
                printf '%s\n' "${config_list[@]}"
                ## the below code doesn't work with old versions under bash v4
                # config_list=($(find "${configs_path}" -maxdepth 2 -type f -name "${compose_file}" | sed 's|/[^/]$||')) # old versions of bash don't support mapfile
                # mapfile -t config_list < <(find "${configs_path}" -maxdepth 2 -type f -name "${compose_file}" | sed 's|/[^/]*$||')
                ;;
        esac
        ## print config list
        if [[ "${#config_list[@]}" -eq 0 ]]; then
            msg_warning "No ${config_type} configs found." "Use \`dcf/dwf <appname>\` to create one."
            return
        else
            echo -e " > DOCKER CONFIG LIST FOR \`${config_type}\` CONTAINERS <\n ${config_list[*]}"
        fi
        }
    alias dbg="fnc_configs_list build"
    alias dcg="fnc_configs_list local"
    alias dlg="fnc_configs_list local"
    alias dwg="fnc_configs_list swarm"

    dk_compose_config(){ ## "tests" a compose file and displays the dockerfile with variables inserted
        fnc_extract_option "$@"
        set_scope_vars "${config_type}"
        stack="${opds[0]}"
        if ! fnc_appname_validate "${stack}"; then return; fi
        docker compose -f "${configs_path}/${stack}/${compose_file}" config
        }
    # alias dkconf="dk_compose_config"
    alias dct="dk_compose_config local" # docker compose "test"
    alias dwt="dk_compose_config swarm" # docker compose "test"

    dk_compose_edit(){ ## opens the stack compose file in nano, or your editor of choice
        fnc_extract_option "$@"
        set_scope_vars "${config_type}"
        stack="${opds[0]}"
        if ! fnc_appname_validate "${stack}"; then return; fi
        nano "${configs_path}/${stack}/${compose_file}"
        }
    # alias dkedit="dk_compose_edit"
    alias dce="dk_compose_edit local"
    alias dwe="dk_compose_edit swarm"

    dk_compose_logs(){ ## USAGE: dk_compose_logs <config_scope> <stack_name>
        fnc_extract_option "$@"
        # local config_type="${opds[0]}"
        set_scope_vars "${config_type}"
        stack="${opds[0]}"
        # (cd "${configs_path}/${stack}" && docker compose logs -f)
        (cd "${configs_path}/${stack}" && docker logs -tf --tail="50" "${stack}")
        }
    alias dwlogs="dk_compose_logs swarm"
    alias dll="dk_compose_logs local"

    ## docker image list function
    dk_images_list(){ docker images; }
    alias dkil="dk_images_list"

    ## docker network list function
    dk_network_list(){ docker network ls; echo; }
    alias dknl="dk_network_list"

    ## docker volume list function
    dk_volumes_list(){ docker volumes ls; }
    alias dkvl="dk_volumes_list"

    ## docker common list functions
    dk_list_common(){ echo "ls ${dk_common}"; /usr/bin/ls "${dk_common}"; echo; }
    alias dklc="dk_list_common"

    dk_cd_common(){ cd "${dk_common}/$1" || echo; return; }
    alias dkc="dk_cd_common"

    ## docker secrets list functions
    dk_list_secrets(){ echo "ls ${dk_secrets}"; /usr/bin/ls "${dk_secrets}"; echo; }
    alias dkls="dk_list_secrets"

    dk_cd_secrets(){ cd "${dk_secrets}/$1" || echo; return; }
    alias dks="dk_cd_secrets"

    ## docker local list functions
    # TODO: copy configs list function from old scripts
    dk_list_local_appdata(){ echo "ls ${local_appdata}"; /usr/bin/ls "${local_appdata}"; echo; }
    alias dlca="dk_list_local_appdata"
    alias dlla="dk_list_local_appdata"

    dk_list_local_configs(){ echo "ls ${local_configs}"; /usr/bin/ls "${local_configs}"; echo; }
    alias dlcg="dk_list_local_configs"
    alias dllg="dk_list_local_configs"

    # dk_local_appdata(){ cd "${local_appdata}/$1" 2>/dev/null || echo; return; }
    dk_local_appdata(){ cd "${local_appdata}/$1" || return; }
    alias dkla="dk_local_appdata"

    dk_local_configs(){ cd "${local_configs}/$1" || return; }
    alias dklg="dk_local_configs"
    alias dkl="dk_local_configs"

    ## docker swarm list functions
    # TODO: copy configs list function from old scripts
    dk_list_swarm_appdata(){ echo "ls ${swarm_appdata}"; /usr/bin/ls "${swarm_appdata}"; echo; }
    alias dlwa="dk_list_swarm_appdata"

    dk_list_swarm_configs(){ echo "ls ${swarm_configs}"; /usr/bin/ls "${swarm_configs}"; echo; }
    alias dlwg="dk_list_swarm_configs"

    dk_swarm_appdata(){ cd "${swarm_appdata}/$1" || return; }
    alias dkwa="dk_swarm_appdata"

    dk_swarm_configs(){ cd "${swarm_configs}/$1" || return; }
    alias dkwg="dk_swarm_configs"
    alias dkw="dk_swarm_configs"

    # vpn and ip check functions
    dl_cmd_check(){
        if [ -n "$(which curl)" ]; then
            dl_cmd="curl"
        elif [ -n "$(which wget)" ]; then
            dl_cmd="wget -qO-"
        else
            echo "Neither curl nor wget found. Exiting."
            return 1
        fi
        }

    vpncheck(){ dl_cmd_check; echo " > Host IP: $("${dl_cmd}" ifconfig.me)" && echo "Container IP: $(docker container exec -it "${*}" "${dl_cmd}" ipinfo.io)"; }

    ctipcheck(){ dl_cmd_check; echo " > Container IP: $(docker container exec -it "${*}" "${dl_cmd}" ipinfo.io)"; }
    alias ctip="ctipcheck"

    ctport(){ docker container exec -it "${1}" netstat -tulpn; }

    check_vpn_curl(){ echo "     Host IP: $(curl ifconfig.me)" && echo "Container IP: $(docker container exec -it "${1}" curl ipinfo.io/ip)"; }
    alias vpncheckc="check_vpn_curl"
    check_vpn_wget(){ echo "     Host IP: $(wget -qO- ifconfig.me)" && echo "Container IP: $(docker container exec -it "${1}" wget -qO- ipinfo.io/ip)"; }
    alias vpncheckw="check_vpn_wget"
    alias vpncheck="vpncheckw"

    check_ctip_curl(){ echo "Container IP: $(docker container exec -it "${1}" curl ipinfo.io)"; }
    alias ipcheckc="check_ctip_curl"
    check_ctip_wget(){ echo "Container IP: $(docker container exec -it "${1}" wget -qO- ipinfo.io)"; }
    alias ipcheckw="check_ctip_wget"
    alias ctip="ipcheckw"

    alias dkex="docker exec -it"

    ## verify website function
    # verify_url(){ if wget --spider "${1}" 2>/dev/null; then echo "Website exists."; else echo "Website is not available."; fi; } ## does not seem to work for local websites
    verify_url(){ echo " '$1' status code: $(curl -s -o /dev/null --head -w "%{http_code}" "$1" --max-time 5)"; }
    alias webcheck="verify_url"

#################### docker permissions update functions ####################

    ## TODO: PERMISSIONS CODEBLOCK DOES NOT TAKE INTO ACCOUNT SCOPE PATHS

    # update_file_permissions(){ ## USAGE: update_file_permissions [option] <permissions> <file list>
    #     fnc_extract_option "${@}"
    #     perms="${opds[0]}"; shift
    #     files_list=("$@")

    #     case "${1}" in
    #         -* )
    #             optn="${1}"; shift
    #             case "${optn}" in
    #                 "-a" | "--all")
    #                     files_dir="${configs_path}"
    #                     ;;
    #                 * )
    #                     msg_error "Invalid option: ${optn}"
    #                     return 1
    #                     ;;
    #             esac
    #             ;;
    #         * )
    #             files_dir="${configs_path}/${1}"
    #             ;;
    #     esac
    #     for file in "${files_list[@]}"; do
    #         ${var_sudo:-} find "${files_dir}" -iname "${file}" -type f -exec chmod "${perms}" {} +
    #     done
    #     }
    ## files_list=("acme.json" "*.crt" "*.key" "*.pub" "*.ppk" "*.pem" )
    # update_file_permissions "${perms_cert}" "acme.json" "*.crt" "*.key" "*.pub" "*.ppk" "*.pem"

    set_file_permissions(){ ${var_sudo:-} find "${files_dir}" -iname "${2}" -type f -exec chmod "${1}" {} +; }

    dk_file_permissions(){ ## USAGE: dk_file_permissions [option] <stack_name>
        echo "DEBUG: 'dk_file_permissions' [00] <arguments> '${*}'"
        fnc_extract_option "${@}"
        set_scope_vars "${config_type}"
        echo "DEBUG: 'dk_file_permissions' [01] <config_type> '${config_type}' <optn> '${optn[*]}' <opds> '${opds[*]}'"
        for stack in "${opds[@]}"; do
            if ! fnc_appname_validate "${stack}"; then return; fi
            case "${optn[0]}" in
                "-a" | "--all" )
                    files_dir="${configs_path}"
                    ;;
                * )
                    files_dir="${configs_path}/${stack}"
                    ;;
            esac
            # update restricted access file permissions to 600
            files_restricted=("acme.json" "*.crt" "*.key" "*.pub" "*.ppk" "*.pem")
            for file in "${files_restricted[@]}"; do
                set_file_permissions "${perms_cert}" "${file}"
            done
            # update limited access file permissions to 660
            files_limited=(".conf" "*.env" ".log" "*.secret")
            for file in "${files_limited[@]}"; do
                set_file_permissions "${perms_data}" "${file}"
            done
            ## update general access file permissions to 664
            # files_general=("*.yml" "*.yaml" "*.toml")
            # for file in "${files_general[@]}"; do
            #     set_file_permissions "${perms_conf}" "${file}"
            # done
        done
        }

    set_owner(){ ${var_sudo:-} chown -R "${1}" "${2}"; }

    set_perms(){ ${var_sudo:-} chmod -R "${1}" "${2}"; }

    dk_folder_permissions(){ ## USAGE: dk_folder_permissions [option] <file list>
        # echo "DEBUG: 'dk_folder_permissions' [00] <arguments> '${*}'"
        fnc_extract_option "$@"
        # echo "DEBUG: 'dk_folder_permissions' [01] <arguments> '${*}' <optn> '${optn[*]}' <opds> '${opds[*]}'"
        case "${optn[0]}" in
            "-a" | "--all" )
                ## update all docker folder ownership
                set_owner "${dk_uid}:${dk_gid}" "${dk_dir:?}"
                ## update appdata folder permissions
                dirs_list=("${local_appdata}" "${swarm_appdata}" "${dk_secrets}")
                for dir in "${dirs_list[@]}"; do
                    set_perms "${perms_data}" "${dir:?}"
                done # -rwXrwX---
                ## update config folder permissions
                dirs_list=("${dk_common}" "${local_configs}" "${swarm_configs}")
                for dir in "${dirs_list[@]}"; do
                    set_perms "${perms_conf}" "${dir:?}"
                done # -rwXrwXr-X
                ## update all docker folder permissions
                set_perms "${perms_conf}" "${dk_dir:?}"
                set_perms "${perms_data}" "${dk_dir:?}"
                ## update all docker file permissions
                dk_file_permissions --all
                echo -e " > \`ALL\` docker subdirectory and file permissions updated <"
                ;;
            * )
                for stack in "${opds[@]}"; do
                    if ! fnc_appname_validate "${stack}"; then return; fi
                    ## update specified stack folders permissions
                    appdata_dir="${appdata_path:?}/${stack}"
                    appconf_dir="${configs_path:?}/${stack}"
                    if [ -d "${appdata_dir:?}" ]; then
                        set_owner "${dk_uid}:${dk_gid}" "${appdata_dir:?}"
                        set_perms "${perms_data}" "${appdata_dir:?}"
                    else
                        msg_failure "DIRECTORY DOES NOT EXIST" "Unable to update ${cyn:-}\`${appdata_dir:?}\`${def:-} permissions"
                        return 1
                    fi
                    if [ -d "${appconf_dir:?}" ]; then
                        set_owner "${dk_uid}:${dk_gid}" "${appconf_dir:?}"
                        set_perms "${perms_conf}" "${appconf_dir:?}"
                    else
                        msg_failure "DIRECTORY DOES NOT EXIST" "Unable to update ${cyn:-}\`${appconf_dir:?}\`${def:-} permissions"
                        return 1
                    fi
                    dk_file_permissions "${stack}"
                    echo -e " > \`${stack}\` docker container subdirectory and file permissions updated <"
                    msg_success "UPDATED" "${cyn:-}\`${appdata_dir:?}\`${def:-} AND ${cyn:-}\`${appconf_dir:?}\`${def:-} folder and file permissions."
                    # echo -e "\n  ${ylw:-}UPDATED ${blu:-}${appdata_dir:?}/${mgn:-}${stack}${def:-} AND ${blu:-}${dk_local:?}/${mgn:-}${stack}${def:-} dk_folders AND FILE PERMISSIONS ${def:-}"
                done
                ;;
        esac
        }

    dk_permissions_update(){ ## USAGE: dk_permissions_update <scope>
        dirs_list=("${local_configs}" "${swarm_configs}")
        for dir in "${dirs_list[@]}"; do
            export configs_path="$dir"
            dk_folder_permissions "--all"
        done
        }
        alias dkp="dk_permissions_update"
        # TODO: make sure the called function checks $1 for valid scope
        # alias dcp="dk_folder_permissions local"
        # alias dwp="dk_folder_permissions swarm"

#################### dk_files and dk_folders ####################

    fnc_env_create(){
        # echo "DEBUG: 'fnc_env_create' [00] <arguments> '${*}'"
        fnc_extract_option "${@}"
        set_scope_vars "${opds[0]}"
        # echo "DEBUG: 'fnc_env_create' [01] <configs_path> '${configs_path}' <optn> '${optn[*]}' <opds> '${opds[*]}'"
        for stack in "${opds[@]}"; do
            if ! fnc_appname_validate "${stack}"; then return; fi
            case "${optn[0]}" in
                "-c" | "--copy" )
                    fnc_install_cmd "-c ${dk_env_file}" "${configs_path}/${stack}/.env"
                    # ${var_sudo:-} install -o "${dk_uid}" -g "${dk_gid}" -m "${perms_data}" "${dk_env_file}" "${configs_path}/${stack}/.env"
                    ;;
                "-d" | "--delete" | "-r" | "--remove" )
                    ${var_sudo:-} rm -f "${configs_path}/${stack}/.env"
                    ;;
                "-f" | "--force" )
                    # fnc_symlink_create will not create the symlink if it already exists
                    ln -s -f "${dk_env_file}" "${configs_path}/$stack/.env"
                    ;;
                * )
                    fnc_symlink_create "${configs_path}/$stack/.env" "${dk_env_file}"
                    # if [[ ! -f "${configs_path}/$1/.env" ]]; then
                    #     ln -s "$dk_env_file" "${configs_path}/$1/.env" # symlinks .env to .docker.env
                    # fi
                    ;;
            esac
        done
        }
    alias dcenv="fnc_env_create local"
    alias dwenv="fnc_env_create swarm"

    dk_folders_create(){
        # echo "DEBUG: 'dk_folders_create' [00] <arguments> '${*}' <optn> '${optn[*]}' <opds> '${opds[*]}'"
        # echo "DEBUG: 'dk_folders_create' [01] <configs_path> '${configs_path}' <appdata_path> '${appdata_path}'"
        for stack in "${opds[@]}"; do
            if ! fnc_appname_validate "${stack}"; then return; fi
            if [ ! -d "${appdata_path}/${stack}" ]; then
                fnc_dir_create "${appdata_path}/${stack}" "${perms_data}"
                msg_success "CREATED" " ${cyn:-}\`${appdata_path}/${stack}\`${def:-} appdata directory."
            else
                msg_info "FYI" " Folder ${cyn:-}\`${appdata_path:?}/${stack}}\`${def:-} already exists."
            fi
            if [ ! -d "${configs_path}/${stack}" ]; then
                fnc_dir_create "${configs_path}/${stack}" "${perms_conf}"
                fnc_env_create "${stack}"
                fnc_install_cmd "/dev/null" "${configs_path}/${stack}/${compose_file}"
                # ${var_sudo:-} install -o "${dk_uid}" -g "${dk_gid}" -m "${perms_conf}" /dev/null "${configs_path}/${stack}/${compose_file}"
                msg_success "CREATED" " ${cyn:-}\`${configs_path}/${stack}\`${def:-} configs directory and files."
            else
                msg_info "FYI" " Folder ${cyn:-}\`${configs_path:?}/${stack}}\`${def:-} already exists."
            fi
        done
        }

    # TODO: fix the deletion of docker_folders and docker_files
    dk_folders_delete(){
        echo "DEBUG: 'dk_folders_delete' [00] <arguments> '${*}' <optn> '${optn[*]}' <opds> '${opds[*]}'"
        for stack in "${opds[@]}"; do
            # if ! fnc_appname_validate "${stack}"; then return; fi
            if ! fnc_verify_action " ${orn:-}This will forcefully delete all ${cyn:-}\`${stack}\`${orn:-} application directories and files."; then return; fi
            if [ -d "${appdata_path:?}/${stack}" ]; then
                rm -rf "${appdata_path:?}/${stack}"
                msg_success "DELETED" " Folder ${cyn:-}\`${appdata_path:?}/${stack}\` ${def:-}and contents."
            else
                msg_warning "UHOH!" " Folder ${cyn:-}\`${appdata_path:?}/${stack}\` ${def:-}does not exists. Nothing to remove."
            fi
            if [ -d "${configs_path:?}/${stack}" ]; then
                rm -rf "${configs_path:?}/${stack}"
                msg_success "DELETED" " Folder ${cyn:-}\`${configs_path:?}/${stack}\`${def:-} and contents."
            else
                msg_warning "UHOH!" " Folder ${cyn:-}\`${configs_path:?}/${stack}\`${def:-} does not exists. Nothing to remove."
            fi
        done
        }

    # TODO: verify the scope is handled correctly
    dk_folder_actions(){
        # echo "DEBUG: 'dk_folder_actions' [00] <arguments> '${*}'"
        fnc_extract_option "$@"
        # echo "DEBUG: 'dk_folder_actions' [01] <optn> '${optn[*]}' <opds> '${opds[*]}'"
        set_scope_vars "${opds[0]}"
        # echo "DEBUG: 'dk_folder_actions' [03] <appdata_path> '${appdata_path}' <configs_path> '${configs_path}'"
        # if [ "${config_type}" == "${opds[0]}" ]; then opds=("${opds[@]:1}"); fi # remove config type from opds
        # echo "DEBUG: 'dk_folder_actions' [02] <optn> '${optn[*]}' <opds> '${opds[*]}'"
        if test -n "${optn[0]}"; then
            case "${optn[0]}" in
                "-c" | "--create" )
                    dk_folders_create "${opds[@]}"
                    ;;
                "-d" | "--delete" )
                    dk_folders_delete "${opds[@]}"
                    ;;
                "-r" | "--remove" )
                    dk_folders_delete "${opds[@]}"
                    ;;
                * )
                    msg_failure "INVALID OPTION '${optn[0]}' USED" "Only '-c' or '-d' or '-r' options are allowed"
                    ;;
            esac
        else dk_folders_create "${opds[@]}"
        fi
        }
        alias dcf='dk_folder_actions local'
        alias dwf="dk_folder_actions swarm"

#################### docker download functions ####################

    fnc_check_git(){
        if ! command -v git &> /dev/null; then
            msg_failure "GIT IS NOT INSTALLED" "Please install \`git\` and try again."
            return 1
        fi
        }

    # TODO: incorporate $git_url_local and $git_url_swarm to download function here for configs downloading
    fnc_download_config_template(){ ## USAGE: fnc_download_config_template [config_type] [stack_name]
        if ! fnc_check_git; then return; fi
        fnc_extract_option "$@"
        set_scope_vars "${config_type}"
        if [ ! -d "${configs_path:?}/${compose_file}" ]; then
            fnc_dir_create "${compose_file}"
        fi
        case ${config_type} in
            "local" )
                git clone "${git_url_local}/${stack}" "${configs_path}/${stack}"
                ;;
            "swarm" )
                git clone "${git_url_swarm}/${stack}" "${configs_path}/${stack}"
                ;;
            * )
                msg_failure "INVALID OPTION '${config_type}' USED" "Only 'local' or 'swarm' options are allowed"
        esac
        }
    alias dlpull='fnc_download_config_template local'
    alias dwpull='fnc_download_config_template swarm'

#################### docker network functions ####################

    dk_net_verify(){ docker network ls -q --filter name="$1"; }

    dk_net_delete(){
        local net_name="${1}"; shift
        # verify_action " > This will forcefully delete the \`${net_name}\` docker network. Proceed? (y)es / [n]o"
        if [ "$(dk_net_verify "${net_name}")" ]; then
            docker network rm "${net_name}"
        else
            msg_failure "FAILURE" "Unable to delete the \`${cyn:-}${net_name}${def:-}\` network, it does not exist."
        fi
        }

    # TODO: verify the scope is handled correctly
    dk_net_create(){ ## USAGE: dk_net_create [scope] [driver] [network_name] (options)
        if [ "$#" -lt 3 ]; then msg_error "Invalid options" "Expected syntax: ${cyn:-}dk_net_create <scope> <driver> <network_name> [options]${def:-}"; return; fi
        local scope="${1}"; shift
        local driver="${1}"; shift
        local network_name="${1}"; shift
        local net_options="${*}"
        docker network create --opt "encrypted" --scope "${scope}" --driver "${driver}" --subnet "${net_prefix_docker_socket}.0/24" --gateway "${net_prefix_docker_socket}.254" --attachable "${net_options}" "${network_name}"
        }
    alias dkln="dk_net_create local bridge"
    alias dkwn="dk_net_create swarm overlay"

    # TODO: re-write to create network based on passed vars instead of scope only
    dk_net_setup(){ ## USAGE: dk_net_setup [scope]
        # if [ "$#" -lt 1 ]; then msg_error "Invalid options" "Expected syntax: ${cyn:-}dk_net_setup <scope>${def:-}"; return; fi
        local scope="${1}"
        declare -gx net_docker_socket; net_docker_socket=(
            [0]="docker_socket"  # name
            [1]="${scope}"       # scope
            [2]="${driver}"      # driver
            [3]="172.27.20.0/24" # subnet
            [4]="172.27.20.254"  # gateway
            [5]="--attachable --internal"   # options
        )
        declare -gx net_internal_only; net_internal_only=(
            [0]="internal_only"  # name
            [1]="${scope}"       # scope
            [2]="${driver}"      # driver
            [3]="172.27.21.0/24" # subnet
            [4]="172.27.21.254"  # gateway
            [5]="--attachable --internal"   # options
        )
        local net_name=(
            [0]="docker_socket"
            [1]="internal_only"
            [2]="reverse_proxy"
            [3]="external_edge"
            )
        # local net_prefix=(
        #     [0]="172.27.20" # docker_socket network
        #     [1]="172.27.21" # internal_only network
        #     [2]="172.27.22" # external_edge network
        #     [3]="172.27.23"
        #     [4]="172.27.24" # reverse_proxy network
        #     [5]="172.27.25"
        #     [6]="10.27.21" # swarm "ingress" network
        #     [7]="10.27.22" # swarm "gwbridge" network
        #     )
        # local net_prefix=(
        #     [0]="${net_prefix_docker_socket}"
        #     [1]="${net_prefix_internal_only}"
        #     [2]="${net_prefix_reverse_proxy}"
        #     [3]="${net_prefix_external_edge}"
        #     )

        # set scope specific net names and perform scope specific network creation
        case "${scope}" in
            "build" | "local" )
                scope="local"
                local net_name=(
                    [4]="docker_ipvlan"
                    [5]="docker_maclan"
                    )
                ;;
            "swarm" )
                local net_name=(
                    [4]="docker_gwbridge"
                    [5]="ingress"
                    )
                if [ ! "$(dk_net_verify "internal_only")" ]; then
                    if [ "$(dk_net_verify "docker_gwbridge")" ]; then
                        dk_net_delete "docker_gwbridge"
                        # dk_net_create "local" "bridge" "docker_gwbridge"
                        docker network create --opt "encrypted" --scope "${scope}" --driver "${driver}" --subnet "${net_prefix_docker_socket}.0/24" --gateway "${net_prefix_docker_socket}.254" --attachable "docker_gwbridge"
                    fi
                    if [ "$(dk_net_verify "ingress")" ]; then
                        dk_net_delete ingress;
                        docker network create --ingress --opt encrypted --driver overlay --subnet "${net_prefix_ingress}.0/16" --gateway "${net_prefix_ingress}.254" "ingress"
                    fi
                fi
                ;;
            * )
                msg_error "INVALID NETWORK SCOPE"
                return
                ;;
        esac

        ## network create loop
        # for i in {0..3}; do
        #     net_options="--opt encrypted --scope ${scope} --driver ${driver} --subnet ${net_prefix[$i]}.0/24 --gateway ${net_prefix[$i]}.254 --attachable ${net_name[$i]}"
        #     case "${net_name[$i]}" in
        #         "docker_socket" )
        #             net_options="--opt encrypted --scope local --driver bridge --subnet ${net_prefix[$i]}.0/24 --gateway ${net_prefix[$i]}.254 --attachable ${net_name[$i]}"
        #             ;;
        #         "external_edge" | "reverse_proxy" )
        #             net_options="--opt encrypted --scope ${scope} --driver ${driver} --subnet ${net_prefix[$i]}.0/24 --gateway ${net_prefix[$i]}.254 --attachable ${net_name[$i]}"
        #             # continue
        #             ;;
        #         "internal_only" )
        #             net_options="${net_options} --internal"
        #             ;;
        #         * )
        #             msg_error "INVALID NETWORK NAME"; return
        #             ;;
        #     esac
        #     if docker network create "${net_options}"
        #     then echo " > \`${net_name[$i]}\` network created."
        #     else msg_error "UHOH!" "Failed to create \`${net_name[$i]}\` network. Does it already exist?"; return
        #     fi
        # done

        # TODO: rewrite to use dk_net_create instead of individual functions
        dk_net_create "local" "bridge" "docker_socket" "--internal"
        # docker network create --opt "encrypted" --scope "local" --driver "bridge" --subnet "${net_prefix_docker_socket}.0/24" --gateway "${net_prefix_docker_socket}.254" --attachable --internal "docker_socket"
        dk_net_create "swarm" "overlay" "internal_only" "--internal"
        # docker network create --opt "encrypted" --scope "${scope}" --driver "${driver}" --subnet "${net_prefix_internal_only}.0/24" --gateway "${net_prefix_internal_only}.254" --attachable --internal "internal_only"
        dk_net_create "swarm" "overlay" "external_edge"
        # docker network create --opt "encrypted" --scope "${scope}" --driver "${driver}" --subnet "${net_prefix_external_edge}.0/24" --gateway "${net_prefix_external_edge}.254" --attachable "external_edge"
        dk_net_create "swarm" "overlay" "reverse_proxy"
        # docker network create --opt "encrypted" --scope "${scope}" --driver "${driver}" --subnet "${net_prefix_reverse_proxy}.0/24" --gateway "${net_prefix_reverse_proxy}.254" --attachable "reverse_proxy"

        # docker network create --opt "encrypted" --scope "local" --driver "bridge" --subnet "172.27.21.0/24" --attachable --internal "internal_only"
        # docker network create --opt "encrypted" --scope "swarm" --driver "overlay" --subnet "172.27.30.0/24" --gateway "172.27.30.254" --attachable "external_edge"
        # docker network create --opt "encrypted" --scope "swarm" --driver "overlay" --subnet "172.27.20.0/24" --gateway "172.27.20.254" --attachable "reverse_proxy"

        echo "The \`docker_socket\`, \`internal_only\`, \`external_edge\`, and \`reverse_proxy\` custom docker networks already exist or have been created."; echo
        }

#################### docker local functions ####################

    dk_container_list(){
        fnc_extract_option "$@"
        local option="${option:-"-a"}"
        case "$option" in
            "-a" | "--all" )
                docker container list --all --format "table {{.ID}}  {{.Names}}\t{{.Status}}\t{{.RunningFor}}\t{{.Image}}"
                ;;
            "-l" | "--labels" )
                docker container list --no-trunc --format "table {{.Names}}\t{{.Status}}\t{{.Labels}}\t{{.Command}}"
                ;;
            "-n" | "--networks" )
                docker container list --no-trunc --format "table {{.Names}}\t{{.Status}}\t{{.Networks}}\t{{.Ports}}"
                ;;
            "-v" | "--volumes" )
                docker container list --no-trunc --format "table {{.Names}}\t{{.Status}}\t{{.LocalVolumes}}\t{{.Mounts}}"
                ;;
            * )
                docker container list --format "table {{.ID}}  {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Command}}"
                ;;
        esac
        }
        alias dkcl="dk_container_list --all"
        alias dll="dk_container_list"
        alias dlc="dk_container_list" # "docker list containers"

    # dk_local_start(){
    #     # echo "DEBUG: 'dk_local_start' [00] <arguments> '${*}'"
    #     fnc_extract_option "$@"
    #     stackslist=( "${opds[@]}" )
    #     # echo "DEBUG: 'dk_local_start' [01] <optn> '${optn[*]}' <opds> '${opds[*]}' <stackslist> '${stackslist[*]}'"
    #     config_type="local"
    #     set_scope_vars "${config_type}"
    #     # echo "DEBUG: 'dk_local_start' [02] <config_type> '${config_type}' <configs_path> '${configs_path}'"
    #     dk_compose_up(){
    #         for stack in "${stackslist[@]}"; do
    #             if [ -f "${local_configs}/${stack}/${local_compose}" ]; then
    #                 fnc_env_create "${config_type}" "${stack}"
    #                 docker compose -f "${local_configs}/${stack}/${local_compose}" up -d --remove-orphans
    #             else
    #                 echo " > No docker compose configuration file found for the \`${stack}\` application."
    #             fi
    #         done
    #         echo
    #         }
    #     case "$1" in
    #         -* ) # perform optional action
    #             case "$1" in
    #                 "-l" | "--logs" )
    #                     # read -r -a stackslist <<< "$(fnc_strip_option stackslist)"
    #                     # read -r stackslist < <( fnc_strip_option stackslist )
    #                     stackslist=( $( fnc_strip_option stackslist ) ) # old bash versions can't use mapfile/read examples above
    #                     dk_compose_up "${stackslist[@]}"
    #                     dk_compose_logs local "${2:-${stackslist[1]}}"
    #                     ;;
    #                 * )
    #                     echo "Invalid option: \`$1\`"; echo
    #             esac
    #             ;;
    #         * )
    #             dk_compose_up "${stackslist[@]}"
    #             ;;
    #     esac
    #     }

    dk_compose_up(){ ## USAGE: dk_compose_up <stackname1>
        if [ -f "${configs_path}/${1}/${compose_file}" ]; then
            fnc_env_create "${config_type}" "${1}"
            docker compose -f "${configs_path}/${1}/${compose_file}" up -d --remove-orphans
            return $?
        else
            msg_warning "WARNING" "No docker compose configuration file found for the \`${1}\` application."
            return 1
        fi
        # echo
        }
    dk_local_start(){ ## USAGE: dk_local_start [OPTION] <stackname1> [stackname2] ...
        # echo "DEBUG: 'dk_local_start' [00] <arguments> '${*}'"
        fnc_extract_option "$@"
        # echo "DEBUG: 'dk_local_start' [01] <optn> '${optn[*]}' <opds> '${opds[*]}'"
        config_type="local"
        set_scope_vars "${config_type}"
        # echo "DEBUG: 'dk_local_start' [02] <config_type> '${config_type}' <configs_path> '${configs_path}'"
        local success_count=0
        case "${optn[0]}" in
            "-f" | "--follow" | "-l" | "--logs" )
                if [ "${#opds[@]}" -gt 1 ]; then
                    msg_warning "WARNING" "Only the first stack name will be started."
                fi
                dk_compose_up "${opds[0]}"
                dk_compose_logs "local" "${opds[0]}"
                ((success_count++))
                ;;
            * )
                for stack in "${opds[@]}"; do
                    if dk_compose_up "${stack}" > /dev/null 2>&1; then
                        # msg_success "SUCCESS" "Started the \`${opds[*]}\` application."
                        ((success_count++))
                    # else
                    #     msg_failure "FAILURE" "No docker compose configuration file found for the \`${stack}\` application."
                    fi
                done
                ;;
        esac
        if [[ ${success_count} -eq ${#opds[@]} ]]; then
            msg_success "SUCCESS" "Started all applications."
            return 0 # all stacks started successfully
        else
            msg_failure "FAILURE" "Not all applications started successfully."
            return 1 # not all stacks started successfully
        fi
        }
    alias dcu="dk_local_start"
    alias dlu="dk_local_start"

    dk_compose_dn(){ ## USAGE: dk_compose_dn <stack_name>
        if [[ -f "${configs_path}/${1}/${compose_file}" && -f "${configs_path}/${1}/.env" ]]; then
            docker compose -f "${configs_path}/${1}/${compose_file}" down
            return $?
        elif [[ $(docker ps -a --filter "name=${1}") ]]; then
            docker stop "${1}" && docker container rm "${1}"
            return $?
        else
            msg_warning "WARNING" "No docker compose config file nor docker container found for the \`${1}\` application."
            return 1
        fi
        # echo
        }
    dk_local_stop(){ ## USAGE: dk_local_stop <stackname1> [stackname2] ...
        fnc_extract_option "$@"
        config_type="local"
        set_scope_vars "${config_type}"
        local success_count=0
        for stack in "${opds[@]}"; do
            if dk_compose_dn "${stack}" > /dev/null 2>&1; then
                # msg_success "SUCCESS" "Stopped and removed the \`${stack}\` application."
                ((success_count++))
            # else
            #     msg_failure "FAILURE" "No docker compose configuration file found for the \`${stack}\` application."
            fi
        done
        if [ "${success_count}" -eq "${#opds[@]}" ]; then
            msg_success "SUCCESS" "Stopped and removed all applications."
            return 0 # all stacks stopped and removed
        else
            msg_failure "FAILURE" "Not all applications stopped and removed."
            return 1 # not all stacks stopped and removed
        fi
        }
    alias dcd="dk_local_stop"
    alias dld="dk_local_stop"

    dk_local_bounce(){ dk_compose_dn "$1" && dk_local_start "$1" ; }
    alias dcb="dk_local_bounce"

    # echo -e "\n>> docker local aliases and functions created <<"

#################### docker swarm functions ####################

    dk_stack_all(){ docker stack ls; }
    dk_stack_lst(){ docker stack ls --format "table {{.Name}}\t{{.Description}}\t{{.CreatedAt}}\t{{.Status}}\t{{.CurrentState}}"; }
    dk_stack_chk(){ docker stack ps --no-trunc --format "{{.Error}}" "${1}"; }
    dk_stack_err(){ docker stack ps --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}" "${1}"; }
    dk_stack_svc(){ docker stack services "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Ports}}"; }

    dk_list_stacks(){ ## USAGE: dk_list_stacks [OPTION] [stack_name]
        fnc_extract_option "$@"
        # echo "DEBUG: 'dk_list_stacks' <optn> '${optn[*]}' <opds> '${opds[*]}'"
        case "${optn[0]}" in
            "-a" | "--all" )
                dk_stack_all
                ;;
            "-e" | "--error" )
                dk_stack_err "${opds[0]}"
                ;;
            "" )
                dk_stack_lst
                ;;
            * )
                dk_stack_svc "${opds[0]}"
                ;;
        esac
        }
    alias dls="dk_list_stacks" # "docker list stacks"
    alias dlw="dk_list_stacks" # "docker list swarm apps"
    alias dkls="dk_stack_lst" # "docker list stacks"
    # alias dwl="dk_list_stacks" # "docker list swarm apps"

    dk_stack_deploy(){ ## USAGE: dk_stack_deploy <stack_name>
        if [ -f "${configs_path}/${1}/${compose_file}" ]; then
            fnc_env_create "${config_type}" "${1}"
            docker stack deploy "${1}" -c "${configs_path}/${1}/${compose_file}" --prune
            return $?
        else
            msg_warning "WARNING" "No docker stack config found for the \`${1}\` application."
            return 1
        fi
        # echo
        }
    dk_swarm_start(){
        export config_type="swarm"
        set_scope_vars "${config_type}"
        success_count=0
        for stack in "${opds[@]}"; do
            if dk_stack_deploy "${stack}" > /dev/null 2>&1; then
                # msg_success "SUCCESS" "Deployed the \`${stack}\` application."
                ((success_count++))
            # else
            #     msg_failure "FAILURE" "No docker stack configuration file found for the \`${stack}\` application."
            fi
        done
        }
    alias dwu="dk_swarm_start"
    alias dwt="dk_swarm_start"

    dk_stack_remove(){ ## USAGE: dk_compose_up <stackname1>
        if [[ -f "${configs_path}/${1}/${compose_file}" && -f "${configs_path}/${1}/.env" ]]; then
            docker stack rm "${1}" -c "${configs_path}/${1}/${compose_file}"
            return $?
        elif [[ $(docker ps -a --filter "name=${1}") ]]; then
            docker stop "${1}" && docker container rm "${1}"
            return $?
        else
            msg_warning "WARNING" "No docker stack config nor docker stack found for the \`${1}\` application."
            return 1
        fi
        # echo
        }
    dk_swarm_stop(){
        export config_type="swarm"
        set_scope_vars "${config_type}"
        success_count=0
        for stack in "${opds[@]}"; do
            if dk_stack_remove "${stack}" > /dev/null 2>&1; then
                # msg_success "SUCCESS" "Removed the \`${stack}\` application."
                ((success_count++))
            # else
            #     msg_failure "FAILURE" "No docker stack configuration file found for the \`${stack}\` application."
            fi
        done
        }
    alias dwd="dk_swarm_stop"
    alias dwp="dk_swarm_stop"

    dk_swarm_bounce(){ dk_swarm_stop "$1" && dk_swarm_start "$1" ; }
    alias dwb="dk_swarm_bounce"

    dk_list_swarm_nodes(){
        docker node ls -q | xargs docker node inspect   -f \
        'NODE={{ .Description.Hostname }}, IP={{ .Status.Addr }}, ROLE={{ .Spec.Role }}, STATE={{ .Status.State }}, AVAILABILITY={{ .Spec.Availability }}, ID={{ .ID }} :
        OS={{ .Description.Platform.OS }}, ARCH={{ .Description.Platform.Architecture }}, CPUs={{ .Description.Resources.NanoCPUs }}, RAM={{ .Description.Resources.MemoryBytes }}, DOCKER VERSION={{ .Description.Engine.EngineVersion }},
        LABELS={{ range $k, $v := .Spec.Labels }}{{ $k }}={{ $v }} {{end}}
        '
        }
    alias dknodes="dk_list_swarm_nodes"

    # echo -e "\n>> docker swarm aliases and functions created <<"; echo

####################################################################################################

echo -e " >> ${blu:-}docker aliases and functions ${grn:-}created${def:-} <<\n"

