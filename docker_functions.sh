#!/bin/bash
################################################################################
# Place this file in $HOME/docker/ and name it docker_functions.sh
# A quick and easy way to do this is to run one of these download commands:
# wget 'https://raw.githubusercontent.com/QNAP-HomeLAB/docker-scripts/master/docker_functions' -O $HOME/docker/docker_functions.sh
# curl 'https://raw.githubusercontent.com/QNAP-HomeLAB/docker-scripts/master/docker_functions' > $HOME/docker/docker_functions.sh
# git archive --remote=https://github.com/QNAP-HomeLAB/docker-scripts.git HEAD:docker_functions $HOME/docker/docker_functions.sh | tar -xvf -
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

################################################################################
##################### NOTHING BELOW HERE SHOULD BE CHANGED #####################
################################################################################

####################### docker uid/gid/directories setup #######################

    ## alias to easily source this file
    alias dkfnc='. $HOME/.docker_fnc'

    ## configuration types
    export docker_config_types=("build" "local" "swarm")

    export docker_fnc_file="$docker_dir/docker_functions"
    export docker_env_file="$docker_dir/.docker.env"
    export docker_env_example="$docker_dir/docker.env.example"

    ## docker secrets path
    export docker_secrets="$docker_dir/secrets"

    ## docker build folders
    export build_path="$docker_dir/build"
    export build_appdata="$build_path/appdata"
    export build_configs="$build_path/configs"
    export build_compose="compose.yml"
    # declare -A build_scope
    # build_scope[data]="${build_path}/appdata"
    # build_scope[conf]="${build_path}/configs"
    # build_scope[file]="compose.yml"

    ## docker compose local
    export local_path="$docker_dir/local"
    export local_appdata="$local_path/appdata"
    export local_configs="$local_path/configs"
    export local_compose="compose.yml"
    # declare -A local_scope
    # local_scope[data]="${local_path}/appdata"
    # local_scope[conf]="${local_path}/configs"
    # local_scope[file]="compose.yml"

    ## docker swarm configs folders
    export swarm_path="$docker_dir/swarm"
    export swarm_appdata="$swarm_path/appdata"
    export swarm_configs="$swarm_path/configs"
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
    docker_uid=$(id -u "${docker_usr:-docker}") # docker UID (1000)
    export docker_uid #&& echo "DEBUG: docker UID: ${docker_uid}"
    docker_gid=$(id -g "${docker_usr:-docker}") # docker GID (1000)
    export docker_gid #&& echo "DEBUG: docker GID: ${docker_gid}"

    ## folder and file permissions
    export perms_cert='a-rwx,u=rwX,g=,o=' # 600 # -rw-rw----
    export perms_conf='a-rwx,u+rwX,g=rwX,o=rX' # 664 # -rw-rw-r--
    export perms_data='a-rwx,u+rwX,g=rwX,o=' # 660 # -rw-rw----
    # export docker_dir'a=rwx,o-w' # 775 # -rwxrwxr-x

    # might want to consolidate these with scope config vars above
    set_scope_vars(){
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
            (*) msg_error "INVALID CONFIG TYPE" "Please inform the script maintainer."; return;;
        esac
        }

    ## check if sudo is needed for some commands used in these custom docker functions
    if [[ $(id -u) -ne 0 ]]; then var_sudo="$(command -v sudo 2>/dev/null) "; else var_sudo=""; fi; #unset var_sudo; fi;

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
    fnc_dir_create(){ if [[ ! -d "$1" ]]; then ${var_sudo}install -o "${docker_uid}" -g "${docker_gid}" -m "$2" -d "$1"; fi; }

    fnc_dir_create "${docker_secrets}" "${perms_data}"
    fnc_dir_create "${local_appdata}" "${perms_data}"
    fnc_dir_create "${local_configs}" "${perms_conf}"
    fnc_dir_create "${swarm_appdata}" "${perms_data}"
    fnc_dir_create "${swarm_configs}" "${perms_conf}"

    ## separate option from args
    fnc_extract_option(){ # USAGE: fnc_extract_option $@
        local args=()
        local opts=()
        ## iterate through arguments
        # echo -e "\n fnc_extract_option args: $*"
        for arg in "$@"; do
            if [[ $arg = "." ]]; then continue;
            elif [[ $arg == "-*" ]]; then opts+=("$arg");
            else args+=("$arg");
            fi
        done
        ## validate option count
        if [[ ${#opts[@]} -gt 1 ]]; then
            msg_error "More than one opts found." "Check \`--help\` for usage syntax.";
            return 1;
        else ## export arrays
            operands=("${args[@]}"); #echo "operands: ${operands[*]}";
            option=("${opts[@]}") ; #echo "option: ${option[*]}";
        fi
        }

    ## Download file if it doesn't exist already, then optionally create a symlink
    fnc_file_download(){ # USAGE: fnc_file_download <url> <filepath> [symlink]
        # echo -e "\n fnc_file_download args: $*"
        fnc_extract_option "$@";
        local file_url="${operands[0]}"; #echo "file_url: $file_url";
        local filename="${operands[1]}"; #echo "filename: $filename";
        local filelink="${operands[2]}"; #echo "filelink: $filelink";
        # local file_url="${1}";
        # local filename="${2}";
        # local filelink="${3}";

        if [[ -f "$filename" ]]; then
            case "${option}" in
                ("-f"|"--force")
                    var_force="-N ";
                    # wget -N "$file_url" -O "$filename"
                    ;;
                (*) # msg_info "File \`${filename}\` already exists." "Use option \`--force\` to overwrite.";
                    return;;
            esac
        elif ! wget "${var_force}""$file_url" -O "$filename"; then
            msg_failure "DOWNLOAD FAILED" "check url: $file_url"; return 1;
        fi
        if [[ -n "$filelink" ]]; then
            ${var_sudo:-""}install -o "${docker_uid}" -g "${docker_gid}" -m "${perms_conf}" "$filename" "$filelink";
        fi
        }

    fnc_file_download "https://raw.githubusercontent.com/drauku/bash-scripts/master/.bash_env" "$HOME/.bash_env";
    fnc_file_download "https://raw.githubusercontent.com/drauku/bash-scripts/master/docker.env.example" "$docker_env_example" "$docker_env_file";

        # if [[ ! -f "$filename" ]]; then
        #     if ! wget "$file_url" -O "$filename";
        #     then msg_failure "Failed to download" "$file_url"; return 1;
        #     fi;
        # fi

    ## create blank .docker.env if download fails
    if [[ ! -f "$docker_env_file" ]]; then ${var_sudo}install -o "${docker_uid}" -g "${docker_gid}" -m "${perms_data}" /dev/null "$docker_env_file"; fi;

    ## symlink verification function
    fnc_verify_symlink(){ if [[ ! -f "$1" ]]; then ln -s "$2" "$1"; fi; }

    ## create the $HOME/.docker_fnc symlink if it does not exist
    fnc_verify_symlink "$HOME/.docker_fnc" "$docker_dir/docker_functions"

    fnc_verify_action(){ ## usage fnc_verify_action <message>
        msg_alert "" "$1";
        while read -r -p " >> CONTINUE? [y/N] <<" input; do
            case "${input:-N}" in
                ([yY]|[yY][eE][sS]) return 0;;
                ([nN]|[nN][oO]) return 1;;
                (*) msg_failure "Invalid input" "Please enter 'y' or 'n'";;
                # echo -e " > invalid input <"; return 1; ;;
            esac
        done
        }

    fnc_check_app(){ if test -z "$1"; then msg_warning "No application name specified." "Application name required."; return; fi; }
        # echo; echo " > Application name must be specified. Nothing to do."; echo; return; fi; }

    fnc_check_dir(){ if test ! -d "$1"; then msg_warning "Docker container directory does not exist." "Use \`dcf $1\` to create."; return; fi; }
        # echo -e " > \`$1\` docker container directory does not exist <"; return 1; fi; }

    fnc_appname_validate(){
        fnc_check_app "$1";
        if [[ ${1:0:1} =~ ^[_-]+$ ]] || [[ ! ${1} =~ ^[a-zA-Z0-9_-]+$ ]];
        then msg_warning "Invalid application name." "Only alphanumeric characters, underscores, and hyphens allowed."; return 1;
        else return 0; # container name only contains valid characters
        fi;
        }

    fnc_configs_list(){ ## USAGE: fnc_configs_list <config_type>
        fnc_extract_option "$@";
        local config_type="${operands[0]}";
        set_scope_vars "$config_type";
        ## find config dirs or files
        case "${option}" in
            (-d|--dir*|--folder)
                mapfile -t config_list < <(find "$configs_path" -maxdepth 1 -type d -not -path '*/\.*');;
            (*)
                mapfile -t config_list < <(find "$configs_path" -maxdepth 2 -type f -name "$config_file" | sed 's|/[^/]*$||');;
        esac
        ## print config list
        if [[ "${#config_list[@]}" -eq 0 ]];
        then msg_warning "No $config_type configs found." "Use \`dcf/dwf $<appname>\` to create one."; return;
        else echo -e " > DOCKER CONFIG LIST FOR \`$config_type\` CONTAINERS <\n ${config_list[*]}";
        fi
        }

# #################### general docker functions ####################

    ## docker network list function
    docker_list_networks(){ docker network ls; echo; }
    alias dln="docker_list_networks"

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
        if [[ -n "$(which curl)" ]]; then dl_cmd="curl"; fi
        if [[ -n "$(which wget)" ]]; then dl_cmd="wget -qO-"; fi
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

    docker_file_permissions(){
        case "${1}" in
            ("-a"|"--all") files_dir="${configs_path}" ;;
            (*) files_dir="${configs_path}/${1}" ;;
        esac
        # update restricted access file permissions to 600
        files_restricted=("acme.json" "*.crt" "*.key" "*.pub" "*.ppk" "*.pem");
        for file in "${files_restricted[@]}"; do
            ${var_sudo}find "$files_dir" -iname "$file" -type f -exec chmod "$perms_cert" {} +
        done
        # update limited access file permissions to 660
        files_limited=(".conf" "*.env" ".log" "*.secret");
        for file in "${files_limited[@]}"; do
            ${var_sudo}find "$files_dir" -iname "$file" -type f -exec chmod "${perms_data}" {} +
        done
        # # update general access file permissions to 664
        # files_general=("*.yml" "*.yaml" "*.toml");
        # for file in "${files_general[@]}"; do
        #     ${var_sudo}find "$docker_dir" -iname "$file" -type f -exec chmod "${perms_conf}" {} +
        # done
        }
    update_file_permissions(){ # usage: update_file_permissions [option] <permissions> <file list>
        fnc_extract_option "${@}";
        perms="${operands[0]}"; shift;
        files_list=("$@");

        case "${1}" in
            (-*) option="${1}"; shift;
                case "${option}" in
                    ("-a"|"--all") files_dir="${configs_path}" ;;
                    (*) msg_error "Invalid option: ${option}"; return 1;;
                esac
                ;;
            (*) files_dir="${configs_path}/${1}" ;;
        esac
        for file in "${files_list[@]}"; do
            ${var_sudo}find "$files_dir" -iname "$file" -type f -exec chmod "$perms" {} +
        done
        }
    # # files_list=("acme.json" "*.crt" "*.key" "*.pub" "*.ppk" "*.pem");
    # update_file_permissions "$perms_cert" "acme.json" "*.crt" "*.key" "*.pub" "*.ppk" "*.pem";

    docker_folder_permissions(){
        fnc_check_app "$1";
        for stack in ${1}; do
            case "${stack}" in
                ("-a"|"--all")
                    ## update all docker folder ownership
                    ${var_sudo}chown -R "${docker_uid}:${docker_gid}" "${docker_dir:?}";
                    ## update appdata folder permissions
                    dirs_list=("${local_appdata}" "${swarm_appdata}" "${docker_secrets}");
                    for dir in "${dirs_list[@]}"; do ${var_sudo}chmod -R "${perms_data}" "${dir:?}"; done; # -rwXrwX---
                    ## update config folder permissions
                    dirs_list=("${local_configs}" "${swarm_configs}");
                    for dir in "${dirs_list[@]}"; do ${var_sudo}chmod -R "${perms_conf}" "${dir:?}"; done; # -rwXrwXr-X
                    ## update all docker file permissions
                    docker_file_permissions --all;
                    echo -e " > \`ALL\` docker subdirectory and file permissions updated <"
                    ;;
                (*) # update specified docker folder permissions
                    appdata_path="${appdata_path:?}/${stack}";
                    appconf_dir="${configs_path:?}/${stack}";
                    if [[ ! -d "${appconf_dir:?}" ]]; then echo -e " > \`${appconf_dir:?}\` docker container directory does not exist <"; return; fi;
                    ## appdata folder and file permissions
                    ${var_sudo}chown -R "${docker_uid}:${docker_gid}" "${appdata_path:?}";
                    ${var_sudo}chmod -R "${perms_data}" "${appdata_path:?}";
                    ## local folder and file permissions
                    ${var_sudo}chown -R "${docker_uid}:${docker_gid}" "${appconf_dir:?}";
                    ${var_sudo}chmod -R "${perms_conf}" "${appconf_dir:?}";
                    # echo -e "\n  ${ylw:?}UPDATED ${blu:?}${appdata_path:?}/${mgn:?}${stack}${def:?} AND ${blu:?}${docker_local:?}/${mgn:?}${stack}${def:?} docker_folders AND FILE PERMISSIONS ${def:?}";
                    docker_file_permissions "${stack}";
                    echo -e " > \`${stack}\` docker container subdirectory and file permissions updated <";
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

########################## docker_files and docker_folders ############################

    fnc_env_create(){
        echo " 'fnc_env_create' configs_path: $configs_path"
        case "${1}" in
            "-c"|"--copy"|"-f"|"--force") # force copy `.docker.env` to `..configs/$1/.env`
                ${var_sudo}install -o "${docker_uid}" -g "${docker_gid}" -m "${perms_data}" "$docker_env_file" "${configs_path}/$2/.env";
                ;;
            "-r"|"--remove") # remove `..configs/$1/.env`
                ${var_sudo}rm -f "${configs_path}/$2/.env";
                ;;
            *) # symlink .env to .docker.env.example if it does not exist
                if [[ ! -f "${configs_path}/$1/.env" ]]; then
                    ln -s "$docker_env_file" "${configs_path}/$1/.env"; # symlinks .env to .docker.env
                fi
                ;;
        esac
        }
    docker_folders_create(){
        set_scope_vars "$1"; shift;
        for stack in "${operands[@]}"; do
            docheck=0;
            fnc_check_app "$stack";
            if [[ -d "${appdata_path}/${stack}" ]]; then
                msg_warning "UHOH!" " \`${appdata_path:?}/${stack}}\` already exists." #"Use option \`--force\` to overwrite."
                docheck=$((docheck + 1));
            else # create docker container data directory
                if fnc_appname_validate "${stack}"; then
                    # echo -e " > Creating directory for the \` ${appdata_path}/${stack} \` container <"; echo;
                    fnc_dir_create "${appdata_path}/${stack}" "${perms_data}"
                    msg_success "CREATED" " \`${appdata_path}/${stack}\` data directory.";
                fi;
            fi;
            if [[ -d "${configs_path}/${stack}" ]]; then
                msg_warning "UHOH!" " \`${configs_path:?}/${stack}}\` already exists." #"Use option \`--force\` to overwrite."
                docheck=$((docheck + 2));
            else # create docker container config directories and files
                if fnc_appname_validate "${stack}"; then
                    # echo -e " > Creating directories and files for the \` ${configs_path}/${stack} \` container <"; echo;
                    fnc_dir_create "${configs_path}/${stack}" "${perms_conf}"
                    fnc_env_create "${stack}";
                    ${var_sudo}install -o "${docker_uid}" -g "${docker_gid}" -m "${perms_conf}" /dev/null "${configs_path}/${stack}/${config_file}";
                    msg_success "CREATED" " \`${configs_path}/${stack}\` configs directory and files.";
                fi;
            fi;
            case "$docheck" in
                "1") echo " > Docker appdata directory for \`${appdata_path:?}/${stack}\` already exists.";;
                "2") echo " > Docker configs directory for \`${configs_path:?}/${stack}\` already exists.";;
                "3") echo " > Docker appdata and configs directories for the \`${stack}\` application already exist.";;
            esac
        done
        echo
        }
    docker_folders_delete(){
        for stack in "${operands[@]}"; do
            if ! fnc_verify_action " > This will forcefully delete all \`${stack}\` application directories and files."; then return; fi;
            fnc_check_app "${stack}";
            docheck=0;
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
        echo;
        }
    docker_folder_actions(){
        fnc_extract_option "$@"
        case "${option}" in
            (-*) # perform optional action
                case "${option}" in
                    "-c"|"--create") docker_folders_create "$@" ;;
                    "-d"|"--delete") docker_folders_delete "$@" ;;
                    "-r"|"--remove") docker_folders_delete "$@" ;;
                    *) echo " > Invalid option \`${option}\` used."; echo;
                esac
                ;;
            (*) docker_folders_create "$@" ;;
        esac;
        }

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

    docker_local_folders(){
        # export appdata_path="${local_appdata}";
        # export configs_path="${local_configs}";
        # export config_type="local";
        docker_folder_actions "local" "$@";
        }
    alias dcf='docker_local_folders'

    docker_local_env(){
        export configs_path="${local_configs}";
        fnc_env_create "$@";
        }
    alias dcenv='docker_local_env'

    docker_local_permissions(){
        # export appdata_path="${local_appdata}";
        # export configs_path="${local_configs}";
        # export config_type="local";
        docker_folder_permissions "local" "$@";
    }
    alias dcp="docker_local_permissions"

    docker_local_edit(){ nano "${local_configs}/$1/${local_compose}"; }
    alias dce="docker_local_edit"

    docker_local_config(){ docker compose -f "${local_configs}/$1/${local_compose}" config; }
    alias dcc="docker_local_config"
    alias dct="docker_local_config"

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
            echo;
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
        echo
        }
    alias dcd="docker_local_stop"

    docker_local_bounce(){ docker_local_stop "$1" && docker_local_start "$1" ; }
    alias dcb="docker_local_bounce"

    # echo -e "\n>> docker local aliases and functions created <<";

############################ docker swarm functions ############################

    docker_list_stacks(){
        case "$1" in
            "none")
                fnc_stack_lst(){ docker stack ls; }
                fnc_stack_svc(){ docker stack services "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Ports}}"; }
                fnc_stack_err(){ docker stack ps --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}" "${1}"; }
                fnc_stack_chk(){ docker stack ps --no-trunc --format "{{.Error}}" "${1}"; }
                ;;
            "-a"|"--all")
                docker stack ls;;
            "")
                docker stack ls --format "table {{.Name}}\t{{.Description}}";;
            *)
                docker stack services "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Ports}}";;
        esac

        }
    alias dls="docker_list_stacks" # "docker list stacks"
    alias dlw="docker_list_stacks" # "docker list swarm apps"

    docker_swarm_folders(){
        # export appdata_path="${swarm_appdata}";
        # export configs_path="${swarm_configs}";
        # export config_type="swarm";
        docker_folder_actions "swarm" "$@";
        }
    alias dwf="docker_swarm_folders"

    docker_swarm_env(){
        # export configs_path="${swarm_configs}";
        # export config_type="swarm";
        fnc_env_create "swarm" "$@";
        }
    alias dwenv="docker_swarm_env"

    docker_swarm_permissions(){
        # export appdata_path="${swarm_appdata}";
        # export configs_path="${swarm_configs}";
        # export config_type="swarm";
        docker_folder_permissions "swarm" "$@";
    }
    alias dwp="docker_swarm_permissions"

    docker_swarm_edit(){ nano "${swarm_configs}/$1/${swarm_compose}"; }
    alias dwe="docker_swarm_edit"

    docker_swarm_config(){ docker compose -f "${swarm_configs}/$1/${swarm_compose}" config; }
    alias dwc="docker_swarm_config"
    alias dwt="docker_swarm_config"

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
        echo;
        }
    alias dwu="docker_swarm_start"

    docker_swarm_stop(){
        if [[ -f "${swarm_configs}/$1/${swarm_compose}" && -f "${swarm_configs}/$1/.env" ]]
        then docker compose -f "${swarm_configs}/$1/${swarm_compose}" down;
        else docker stop "$1" && docker container rm "$1"
        fi
        echo
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

    echo -e " >> ${blu:?}docker aliases and functions ${grn:?}created${def:?} <<\n";

