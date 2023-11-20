#!/bin/bash
################################################################################
######### --> **** UPDATE THESE VARIABLES FOR YOUR ENVIRONMENT **** <-- ########

export docker_usr="docker"
export docker_grp="docker"
export docker_dir="$HOME/docker"

################################################################################
##################### NOTHING BELOW HERE SHOULD BE CHANGED #####################
################################################################################

################################################################################
####################### docker uid/gid/directories setup #######################

# alias to easily source this file
alias dkfnc='. $ln_source'

# docker directory structure
export docker_appdata="$docker_dir/appdata"
export docker_compose="$docker_dir/compose"
export docker_secrets="$docker_dir/secrets"
export docker_swarm="$docker_dir/swarm"

## assign docker UID and GID variables
docker_uid=$(id -u "$docker_usr") # docker UID (1000)
export docker_uid #&& echo "DEBUG: docker UID: $docker_uid"
docker_gid=$(id -g "$docker_usr") # docker GID (1000)
export docker_gid #&& echo "DEBUG: docker GID: $docker_gid"

# folder and file permissions
export perms_cert="a-rwx,u=rwX,g=,o=" # 600 # -rw-rw----
export perms_conf="a-rwx,u+rwX,g=rwX,o=rX" # 664 # -rw-rw-r--
export perms_data="a-rwx,u+rwX,g=rwX,o-rX" # 660 # -rw-rw----
# export dk_dir="" # 775 # -rwxrwxr-x

# check if sudo is needed for some commands used in these custom docker functions
if [[ $(id -u) -ne 0 ]]; then var_sudo="$(command -v sudo 2>/dev/null) "; else unset var_sudo; fi;

# create the $HOME/.docker_fnc symlink if it does not exist
ln_source="$HOME/.docker_fnc"
ln_target="$docker_dir/docker_functions"
if [[ ! -f "$ln_source" ]]; then ln -s "$ln_target" "$ln_source"; fi;

# create docker directory structure and .docker.env if they don't exist
if [[ ! -d "$docker_appdata" ]]; then ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_data" -d "$docker_dir/appdata"; fi
if [[ ! -d "$docker_compose" ]]; then ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_conf" -d "$docker_dir/compose"; fi
if [[ ! -d "$docker_secrets" ]]; then ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_data" -d "$docker_dir/secrets"; fi
# if [[ ! -d "$docker_stacks" ]]; then ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_conf" -d "$docker_dir/stacks"; fi
if [[ ! -d "$docker_swarm" ]]; then ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_conf" -d "$docker_dir/swarm"; fi

# check if docker.env exists and download if it doesn't otherwise create a blank .docker.env
docker_env_url="https://raw.githubusercontent.com/drauku/bash-scripts/master/docker.env.example"
docker_env_example="$docker_dir/docker.env.example"
docker_env="$docker_dir/.docker.env"
if [[ ! -f "$docker_env" ]]; then
    if [[ ! -f "$docker_env_example" ]]; then
        if ! wget $docker_env_url -O "$docker_env_example"; then
        echo "ERROR: Failed to download $docker_env_url";
        ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_data" /dev/null "$docker_env";
        fi;
    else
        ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_data" "$docker_env_example" "$docker_env";
    fi
fi;

################################################################################
########################### general docker functions ###########################

lda(){ echo "ls $docker_appdata"; ls "$docker_appdata"; echo; }
appdata(){ cd "$docker_appdata/$1" || echo; return; }
alias dka="appdata"
ldc(){ echo "ls $docker_compose"; ls "$docker_compose"; echo; }
compose(){ cd "$docker_compose/$1" || echo; return; }
alias dkc="compose"
lds(){ echo "ls $docker_secrets"; ls "$docker_secrets"; echo; }
secrets(){ cd "$docker_secrets/$1" || echo; return; }
alias dks="secrets"
ldw(){ echo "ls $docker_swarm"; ls "$docker_swarm"; echo; }
swarm(){ cd "$docker_swarm/$1" || echo; return; }
alias dkw="swarm"

vpncheck(){ echo " > Host IP: $(wget -qO- ifconfig.me)" && echo "Container IP: $(docker container exec -it "${*}" wget -qO- ipinfo.io)"; }
ipcheck(){ echo " > Container IP: $(docker container exec -it "${*}" curl ipinfo.io)"; }

fnc_check_app(){ if [[ "$1" == "" ]]; then echo; echo " > Application name must be specified. Nothing to do."; echo; return; fi; }
fnc_check_dir(){ if [[ ! -d "$1" ]]; then echo -e " > \`$1\` docker container directory does not exist <"; return 1; fi; }

fnc_appname_validate(){
    if [[ ${1:0:1} =~ ^[_-]+$ ]] || [[ ! ${1} =~ ^[a-zA-Z0-9_-]+$ ]];
    then echo -e " > \`$1\` is an invalid docker container name <"; return 1;
    else return 0; # container name only contains valid characters
    fi;
    }

fnc_verify_action(){
    while read -r -p "$2" input; do
        case "${input:-N}" in
            ([yY]|[yY][eE][sS]) return 0; ;;
            ([nN]|[nN][oO]) return 1; ;;
            (*) echo -e " > invalid input <"; return 1; ;;
        esac
    done
    }

docker_file_permissions(){
    case "${1}" in
        ("-a"|"--all") # update all docker file permissions
            files_dir="${configs_dir}" ;;
        (*) # update specific docker file permissions
            files_dir="${configs_dir}/${1}" ;;
    esac
    # update restricted access file permissions to 600
    files_restricted=("acme.json" "*.crt" "*.key" "*.pub" "*.ppk" "*.pem");
    for file in "${files_restricted[@]}"; do
        ${var_sudo}find "$files_dir" -iname "$file" -type f -exec chmod "$perms_cert" {} +
    done
    # update limited access file permissions to 660
    files_limited=(".conf" "*.env" ".log" "*.secret");
    for file in "${files_limited[@]}"; do
        ${var_sudo}find "$files_dir" -iname "$file" -type f -exec chmod "$perms_data" {} +
    done
    # # update general access file permissions to 664
    # files_general=("*.yml" "*.yaml" "*.toml");
    # for file in "${files_general[@]}"; do
    #     ${var_sudo}find "$docker_dir" -iname "$file" -type f -exec chmod "$perms_conf" {} +
    # done
    }
docker_folder_permissions(){
    fnc_check_app "$1";
    for stack in ${1}; do
        case "${stack}" in
            ("-a"|"--all") # update all docker folder permissions
            ${var_sudo}chown -R "${docker_uid}:${docker_gid}" "${docker_dir:?}";
            ${var_sudo}chmod -R "${perms_data}" "${docker_appdata:?}"; # -rwXrwX---
            ${var_sudo}chmod -R "${perms_conf}" "${docker_compose:?}"; # -rwXrwXr-X
            ${var_sudo}chmod -R "${perms_data}" "${docker_secrets:?}"; # -rwXrwX---
            ${var_sudo}chmod -R "${perms_conf}" "${docker_swarm:?}"; # -rwXrwXr-X
            docker_file_permissions --all;
            echo -e " > \`ALL\` docker subdirectory and file permissions updated <"
            ;;
            (*) # update specified docker folder permissions
            appdata_dir="${docker_appdata:?}/${stack}";
            appconf_dir="${configs_dir:?}/${stack}";
            if [[ ! -d "${appconf_dir:?}" ]]; then echo -e " > \`${appconf_dir:?}\` docker container directory does not exist <"; return; fi;
            ## appdata folder and file permissions
            ${var_sudo}chown -R "${docker_uid}:${docker_gid}" "${appdata_dir:?}";
            ${var_sudo}chmod -R "${perms_data}" "${appdata_dir:?}";
            ## compose folder and file permissions
            ${var_sudo}chown -R "${docker_uid}:${docker_gid}" "${appconf_dir:?}";
            ${var_sudo}chmod -R "${perms_conf}" "${appconf_dir:?}";
            # echo -e "\n  ${ylw:?}UPDATED ${blu:?}${docker_appdata:?}/${mgn:?}${stack}${def:?} AND ${blu:?}${docker_compose:?}/${mgn:?}${stack}${def:?} FOLDERS AND FILE PERMISSIONS ${def:?}";
            docker_file_permissions "${stack}";
            echo -e " > \`${stack}\` docker container subdirectory and file permissions updated <";
            ;;
        esac
    done;
    }

docker_env_create(){
    case "${1}" in
        "-c"|"--copy"|"-f"|"--force") # force copy .docker.env.example to .docker.env
            ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_data" "$docker_env" "$configs_dir/$2/.env";
            ;;
        *) # symlink .env to .docker.env.example if it does not exist
            if [[ ! -f "$configs_dir/$1/.env" ]]; then
                ln -s "$docker_env" "$configs_dir/$1/.env"; # symlinks .env to .docker.env
            fi
            ;;
    esac
    }

docker_folders_create(){
    fnc_check_app "$1";
    docheck=0;
    if [[ -d "$configs_dir/$1" ]]; then docheck=$((docheck + 1));
    else # create docker container config directories and files
        # if [[ $1 =~ ^[compose]+$ ]];
        # then export configs_dir="$docker_compose";
        # elif [[ $1 =~ ^[swarm]+$ ]];
        # then export configs_dir="$docker_swarm";
        # fi;
        if fnc_appname_validate "$1"; then
            # echo -e " > Creating directories and files for the \` $configs_dir/$1 \` container <"; echo;
            ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_conf" -d "$configs_dir/$1";
            ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_conf" /dev/null "$configs_dir/$1/compose.yml";
            docker_env_create "$1";
            echo " > Docker config directories and files created for the \`$1\` application.";
        fi;
    fi;
    if [[ -d "$docker_appdata/$1" ]]; then docheck=$((docheck + 2));
    else # create docker container data directory
        if fnc_appname_validate "$1"; then
            ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_data" -d "$docker_appdata/$1";
            echo " > Docker appdata directory created for the \`$1\` application.";
        fi;
    fi;
    case "$docheck" in
        "1") echo " > Docker config directory for \`$configs_dir/$1\` already exists.";;
        "2") echo " > Docker data directory for \`$docker_appdata/$1\` already exists.";;
        "3") echo " > Docker config and data directories for the \`$1\` application already exist.";;
    esac
    echo
    }
docker_folders_delete(){
    if ! fnc_verify_action "$1" " > This will forcefully delete all \`$1\` application directories and files. Continue? [y/N] "; then return; fi; echo;
    fnc_check_app "$1";
    docheck=0;
    if [[ -d "${docker_appdata:?}/$1" ]];
    then
        rm -rf "${docker_appdata:?}/$1"; #docheck=$((docheck+1));
        echo " > \`${docker_appdata:?}/$1\` and contents deleted.";
    else echo " > \`$docker_appdata/$1\` does not exists. Nothing to remove."; echo;
    fi;
    if [[ -d "${configs_dir:?}/$1" ]];
    then
        rm -rf "${configs_dir:?}/$1"; #docheck=$((docheck+1));
        echo " > \`${configs_dir:?}/$1\` and contents deleted.";
    else echo " > \`$configs_dir/$1\` does not exists. Nothing to remove."; echo;
    fi;
    # if [[ $configs_dir =~ ^[compose]+$ ]]; then
    #     if [[ -d "$docker_compose/$1" ]];
    #     # then rm -rf "${docker_compose:?}/$1";
    #     then echo "DEBUG: rm -rf ${docker_compose:?}/$1";
    #     else echo " > \`$1\` does not exists. Nothing to remove."; echo;
    #     fi;
    # fi;
    # if [[ $configs_dir =~ ^[swarm]+$ ]]; then
    #     if [[ -d "$docker_swarm/$1" ]];
    #     # then rm -rf "${docker_swarm:?}/$1";
    #     then echo "DEBUG: rm -rf ${docker_swarm:?}/$1";
    #     else echo " > \`$1\` does not exists. Nothing to remove."; echo;
    #     fi;
    # fi;
    # if [[ $docheck -eq 0 ]]; then echo " > \`$1\` docker container subdirectories and files deleted."; echo; fi;
    echo;
    }
docker_folder_actions(){
    case "$1" in
        -*) # perform optional action
            case "$1" in
                "-c"|"--create") docker_folders_create "$2" ;;
                "-d"|"--delete") docker_folders_delete "$2" ;;
                "-r"|"--remove") docker_folders_delete "$2" ;;
                *) echo " > Invalid option \`$1\` used."; echo;
            esac
            ;;
        *) docker_folders_create "$@" ;;
    esac;
    }

################################################################################
########################### docker compose functions ###########################

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

docker_compose_folders(){
    export configs_dir="$docker_compose";
    docker_folder_actions "$@";
    }
alias dcf='docker_compose_folders'

docker_compose_env(){
    export configs_dir="$docker_compose";
    docker_env_create "$@";
    }
alias dcenv='docker_compose_env'

docker_compose_permissions(){
    export configs_dir="$docker_compose";
    docker_folder_permissions "$1";
}
alias dcp="docker_compose_permissions"

docker_compose_edit(){ nano "$docker_compose/$1/compose.yml"; }
alias dce="docker_compose_edit"

docker_compose_config(){ docker compose -f "$docker_compose/$1/compose.yml" config; }
alias dcc="docker_compose_config"
alias dct="docker_compose_config"

docker_compose_logs(){ (cd "$docker_compose/$1" && docker compose logs -f); }
alias dcl="docker_compose_logs"

docker_compose_networks(){
    docker network create --driver "bridge" --opt "encrypted" --scope "local" --subnet "172.20.0.0/16" --gateway "172.20.0.254" --attachable "docker_socket"
    docker network create --driver "bridge" --opt "encrypted" --scope "local" --subnet "172.21.1.0/16" --gateway "172.21.0.254" --attachable "external_edge"
    docker network create --driver "bridge" --opt "encrypted" --scope "local" --subnet "172.22.2.0/16" --gateway "172.22.0.254" --attachable "reverse_proxy"
    echo "The \`docker_socket\`, \`external_edge\`, and \`reverse_proxy\` docker bridge networks exist or were created."; echo
}
alias dcn="docker_compose_networks"

docker_list_networks(){ docker network ls; }
alias dln="docker_list_networks"

fnc_strip_option(){ export applist=( "${applist[@]:1}" ); } # remove first element

docker_compose_start(){
    applist=( "$*" )
    export configs_dir="$docker_compose";
    fnc_compose_start(){
        for app in "$@"; do
            if [[ -f "$docker_compose/$app/compose.yml" ]]; then
                docker_env_create "$app";
                docker compose -f "$docker_compose/$app/compose.yml" up -d --remove-orphans;
            else echo " > No docker compose configuration file found for the \`$app\` application.";
            fi;
        done
        echo;
        }
    case "$1" in
        -*) # perform optional action
            case "$1" in
                "-l"|"--logs")
                    fnc_strip_option "$@"
                    fnc_compose_start "${applist[@]}"
                    docker_compose_logs "${2:-${applist[1]}}";
                    ;;
                *) echo "Invalid option: \`$1\`"; echo;
            esac
            ;;
        *)
            fnc_compose_start "${applist[@]}"
            ;;
    esac
    }
alias dcu="docker_compose_start"

docker_compose_stop(){
    if [[ -f "$docker_compose/$1/compose.yml" && -f "$docker_compose/$1/.env" ]]
    then docker compose -f "$docker_compose/$1/compose.yml" down;
    else docker stop "$1" && docker container rm "$1"
    fi
    echo
    }
alias dcd="docker_compose_stop"

docker_compose_bounce(){ docker_compose_stop "$1" && docker_compose_start "$1" ; }
alias dcb="docker_compose_bounce"

# echo -e "\n>> docker compose aliases and functions created <<";

################################################################################
############################ docker swarm functions ############################

docker_list_stacks(){
    case "$1" in
        "-a"|"--all")
            docker stack ls;;
        *)
            docker stack ls --format "table {{.Name}}\t{{.Description}}";;
    esac
    }
alias dls="docker_list_stacks" # "docker list stacks"
alias dlw="docker_list_stacks" # "docker list swarm apps"

docker_swarm_folders(){
    export configs_dir="$docker_swarm";
    docker_folder_actions "$@";
    }
alias dwf="docker_swarm_folders"

docker_swarm_env(){
    export configs_dir="$docker_swarm";
    docker_env_create "$@";
    }
alias dwenv="docker_swarm_env"

docker_swarm_permissions(){
    export configs_dir="$docker_swarm";
    docker_folder_permissions "$1";
}
alias dwp="docker_swarm_permissions"

docker_swarm_edit(){ nano "$docker_swarm/$1/compose.yml"; }
alias dwe="docker_swarm_edit"

docker_swarm_config(){ docker compose -f "$docker_swarm/$1/compose.yml" config; }
alias dwc="docker_swarm_config"
alias dwt="docker_swarm_config"

docker_swarm_logs(){ (cd "$docker_swarm/$1" && docker compose logs -f); }
alias dwl="docker_swarm_logs"

docker_swarm_networks(){
    docker network create --driver "overlay" --opt "encrypted" --scope "swarm" --subnet "172.20.0.0/16" --gateway "172.20.0.254" --attachable "docker_socket"
    docker network create --driver "overlay" --opt "encrypted" --scope "swarm" --subnet "172.21.0.0/16" --gateway "172.21.0.254" --attachable "external_edge"
    docker network create --driver "overlay" --opt "encrypted" --scope "swarm" --subnet "172.22.0.0/16" --gateway "172.22.0.254" --attachable "reverse_proxy"
    echo "The \`docker_socket\`, \`external_edge\`, and \`reverse_proxy\` docker overlay networks exist or were created."; echo
}
alias dwn="docker_swarm_networks"

docker_swarm_start(){
    if [[ -f "$docker_swarm/$1/compose.yml" ]]; then
        docker_env_create "$1";
        docker stack deploy "${1}" -c "${docker_swarm}/${1}/compose.yml" --prune;
    else echo "No docker swarm configuration file found for the \`$1\` application.";
    fi;
    echo;
    }
alias dwu="docker_swarm_start"

docker_swarm_stop(){
    if [[ -f "$docker_swarm/$1/compose.yml" && -f "$docker_swarm/$1/.env" ]]
    then docker compose -f "$docker_swarm/$1/compose.yml" down;
    else docker stop "$1" && docker container rm "$1"
    fi
    echo
    }
alias dwd="docker_swarm_stop"

docker_swarm_bounce(){ docker_swarm_stop "$1" && docker_swarm_start "$1" ; }
alias dwb="docker_swarm_bounce"

docker_list_swarm_nodes(){ docker node ls -q | xargs docker node inspect   -f '{{ .ID }} [hostname={{ .Description.Hostname }}, Addr={{ .Status.Addr }}, State={{ .Status.State }}, Role={{ .Spec.Role }}, Availability={{ .Spec.Availability }}]: Arch={{ .Description.Platform.Architecture }}, OS={{ .Description.Platform.OS }}, NanoCPUs={{ .Description.Resources.NanoCPUs }}, MemoryBytes={{ .Description.Resources.MemoryBytes }}, docker_version={{ .Description.Engine.EngineVersion }}, labels={{ range $k, $v := .Spec.Labels }}{{ $k }}={{ $v }} {{end}}'; }
alias dkwn="docker_list_swarm_nodes"

# echo -e "\n>> docker swarm aliases and functions created <<"; echo;

################################################################################

echo -e "\n>> docker aliases and functions created <<"; echo;