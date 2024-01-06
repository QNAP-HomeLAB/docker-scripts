#!/bin/bash
################################################################################
# Place this file in $HOME/docker/ and name it docker_functions.sh
# A quick and easy way to do this is to run one of these download commands:
# git archive --remote=https://github.com/QNAP-HomeLAB/docker-scripts.git HEAD:docker_functions.sh $HOME/docker/common/docker_functions.sh | tar -xvf -
# wget -qN 'https://raw.githubusercontent.com/QNAP-HomeLAB/docker-scripts/master/docker_functions.sh' -O $HOME/docker/common/docker_functions.sh
# curl -s 'https://raw.githubusercontent.com/QNAP-HomeLAB/docker-scripts/master/docker_functions.sh' > $HOME/docker/common/docker_functions.sh
################################################################################
######### --> **** UPDATE THESE VARIABLES FOR YOUR ENVIRONMENT **** <-- ########

    export docker_usr="docker" ## default is `docker`
    export docker_grp="docker" ## default is `docker`
    export docker_dir="${HOME:-/opt}/docker" ## default is `$HOME/docker`

    export net_prefix_docker_socket="172.27.0" ## DO NOT include the 4th octet
    export net_prefix_external_edge="172.27.1" ## DO NOT include the 4th octet
    export net_prefix_reverse_proxy="172.27.2" ## DO NOT include the 4th octet
    export net_prefix_internal_only="172.27.3" ## DO NOT include the 4th octet
    export net_prefix_ingress="10.27.0" ## DO NOT include the 4th octet

    git_raw_url="https://raw.githubusercontent.com/qnap-homelab/docker-scripts/master";

################################################################################
##################### NOTHING BELOW HERE SHOULD BE CHANGED #####################
################################################################################

## docker folder visual tree
#  $HOME
#   └── docker
#       ├── common
#       │   ├── .docker_env.example
#       │   ├── docker_functions.sh
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

####################### docker uid/gid/directories setup #######################


    ## configuration types
    export docker_config_types=("build" "local" "swarm")

    ## docker common folder
    export docker_common="$docker_dir/common"

    ## docker secrets path
    export docker_secrets="$docker_common/secrets"

    export docker_env_example="$docker_common/.vars_docker.example"
    export docker_env_file="$docker_common/.docker.env"

    ## alias to easily source this file
    export docker_fnc_file="$docker_common/docker_functions.sh"
    alias dkfnc="source $docker_fnc_file"

    ## docker build folders
    export build_path="$docker_dir/build"
    export build_appdata="$build_path/appdata"
    export build_configs="$build_path/configs"
    export build_runtime="$build_path/runtime"
    export build_compose="compose.yml"
    # declare -A build_scope
    # build_scope[data]="${build_path}/appdata"
    # build_scope[conf]="${build_path}/configs"
    # build_scope[file]="compose.yml"

    ## docker compose local
    export local_path="$docker_dir/local"
    export local_appdata="$local_path/appdata"
    export local_configs="$local_path/configs"
    export local_runtime="$local_path/runtime"
    export local_compose="compose.yml"
    # declare -A local_scope
    # local_scope[data]="${local_path}/appdata"
    # local_scope[conf]="${local_path}/configs"
    # local_scope[file]="compose.yml"

    ## docker swarm configs folders
    export swarm_path="$docker_dir/swarm"
    export swarm_appdata="$swarm_path/appdata"
    export swarm_configs="$swarm_path/configs"
    export swarm_runtime="$swarm_path/runtime"
    export swarm_compose="compose.yml"
    # declare -A swarm_scope
    # swarm_scope[data]="${swarm_path}/appdata"
    # swarm_scope[conf]="${swarm_path}/configs"
    # swarm_scope[file]="compose.yml"

    # export docker_appdata=(
    #     "${build_scope[data]}"
    #     "${local_scope[data]}"
    #     "${swarm_scope[data]}"
    #     ) #("${build_appdata}" "${local_appdata}" "${swarm_appdata}")
    # export docker_configs=(
    #     "${build_scope[conf]}"
    #     "${local_scope[conf]}"
    #     "${swarm_scope[conf]}"
    #     ) #("${build_configs}" "${local_configs}" "${swarm_configs}")

    ## assign docker UID and GID variables
    docker_uid=$(id -u "${docker_usr:-docker}"); export docker_uid #; echo "DEBUG: docker UID: ${docker_uid}"
    docker_gid=$(id -g "${docker_usr:-docker}"); export docker_gid #; echo "DEBUG: docker GID: ${docker_gid}"

    ## folder and file permissions
    perms_cert='a-rwx,u=rwX,g=,o='; export perms_cert # 600 # -rw-rw----
    perms_conf='a-rwx,u+rwX,g=rwX,o=rX'; export perms_conf # 664 # -rw-rw-r--
    perms_data='a-rwx,u+rwX,g=rwX,o='; export perms_data # 660 # -rw-rw----
    perms_main='a=rwX,o-w'; export perms_main # 775 # -rwxrwxr-x

    # might want to consolidate these with scope config vars above
    set_scope_vars(){
        # echo "DEBUG: set_scope_vars: \`$1\`  config_type: \`$config_type\`"
        case "$config_type" in
            ("build")
                export appdata_path="${build_appdata}"
                export configs_path="${build_configs}"
                export compose_file="${build_compose}"
                ;;
            ("local")
                export appdata_path="${local_appdata}"
                export configs_path="${local_configs}"
                export compose_file="${local_compose}"
                ;;
            ("swarm")
                export appdata_path="${swarm_appdata}"
                export configs_path="${swarm_configs}"
                export compose_file="${swarm_compose}"
                ;;
            (*)
                msg_error "INVALID CONFIG TYPE" "Please inform the script maintainer."
                return ;;
        esac
        }

    ## check if sudo is needed for some commands used in these custom docker functions
    if [[ $(id -u) -ne 0 ]]; then var_sudo="$(command -v sudo 2>/dev/null)"; else var_sudo=""; fi; #unset var_sudo; fi;

########################## message functions ############################

    ## source bash environment variables for color codes
    if test -z "$def"; then src="$HOME/.bash_env"; if [ -f "${src}" ]; then . "${src}"; fi; fi;

    msg_alert(){ echo -e "${orn:?} ALERT ${def:?}>> ${ylw:?}${1:-HERE_BE_DRAGONS}${def:?} >> ${red:?}${2:-this_action_is_final}${def:?} <<"; echo; return; }
    msg_error(){ echo -e "${red:?} ERROR ${def:?}>> ${mgn:?}${1:-INVALID_ENTRY}${def:?} >> ${blu:?}${2:-please_notify_the_script_author}${def:?} <<"; echo; return; }
    msg_info(){ echo -e "${cyn:?} INFO ${def:?}>> ${blu:?}${1:-ACTION_IN_PROGRESS}${def:?} >> ${prp:?}${2:-something_is_not_quite_right}${def:?} <<"; echo; return; }
    msg_failure(){ echo -e "${red:?} FAILURE ${def:?}>> ${mgn:?}${1:-OPERATION_FAILURE}${def:?} >> ${cyn:?}${2:-operation_failed}${def:?} <<"; echo; return; }
    msg_success(){ echo -e "${grn:?} SUCCESS ${def:?}>> ${mgn:?}${1:-OPERATION_SUCCESS}${def:?} >> ${cyn:?}${2:-operation_succeeded}${def:?} <<"; echo; return; }
    msg_warning(){ echo -e "${ylw:?} WARNING ${def:?}>> ${mgn:?}${1:-INVALID_ENTRY}${def:?} >> ${cyn:?}${2:-please_check_valid_option_flags}${def:?} <<"; echo; return; }

########################## docker functions ############################

    ## USAGE: fnc_dir_create <directory> <permissions>
    fnc_dir_create(){ if [[ ! -d "$1" ]]; then ${var_sudo:-} install -o "${docker_uid}" -g "${docker_gid}" -m "$2" -d "$1"; fi; }

    fnc_dir_create "${docker_secrets}" "${perms_data}"
    fnc_dir_create "${local_appdata}" "${perms_data}"
    fnc_dir_create "${local_configs}" "${perms_conf}"
    fnc_dir_create "${swarm_appdata}" "${perms_data}"
    fnc_dir_create "${swarm_configs}" "${perms_conf}"

    ## separate option from args
    fnc_extract_option(){ # USAGE: fnc_extract_option $@
        ## initialize arrays
        local args=("$@")
        local opts=()
        local opds=()

        ## iterate through arguments
        # echo -e "\n fnc_extract_option args: $*"
        for arg in "${args[@]}"; do
            if [[ $arg = "." ]]; then
                continue;
            elif [[ $arg == "-*" ]]; then
                opts+=("$arg");
            else
                opds+=("$arg");
            fi
        done

        ## validate option count
        if [[ ${#opts[@]} -gt 1 ]]; then
            msg_error "More than one option found." "Check \`--help\` for usage syntax.";
            return 1;
        else ## export arrays
            option="${opts[*]}" ; #echo "option: ${opts[*]}";
            operands=("${opds[@]}"); #echo "operands: ${opds[*]}";
        fi
        }

    ## Download file if it doesn't exist already, then optionally create a symlink
    fnc_file_download(){ # USAGE: fnc_file_download <url> <filepath> [symlink]
        # echo -e " DEBUG: 'fnc_file_download' args: $*"
        fnc_extract_option "$@";
        local file_url="${operands[0]}"; #echo "file_url: $file_url";
        local filename="${operands[1]}"; #echo "filename: $filename";
        local filelink="${operands[2]}"; #echo "filelink: $filelink";
        # local file_url="${1}";
        # local filename="${2}";
        # local filelink="${3}";
        # echo -e " DEBUG: 'fnc_file_download' file_url: '${file_url}'"
        # echo -e " DEBUG: 'fnc_file_download' filename: '${filename}'"
        # echo -e " DEBUG: 'fnc_file_download' filelink: '${filelink}'"

        if [[ -f "$filename" ]]; then
            case "${option}" in
                ("-f"|"--force")
                    var_force="-N ";
                    # wget -N "$file_url" -O "$filename"
                    ;;
                (*) # msg_info "File \`${filename}\` already exists." "Use option \`--force\` to overwrite.";
                    return;;
            esac
        elif ! wget -qN --show-progress "$var_force""$file_url" -O "$filename"; then
        # elif ! curl "$file_url" -o "$filename" -#; then
            msg_failure "DOWNLOAD FAILED" "check url: $file_url"; return 1;
        fi
        if [[ -n "$filelink" ]]; then
            ${var_sudo:-} install -o "${docker_uid}" -g "${docker_gid}" -m "${perms_conf}" "$filename" "$filelink";
        fi
        }

    # initialize(){
        fnc_file_download "$git_raw_url/.color_codes.conf" "$HOME/.bash_env";
        fnc_file_download "$git_raw_url/.vars_docker.example" "$docker_env_example" "$docker_env_file";

        # if [[ ! -f "$filename" ]]; then
        #     if ! wget "$file_url" -O "$filename";
        #     then msg_failure "Failed to download" "$file_url"; return 1;
        #     fi;
        # fi

        ## create blank .docker.env if download fails
        if [[ ! -f "$docker_env_file" ]]; then ${var_sudo:-} install -o "${docker_uid}" -g "${docker_gid}" -m "${perms_data}" /dev/null "$docker_env_file"; fi;
    # }

    ## symlink verify and create function
    symlink_create(){ ## USAGE: symlink_create <symlink> <target>
        local symlink="$1";
        local target="$2";
        if [[ ! -f "$symlink" ]]; then ln -s "$target" "$symlink"; fi;
        }

    ## create the $HOME/.docker_fnc symlink if it does not exist
    symlink_create "$HOME/.docker_fnc" "$docker_fnc_file"

    verify_action(){ ## usage verify_action <message>
        msg_alert "" "$1";
        while read -r -p " >> CONTINUE? [y/N] <<" input; do
            case "${input:-N}" in
                ([yY]|[yY][eE][sS]) return 0 ;;
                ([nN]|[nN][oO]) break ;;
                (*) msg_failure "Invalid input" "Please enter 'y' or 'n'";;
                # echo -e " > invalid input <"; return 1; ;;
            esac
        done
        }

    fnc_check_dir(){ if test ! -d "$1"; then msg_warning "Docker container directory does not exist." "Use \`dcf $1\` to create."; break; fi; }

    fnc_check_app(){ if test -z "$1"; then msg_warning "No application name specified." "Application name required."; break; fi; }
    validate_appname(){
        echo " DEBUG: 'validate_appname' 1: '$1'"
        # fnc_check_app "$1";
        if [[ ${1:0:1} =~ ^[_-]+$ ]] || [[ ! ${1} =~ ^[a-zA-Z0-9_-]+$ ]];
        then msg_warning "Invalid application name." "Only alphanumeric characters, underscores, and hyphens allowed."; break;
        else return 0; # container name only contains valid characters
        fi;
        }

    ## TODO: function code suggested by Cody AI
    ## NOT YET VERIFIED TO WORK
    validate_ip4(){ # USAGE: validate_ip4 <ip>/<subnet>
        # Matches 0.0.0.0 to 255.255.255.255
        ip_regex='^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$'

        # Extract from subnet variable
        ip="${net_prefix_docker_socket%/*}"
        mask="${net_prefix_docker_socket#*/}"
        if [[ ! $ip =~ $ip_regex ]]; then
            echo "Invalid IP: $ip"
            break
        fi

        if [[ $mask -lt 0 ]] || [[ $mask -gt 32 ]]; then
            echo "Invalid mask: $mask"
            break
        fi

        # Convert mask to binary string
        mask_bin=$(echo "obase=2; $mask" | bc)

        # Prefix with 1's, remaining with 0's
        mask_bin=$(printf "%032d" "$mask_bin")

        # Convert to hex
        mask_hex=$(echo "ibase=2;$mask_bin" | bc)

        # Get network and broadcast addresses
        network_hex=$(echo "ibase=16; $ip & $mask_hex" | bc)
        broadcast_hex=$(echo "ibase=16; $ip | $mask_hex" | bc)

        # Convert hex back to decimal IP
        network_ip=$(echo "obase=A;$network_hex" | bc)
        broadcast_ip=$(echo "obase=A;$broadcast_hex" | bc)

        if [[ $ip != $(echo "$network_ip <= $ip <= $broadcast_ip" | bc) ]]; then
            echo "IP $ip out of subnet range"
            break
        fi
    }

    docker_configs_list(){ ## USAGE: fnc_configs_list <config_type>
        local config_type="${1}"; shift;
        set_scope_vars "$config_type";
        fnc_extract_option "$@";
        ## find config dirs or files
        case "${option}" in
            "-d"|"--dir*"|"--folder")
                mapfile -t config_list < <(find "$configs_path" -maxdepth 1 -type d -not -path '*/\.*');;
            *)
                mapfile -t config_list < <(find "$configs_path" -maxdepth 2 -type f -name "$compose_file" | sed 's|/[^/]*$||');;
        esac
        ## print config list
        if [[ "${#config_list[@]}" -eq 0 ]];
        then msg_warning "No $config_type configs found." "Use \`dcf/dwf <appname>\` to create one."; return;
        else echo -e " > DOCKER CONFIG LIST FOR \`$config_type\` CONTAINERS <\n ${config_list[*]}";
        fi
        }

# #################### general docker functions ####################

    ## docker network list function
    docker_list_networks(){ docker network ls; echo; }
    alias dln="docker_list_networks"

    ## docker common list functions
    docker_common_list(){ echo "ls ${docker_common}"; /usr/bin/ls "${docker_common}"; echo; }
    alias dklc="docker_common_list"
    common(){ cd "${docker_common}/$1" || echo; return; }
    alias dkc="common"
    
    ## docker secrets list functions
    docker_secrets_list(){ echo "ls ${docker_secrets}"; /usr/bin/ls "${docker_secrets}"; echo; }
    alias dkls="docker_secrets_list"
    secrets(){ cd "${docker_secrets}/$1" || echo; return; }
    alias dks="secrets"

    ## docker local list functions
    docker_list_local_appdata(){ echo "ls ${local_appdata}"; /usr/bin/ls "${local_appdata}"; echo; }
    alias dlca="docker_list_local_appdata"
    docker_list_local_configs(){ echo "ls ${local_configs}"; /usr/bin/ls "${local_configs}"; echo; }
    alias dlcg="docker_list_local_configs"
    dklocal(){ cd "${local_configs}/$1" 2>/dev/null || return; }
    alias dkl="dklocal" #"compose"

    ## docker swarm list functions
    docker_list_swarm_appdata(){ echo "ls ${swarm_appdata}"; /usr/bin/ls "${swarm_appdata}"; echo; }
    alias dlwa="docker_list_swarm_appdata"
    docker_list_swarm_configs(){ echo "ls ${swarm_configs}"; /usr/bin/ls "${swarm_configs}"; echo; }
    alias dlwg="docker_list_swarm_configs"
    dkswarm(){ cd "${swarm_configs}/$1" || echo; return; }
    alias dkw="dkswarm"

    # vpn and ip check functions
    dl_cmd_check(){
        if [[ -n "$(which curl)" ]]; then dl_cmd="curl";
        elif [[ -n "$(which wget)" ]]; then dl_cmd="wget -qO-";
        else echo "Neither curl nor wget found. Exiting."; return 1;
        fi
        }
    vpncheck(){ dl_cmd_check; echo " > Host IP: $("${dl_cmd}" ifconfig.me)" && echo "Container IP: $(docker container exec -it "${*}" "${dl_cmd}" ipinfo.io)"; }
    ctipcheck(){ dl_cmd_check; echo " > Container IP: $(docker container exec -it "${*}" "${dl_cmd}" ipinfo.io)"; }
    alias ctip="ctipcheck"

    ctport(){ docker container exec -it "${*}" netstat -tulpn; }

    # check_vpn_curl(){ echo "     Host IP: $(curl ifconfig.me)" && echo "Container IP: $(docker container exec -it ${*} curl ipinfo.io/ip)"; }
    # alias vpncheckc="check_vpn_curl"
    # check_vpn_wget(){ echo "     Host IP: $(wget -qO- ifconfig.me)" && echo "Container IP: $(docker container exec -it ${*} wget -qO- ipinfo.io/ip)"; }
    # alias vpncheckw="check_vpn_wget"
    # alias vpncheck="vpncheckw"

    # check_ctip_curl(){ echo "Container IP: $(docker container exec -it ${1} curl ipinfo.io)"; }
    # alias ipcheckc="check_ctip_curl"
    # check_ctip_wget(){ echo "Container IP: $(docker container exec -it ${1} wget -qO- ipinfo.io)"; }
    # alias ipcheckw="check_ctip_wget"
    # alias ipcheck="ipcheckw"

    ## verify website function
    verify_url(){ echo " '$1' status code: $(curl -s -o /dev/null --head -w "%{http_code}" "$1" --max-time 5)"; }
    # verify_url(){ if wget --spider "${1}" 2>/dev/null; then echo "Website exists."; else echo "Website is not available."; fi; } ## does not seem to work for local websites
    alias webcheck="verify_url"

########################## docker permissions update ###########################

    # update_file_permissions(){ # usage: update_file_permissions [option] <permissions> <file list>
    #     fnc_extract_option "${@}";
    #     perms="${operands[0]}"; unset "${operands[0]}";
    #     files_list=("${operands[@]}")

    #     case "${option}" in
    #         (-*) option="${1}"; shift;
    #             case "${option}" in
    #                 ("-a"|"--all") files_dir="${configs_path}" ;;
    #                 (*) msg_error "Invalid option: ${option}"; return 1;;
    #             esac
    #             ;;
    #         (*) files_dir="${configs_path}/${1}" ;;
    #     esac
    #     for file in "${files_list[@]}"; do
    #         ${var_sudo:-} find "$files_dir" -iname "$file" -type f -exec chmod "$perms" {} +
    #     done
    #     }
    # # files_list=("acme.json" "*.crt" "*.key" "*.pub" "*.ppk" "*.pem");
    # update_file_permissions "$perms_cert" "acme.json" "*.crt" "*.key" "*.pub" "*.ppk" "*.pem";

    set_file_permissions(){ ${var_sudo:-} find "${files_dir}" -iname "${2}" -type f -exec chmod "${1}" {} +; }
    docker_file_permissions(){
        case "${1}" in
            ("-a"|"--all") files_dir="${configs_path}" ;;
            (*) files_dir="${configs_path}/${1}" ;;
        esac
        # update restricted access file permissions to 600
        files_restricted=("acme.json" "*.crt" "*.key" "*.pub" "*.ppk" "*.pem");
        for file in "${files_restricted[@]}"; do
            set_file_permissions "${perms_cert}" "${file}"
        done
        # update limited access file permissions to 660
        files_limited=(".conf" "*.env" ".log" "*.secret");
        for file in "${files_limited[@]}"; do
            set_file_permissions "${perms_data}" "${file}"
        done
        # # update general access file permissions to 664
        # files_general=("*.yml" "*.yaml" "*.toml");
        # for file in "${files_general[@]}"; do
        #     set_file_permissions "${perms_conf}" "${file}"
        # done
        }

    set_folder_owner(){ ${var_sudo:-} chown -R "${1}" "${2}"; }
    set_folder_permissions(){ ${var_sudo:-} chmod -R "${1}" "${2}"; }
    docker_folder_permissions(){
        fnc_check_app "$1";
        for stack in ${1}; do
            case "${stack}" in
                ("-a"|"--all")
                    ## update all docker folder ownership
                    set_folder_owner "${docker_uid}:${docker_gid}" "${docker_dir:?}";
                    ## update appdata folder permissions
                    dirs_list=("${local_appdata}" "${swarm_appdata}" "${docker_secrets}");
                    for dir in "${dirs_list[@]}"; do
                        set_folder_permissions "${perms_data}" "${dir:?}";
                    done; # -rwXrwX---
                    ## update config folder permissions
                    dirs_list=("${docker_shared}" "${local_configs}" "${swarm_configs}");
                    for dir in "${dirs_list[@]}"; do
                        set_folder_permissions "${perms_conf}" "${dir:?}";
                    done; # -rwXrwXr-X
                    ## update all docker file permissions
                    docker_file_permissions --all;
                    echo -e " > \`ALL\` docker subdirectory and file permissions updated <"
                    ;;
                (*) # update specified docker folder permissions
                    appdata_dir="${appdata_path:?}/${stack}";
                    appconf_dir="${configs_path:?}/${stack}";
                    if [[ ! -d "${appconf_dir:?}" ]]; then
                        echo -e " > \`${appconf_dir:?}\` docker container directory does not exist <"; return;
                    fi;
                    set_folder_owner "${docker_uid}:${docker_gid}" "${appdata_dir:?}";
                    set_folder_permissions "${perms_data}" "${appdata_dir:?}";
                    set_folder_owner "${docker_uid}:${docker_gid}" "${appconf_dir:?}";
                    set_folder_permissions "${perms_conf}" "${appconf_dir:?}";
                    docker_file_permissions "${stack}";
                    echo -e " > \`${stack}\` docker container subdirectory and file permissions updated <";
                    # echo -e "\n  ${ylw:?}UPDATED ${blu:?}${appdata_dir:?}/${mgn:?}${stack}${def:?} AND ${blu:?}${docker_local:?}/${mgn:?}${stack}${def:?} docker_folders AND FILE PERMISSIONS ${def:?}";
                    ;;
            esac
        done;
        }
    docker_permissions_update(){
        dirs_list=("${local_configs}" "${swarm_configs}");
        for dir in "${dirs_list[@]}"; do
            export configs_path="$dir";
            docker_folder_permissions "--all";
        done
        }
    alias dkp="docker_permissions_update"

########################### docker_files and docker_folders ###########################

    fnc_env_create(){
        fnc_extract_option "$*";
        echo " DEBUG: 'fnc_env_create' option: '$option' operands: '${operands[*]}' configs_path: '$configs_path' 1: '$1' 2: '$2' *: '$*'"
        for stack in "${operands[@]}"; do
            case "${option}" in
                "-c"|"--copy"|"-f"|"--force") # force copy `.docker.env` to `../configs/$1/.env`
                    ${var_sudo:-} install -o "${docker_uid}" -g "${docker_gid}" -m "${perms_data}" "${docker_env_file}" "${configs_path}/${stack}/.env";
                    ;;
                "-d"|"--delete"|"-r"|"--remove") # remove `..configs/$1/.env`
                    ${var_sudo:-} rm -f "${configs_path}/${stack}/.env";
                    ;;
                *) # symlink .env to .docker.env.example if it does not exist
                    echo " DEBUG: 'fnc_env_create' option: '$option' operands: '${stack}' configs_path: '$configs_path' 1: '$1' 2: '$2' *: '$*'"
                    validate_appname "${stack}";
                    if [[ -f "${configs_path}/${stack}/.env" ]];
                    then echo -e " > \`${configs_path}/${stack}/.env\` already exists. Verify the values in the \`.env\` file are correct. <";
                    else symlink_create "${configs_path}/${stack}/.env" "${docker_env_example}";
                    # ln -s "${docker_env_file}" "${configs_path}/${operands[0]}/.env"; # symlinks .env to .docker.env
                    fi
                    ;;
            esac
        done
        }
    docker_folders_create(){
        # local config_type="${1}"; shift;
        # set_scope_vars "$config_type";
        # fnc_extract_option "$@";
        for stack in "${operands[@]}"; do
            # docheck=0;
            fnc_check_app "$stack";
            if [[ -d "${appdata_path}/${stack}" ]]; then
                msg_info "\`${appdata_path:?}/${stack}\`" "already exists." #"Use option \`--force\` to overwrite."
                # docheck=$((docheck + 1));
            else # create docker container data directory
                if validate_appname "${stack}"; then
                    # echo -e " > Creating directory for the \` ${appdata_path}/${stack} \` container <"; echo;
                    fnc_dir_create "${appdata_path}/${stack}" "${perms_data}"
                    msg_success "CREATED" " \`${appdata_path}/${stack}\` data directory.";
                fi;
            fi;
            if [[ -d "${configs_path}/${stack}" ]]; then
                msg_info "\`${configs_path:?}/${stack}\`" "already exists." #"Use option \`--force\` to overwrite."
                # docheck=$((docheck + 2));
            else # create docker container config directories and files
                if validate_appname "${stack}"; then
                    # echo -e " > Creating directories and files for the \` ${configs_path}/${stack} \` container <"; echo;
                    fnc_dir_create "${configs_path}/${stack}" "${perms_conf}"
                    fnc_env_create "${stack}";
                    ${var_sudo:-} install -o "${docker_uid}" -g "${docker_gid}" -m "${perms_conf}" /dev/null "${configs_path}/${stack}/${compose_file}";
                    msg_success "CREATED" " \`${configs_path}/${stack}\` configs directory and files.";
                fi;
            fi;
            # case "$docheck" in
            #     "1") echo " > Docker appdata directory for \`${appdata_path:?}/${stack}\` already exists.";;
            #     "2") echo " > Docker configs directory for \`${configs_path:?}/${stack}\` already exists.";;
            #     "3") echo " > Docker appdata and configs directories for the \`${stack}\` application already exist.";;
            # esac
        done
        # echo
        }
    docker_folders_delete(){
        echo " DEBUG: 'docker_folders_delete' operands: '${operands[*]}' 1: '$1' 2: '$2' *: '$*'"
        for stack in "${operands[@]}"; do
            if ! verify_action " > This will forcefully delete all \`${stack}\` application directories and files."; then return; fi;
            fnc_check_app "${stack}";
            if [[ -d "${appdata_path:?}/${stack}" ]]; then
                rm -rf "${appdata_path:?}/${stack}";
                echo " > \`${appdata_path:?}/${stack}\` and contents deleted.";
            else msg_warning "UHOH!" " \`${appdata_path:?}/${stack}\` does not exists. Nothing to remove."
                # echo " > \`${appdata_path:?}/${stack}\` does not exists. Nothing to remove."; echo;
            fi;
            if [[ -d "${configs_path:?}/${stack}" ]]; then
                rm -rf "${configs_path:?}/${stack}";
                echo " > \`${configs_path:?}/${stack}\` and contents deleted.";
            else msg_warning "UHOH!" " \`${configs_path:?}/${stack}\` does not exists. Nothing to remove."
                # echo " > \`${configs_path:?}/${stack}\` does not exists. Nothing to remove."; echo;
            fi;
        done
        # echo
        }
    docker_folder_actions(){
        local config_type="${1}"; shift;
        set_scope_vars "$config_type";
        fnc_extract_option "$@";
        case "${option}" in
            (-*) # perform optional action
                case "${option}" in
                    "-c"|"--create")
                        docker_folders_create "$@" ;;
                    "-d"|"--delete")
                        docker_folders_delete "$@" ;;
                    "-r"|"--remove")
                        docker_folders_delete "$@" ;;
                    *)
                        echo " > Invalid option \`${option}\` used."; echo;
                esac
                ;;
            (*) docker_folders_create "$@" ;;
        esac;
        unset config_type
        }

######################### docker network functions #########################

    fnc_network_check(){ docker network ls -q --filter name="$1"; }
    docker_networks_create(){
        ## $1 is scope, $2 is driver
        case "$1" in
            ("local")
                if [[ "$(fnc_network_check "docker_gwbridge")" ]]; then docker network rm "docker_gwbridge"; fi;
                ;;
            ("swarm")
                if [[ "$(fnc_network_check "ingress")" ]]; then docker network rm ingress; fi;
                docker network create --ingress --opt encrypted --driver overlay --subnet "${net_prefix_ingress}.0/16" --gateway "${net_prefix_ingress}.254" "ingress";
                ;;
            (*)
                msg_error "INVALID NETWORK SCOPE"; return;
                ;;
        esac
        docker network create --opt "encrypted" --scope "local" --driver "bridge" --subnet "${net_prefix_docker_socket}.0/24" --gateway "${net_prefix_docker_socket}.254" --attachable "docker_socket"
        docker network create --opt "encrypted" --scope "$1" --driver "$2" --subnet "${net_prefix_external_edge}.0/24" --gateway "${net_prefix_external_edge}.254" --attachable "external_edge"
        docker network create --opt "encrypted" --scope "$1" --driver "$2" --subnet "${net_prefix_reverse_proxy}.0/24" --gateway "${net_prefix_reverse_proxy}.254" --attachable "reverse_proxy"
        # docker network create --opt "encrypted" --scope "swarm" --driver "overlay" --subnet "172.27.20.0/24" --gateway "172.27.20.254" --attachable "reverse_proxy"
        echo "The \`docker_socket\`, \`external_edge\`, and \`reverse_proxy\` docker networks already exist or were created."; echo
        }

########################### docker local functions ###########################

    docker_list_containers(){
        case "$1" in
            "-a"|"--all")
                docker container list --all --format "table {{.ID}}  {{.Names}}\t{{.Status}}\t{{.RunningFor}}\t{{.Image}}";;
            "-l"|"--labels")
                docker container list --no-trunc --format "table {{.Names}}\t{{.Status}}\t{{.Labels}}\t{{.Command}}";;
            "-n"|"--networks")
                docker container list --no-trunc --format "table {{.Names}}\t{{.Status}}\t{{.Networks}}\t{{.Ports}}";;
            "-v"|"--volumes")
                docker container list --no-trunc --format "table {{.Names}}\t{{.Status}}\t{{.LocalVolumes}}\t{{.Mounts}}";;
            *)
                docker container list --format "table {{.ID}}  {{.Names}}\t{{.Status}}\t{{.Image}}\t{{.Command}}";;
        esac
        }
    alias dlc="docker_list_containers" # "docker list containers"
    alias dll="docker_list_containers" # "docker list local apps"

    alias dcf='docker_folder_actions local'

    alias dcenv="fnc_env_create local";

    alias dcp="docker_folder_permissions local"

    docker_local_edit(){ nano "${local_configs}/$1/${local_compose}"; }
    alias dce="docker_local_edit"

    docker_local_config(){ docker compose -f "${local_configs}/$1/${local_compose}" config; }
    alias dcc="docker_local_config"
    alias dct="docker_local_config"

    alias dcg="docker_configs_list local"

    docker_local_logs(){ (cd "${local_configs}/$1" && docker compose logs -f); }
    alias dcl="docker_local_logs"

    docker_local_networks(){ docker_networks_create "local" "bridge"; }
    alias dcn="docker_local_networks"

    docker_list_networks(){ docker network ls; }
    alias dln="docker_list_networks"

    fnc_strip_option(){ local list="$1[@]"; local apps=( "${!list}" ); apps=( "${apps[@]:1}" ); } # remove first arg

    docker_local_start(){
        applist=( "$@" )
        export configs_path="${local_configs}";
        fnc_compose_start(){
            for app in "${applist[@]}"; do
                if [[ -f "${local_configs}/$app/${local_compose}" ]]; then
                    fnc_env_create "$app";
                    docker compose -f "${local_configs}/$app/${local_compose}" up -d --remove-orphans;
                else echo " > No docker compose configuration file found for the \`$app\` application.";
                fi;
            done
            # echo
            }
        case "$1" in
            -*) # perform optional action
                case "$1" in
                    "-l"|"--logs")
                        # applist=( $( fnc_strip_option applist ) )
                        # read -r -a applist <<< "$(fnc_strip_option applist)"
                        read -r applist < <( fnc_strip_option applist )
                        fnc_compose_start "${applist[@]}"
                        docker_local_logs "${2:-${applist[1]}}";
                        ;;
                    *) echo "Invalid option: \`$1\`"; echo;
                esac
                ;;
            *)
                fnc_compose_start "${applist[@]}"
                ;;
        esac
        }
    alias dcu="docker_local_start"

    docker_local_stop(){
        if [[ -f "${local_configs}/$1/${local_compose}" && -f "${local_configs}/$1/.env" ]]
        then docker compose -f "${local_configs}/$1/${local_compose}" down;
        else docker stop "$1" && docker container rm "$1"
        fi
        # echo
        }
    alias dcd="docker_local_stop"

    docker_local_bounce(){ docker_local_stop "$1" && docker_local_start "$1" ; }
    alias dcb="docker_local_bounce"

    # echo -e "\n>> docker local aliases and functions created <<";

############################ docker swarm functions ############################

    docker_list_stacks(){
        case "$1" in
            "-*")
                case "$1" in
                    "-a"|"--all")
                        docker stack ls ;;
                    "-e"|"--error")
                        docker stack ps --no-trunc --format "{{.Error}}" "${1}" ;;
                    *)
                        echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE '${cyn:?}--help${ylw:?}' OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; ;;
                esac ;;
            "")
                docker stack ls ;;
            *)
                docker stack services "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Ports}}" ;;
                # docker stack ps --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}" "${1}" ;;
        esac
        }
    alias dls="docker_list_stacks" # "docker list stacks"
    alias dlw="docker_list_stacks" # "docker list swarm apps"

    alias dwf="docker_folder_actions swarm"

    alias dwenv="fnc_env_create swarm"

    alias dwp="docker_folder_permissions swarm"

    docker_swarm_edit(){ nano "${swarm_configs}/$1/${swarm_compose}"; }
    alias dwe="docker_swarm_edit"

    docker_swarm_config(){ docker compose -f "${swarm_configs}/$1/${swarm_compose}" config; }
    alias dwc="docker_swarm_config"
    alias dwt="docker_swarm_config"

    alias dwg="docker_configs_list swarm"

    docker_swarm_logs(){ (cd "${swarm_configs}/$1" && docker compose logs -f); }
    alias dwl="docker_swarm_logs"

    docker_swarm_networks(){ docker_networks_create "swarm" "overlay"; }
    alias dwn="docker_swarm_networks"

    docker_swarm_start(){
        export configs_path="${swarm_configs}";
        if [[ -f "${swarm_configs}/$1/${swarm_compose}" ]]; then
            fnc_env_create "$1";
            docker stack deploy "${1}" -c "${swarm_configs}/${1}/${swarm_compose}" --prune;
        else echo "No docker swarm configuration file found for the \`$1\` application.";
        fi;
        # echo
        }
    alias dwu="docker_swarm_start"

    docker_swarm_stop(){
        if [[ -f "${swarm_configs}/$1/${swarm_compose}" && -f "${swarm_configs}/$1/.env" ]]
        then docker compose -f "${swarm_configs}/$1/${swarm_compose}" down;
        else docker stop "$1" && docker container rm "$1"
        fi
        # echo
        }
    alias dwd="docker_swarm_stop"

    docker_swarm_bounce(){ docker_swarm_stop "$1" && docker_swarm_start "$1" ; }
    alias dwb="docker_swarm_bounce"

    docker_list_swarm_nodes(){
        docker node ls -q | xargs docker node inspect   -f \
        'NODE={{ .Description.Hostname }}, IP={{ .Status.Addr }}, ROLE={{ .Spec.Role }}, STATE={{ .Status.State }}, AVAILABILITY={{ .Spec.Availability }}, ID={{ .ID }} :
        OS={{ .Description.Platform.OS }}, ARCH={{ .Description.Platform.Architecture }}, CPUs={{ .Description.Resources.NanoCPUs }}, RAM={{ .Description.Resources.MemoryBytes }}, DOCKER VERSION={{ .Description.Engine.EngineVersion }},
        LABELS={{ range $k, $v := .Spec.Labels }}{{ $k }}={{ $v }} {{end}}
        ';
        }
    alias dkwn="docker_list_swarm_nodes"

    # echo -e "\n>> docker swarm aliases and functions created <<"; echo;

################################################################################

    echo -e "\n >> ${blu:?}docker aliases and functions ${grn:?}created${def:?} <<\n";
