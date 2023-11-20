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
########################### general docker functions ###########################

# create the $HOME/.docker_fnc symlink if it does not exist
ln_source="$HOME/.docker_fnc"
ln_target="$HOME/docker/docker_functions"
if [[ ! -f "$ln_source" ]]; then ln -s "$ln_target" "$ln_source"; fi;

# alias to easily source this file
alias dkfnc='. $ln_source'

## assign docker UID and GID variables
docker_uid=$(id -u "$docker_usr") # docker UID (1001)
export docker_uid
docker_gid=$(id -g "$docker_usr") # docker GID (994)
export docker_gid

# folder and file permissions
export perms_cert="a-rwx,u=rwX,g=,o=" # 600 # -rw-rw----
export perms_conf="a-rwx,u+rwX,g=rwX,o=rX" # 664 # -rw-rw-r--
export perms_data="a-rwx,u+rwX,g=rwX,o-rX" # 660 # -rw-rw----
# export dk_dir="" # 775 # -rwxrwxr-x

# docker directory structure
export docker_appdata="$docker_dir/appdata"
export docker_compose="$docker_dir/compose"
export docker_dkswarm="$docker_dir/dkswarm"
export docker_secrets="$docker_dir/secrets"

# check if sudo is needed for some commands used in these custom docker functions
if [[ $(id -u) -ne 0 ]]; then var_sudo="$(command -v sudo 2>/dev/null) "; else unset var_sudo; fi;

# create docker directory structure and .docker.env if they don't exist
if [[ ! -d "$docker_dir" ]]; then ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_conf" -d "$docker_dir"/{compose,dkswarm}; fi
if [[ ! -d "$docker_dir" ]]; then ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_data" -d "$docker_dir"/{appdata,secrets}; fi
if [[ ! -f "$docker_dir/.docker.env" ]]; then ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_data" /dev/null "$docker_compose/.docker.env"; fi

appdata(){ cd "$docker_appdata/$1" || echo "No appdata directory for the \`$1\` container exists."; return; }
compose(){ cd "$docker_compose/$1" || echo "No compose directory for the \`$1\` container exists."; return; }
dkswarm(){ cd "$docker_dkswarm/$1" || echo "No dkswarm directory for the \`$1\` container exists."; return; }
secrets(){ cd "$docker_secrets/$1" || echo "No secrets directory for the \`$1\` container exists."; return; }

vpncheck(){ echo " Host IP: $(wget -qO- ifconfig.me)" && echo "Container IP: $(docker container exec -it "${*}" wget -qO- ipinfo.io)"; }
ipcheck(){ echo "Container IP: $(docker container exec -it "${*}" curl ipinfo.io)"; }

fnc_check_dir(){ if [[ ! -d "$1" ]]; then echo -e " > \`$1\` docker container directory does not exist <"; return 1; fi; }

fnc_check_container_name(){
    if [[ ${1:0:1} =~ ^[_-]+$ ]] || [[ ! ${1} =~ ^[a-zA-Z0-9_-]+$ ]];
    then echo -e " > \`$1\` is an invalid docker container name <"; return 1;
    else return 0; # container name only contains valid characters
    fi;
    }

fnc_verify_action(){
    while read -r -p " $2 " input; do
        case "${input:-N}" in
            [yY]|[yY][eE][sS]) return 0;;
            [nN]|[nN][oO]) return 1;;
            *) echo -e " > invalid input <"; return 1;;
        esac
    done
    }

docker_file_permissions(){
    # update restricted access file permissions to 600
    files_restricted=("acme.json" "*.crt" "*.key" "*.pub" "*.ppk" "*.pem");
    for file in "${files_restricted[@]}"; do
        ${var_sudo}find "$docker_dir" -iname "$file" -type f -exec chmod "$perms_cert" {} +
    done
    # update limited access file permissions to 660
    files_limited=(".conf" "*.env" ".log" "*.secret");
    for file in "${files_limited[@]}"; do
        ${var_sudo}find "$docker_dir" -iname "$file" -type f -exec chmod $perms_data {} +
    done
    # # update general access file permissions to 664
    # files_general=("*.yml" "*.yaml" "*.toml");
    # for file in "${files_general[@]}"; do
    #     ${var_sudo}find "$docker_dir" -iname "$file" -type f -exec chmod "$perms_conf" {} +
    # done
    }
docker_folder_permissions(){
    case "${1}" in
    "-a"|"--all") # update file and folder permissions for all containers
        ${var_sudo}chown -R "${docker_uid:-1000}:${docker_gid:-1000}" "${docker_dir:?}";
        ${var_sudo}chmod -R $perms_data "${docker_appdata:?}"; # -rwXrwX---
        ${var_sudo}chmod -R $perms_conf "${docker_compose:?}"; # -rwXrwXr-X
        ${var_sudo}chmod -R $perms_conf "${docker_dkswarm:?}"; # -rwXrwXr-X
        ${var_sudo}chmod -R $perms_data "${docker_secrets:?}"; # -rwXrwX---
        docker_file_permissions
        echo -e " > \`ALL\` docker subdirectory and file permissions updated <"
        ;;
    *) # update file and folder permissions for specific container
        directories=("$docker_appdata" "$docker_compose" "$docker_dkswarm" "$docker_secrets");
        for dir in "${directories[@]}"; do
            fnc_check_dir "$dir/$1" && {
                case $dir in
                    "$docker_appdata") dir_perms="a-x,ug+rwX,o=";;
                    "$docker_compose"|"$docker_dkswarm") dir_perms="a-x,ug+rwX,o=rX";;
                    "$docker_secrets") dir_perms="a-x,u+rwX,g=rX,o=";;
                esac
                ${var_sudo}chown -R "${var_uid:-1000}:${var_gid:-1000}" "$dir/$1";
                ${var_sudo}chmod -R "$dir_perms" "$dir/$1";
                docker_file_permissions "$1";
                };
        done
        echo -e " > \`${1}\` docker container subdirectory and file permissions updated <"
        ;;
    esac
    }
alias dfp="docker_folder_permissions"

docker_env_actions(){
    if [[ ! -f "$docker_type/$1/.env" ]];
    then ln -s "$docker_dir/.docker.env" "$docker_type/$1/.env"; # symlinks .env to .docker.env
        # ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_data" "$docker_dir/.docker.env" "$docker_compose/$1/.env"; # copies .docker.env to .env
    fi
    }

docker_folders_create(){
    if [[ -d "$1" ]];
    then echo "Docker config directory for \`$1\` already exists."; echo; return;
    else # create docker container directories and files
        if [[ $1 =~ ^[compose]+$ ]];
        then export docker_type="$docker_compose";
        elif [[ $1 =~ ^[dkswarm]+$ ]];
        then export docker_type="$docker_dkswarm";
        fi;
        ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_conf" -d "$docker_type/$1";
        ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_conf" /dev/null "$docker_type/$1/compose.yml";
        ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_data" -d "$docker_appdata/$1";
        docker_env_actions "$1";
        echo "Docker directories and files created for the \`$1\` application.";
    fi;
    echo
    }
docker_folders_delete(){
    if ! fnc_verify_action "$1" "This will forcefully delete all \`$1\` application subdirectories and files. Continue? [y/N] "; then return; fi;
    if [[ ! -d "$docker_appdata/$1" ]];
    then echo "Docker appdata directory for \`$1\` does not exists. Nothing to remove."; echo;
    else rm -rf "$docker_appdata/$1";
    fi;
    if [[ $1 =~ ^[compose]+$ ]] && [[ ! -d "$docker_compose/$1" ]];
    then echo "Docker compose config directory for \`$1\` does not exists. Nothing to remove."; echo;
    else rm -rf "$docker_compose/$1";
    fi;
    if [[ $1 =~ ^[dkswarm]+$ ]] && [[ ! -d "$docker_dkswarm/$1" ]];
    then echo "Docker swarm config directory for \`$1\` does not exists. Nothing to remove."; echo;
    else rm -rf "$docker_dkswarm/$1";
    fi;
    echo " > \`$1\` docker container subdirectories and files deleted.";
    }
docker_folders_remove(){
    if ! fnc_verify_action "$1" "This will forcefully remove all \`$1\` application subdirectories and files. Continue? [y/N] "; then return; fi;
    }
docker_folder_actions(){
    case "$1" in
        -*) # perform optional action
            case "$1" in
                "-c"|"--create")
                    docker_folders_create "$docker_type/$2" ;;
                "-d"|"--delete")
                    docker_folders_delete "$docker_type/$2" ;;
                "-r"|"--remove")
                    docker_folders_remove "$docker_type/$2" ;;
            esac
        ;;
        *)
            docker_folders_create "$docker_type/$1" ;;
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
    # if ! fnc_check_container_name "$1"; then return; fi;
    # export docker_type="$docker_compose";
    # docker_folder_actions "$1";
    if fnc_check_container_name "$1"; then
        export docker_type="$docker_compose";
        docker_folder_actions "$1";
    fi;
    }
alias dcf='docker_compose_folders'

docker_compose_edit(){ nano "$docker_compose/$1/compose.yml"; }
alias dce="docker_compose_edit"

docker_compose_logs(){ (cd "$docker_compose/$1" && docker compose logs -f); }
alias dcl="docker_compose_logs"

docker_compose_networks(){
    docker network create --driver "bridge" --opt "encrypted" --scope "local" --subnet "172.27.0.0/24" --gateway "172.27.0.254" --attachable "docker_socket"
    docker network create --driver "bridge" --opt "encrypted" --scope "local" --subnet "172.27.1.0/24" --gateway "172.27.1.254" --attachable "external_edge"
    docker network create --driver "bridge" --opt "encrypted" --scope "local" --subnet "172.27.2.0/24" --gateway "172.27.2.254" --attachable "reverse_proxy"
    echo "The \`docker_socket\`, \`external_edge\`, and \`reverse_proxy\` docker bridge networks exist or were created."; echo
}
alias dcn="docker_compose_networks"

docker_compose_start(){
    if [[ -f "$docker_compose/$1/compose.yml" ]]; then
        docker_env_actions "$1";
        docker compose -f "$docker_compose/$1/compose.yml" up -d --remove-orphans;
    else echo "No docker compose configuration file found for the \`$1\` application.";
    fi;
    echo;
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

echo -e "\n>> docker terminal aliases and functions created <<\n";

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
    if ! fnc_check_container_name "$1"; then return; fi;
    export docker_type="$docker_dkswarm";
    docker_folder_actions "$1";

    # if [[ ! -f $docker_dir/.docker.env ]]; then ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_data" /dev/null "$docker_dkswarm/.docker.env"; fi
    # if [[ -f "$docker_dkswarm/$1/compose.yml" ]]; then echo "Docker swarm config for \`$1\` already exists."; return;
    # else
    #     ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$dk_dir" -d "$docker_dir"/{appdata,dkswarm}/"$1"
    #     ${var_sudo}install -o "$docker_uid" -g "$docker_gid" -m "$perms_conf" /dev/null "$docker_dkswarm/$1/compose.yml"
    #     [[ -f "$docker_dkswarm/$1/compose.yml" ]] && echo "Docker swarm directories and files created for the \`$1\` application."; echo;
    #     echo
    # fi
    }
alias dwf="docker_swarm_folders"

docker_swarm_edit(){ nano "$docker_dkswarm/$1/compose.yml"; }
alias dwe="docker_swarm_edit"

docker_swarm_networks(){
    docker network create --driver "bridge" --opt "encrypted" --scope "swarm" --subnet "172.27.0.0/24" --gateway "172.27.0.254" --attachable "docker_socket"
    docker network create --driver "overlay" --opt "encrypted" --scope "swarm" --subnet "172.27.1.0/24" --gateway "172.27.1.254" --attachable "external_edge"
    docker network create --driver "overlay" --opt "encrypted" --scope "swarm" --subnet "172.27.2.0/24" --gateway "172.27.2.254" --attachable "reverse_proxy"
    echo "The \`docker_socket\`, \`external_edge\`, and \`reverse_proxy\` docker overlay networks exist or were created."; echo
}
alias dwn="docker_swarm_networks"

docker_swarm_start(){
    if [[ -f "$docker_dkswarm/$1/compose.yml" ]]; then
        docker_env_actions "$1";
        docker stack deploy "${1}" -c "${docker_dkswarm}/${1}/compose.yml" --prune;
    else echo "No docker swarm configuration file found for the \`$1\` application.";
    fi;
    echo;
    }
alias dwu="docker_swarm_start"

docker_swarm_stop(){
    if [[ -f "$docker_dkswarm/$1/compose.yml" && -f "$docker_dkswarm/$1/.env" ]]
    then docker compose -f "$docker_dkswarm/$1/compose.yml" down;
    else docker stop "$1" && docker container rm "$1"
    fi
    echo
    }
alias dwd="docker_swarm_stop"

docker_swarm_bounce(){ docker_swarm_stop "$1" && docker_swarm_start "$1" ; }
alias dwb="docker_swarm_bounce"

echo -e "\n>> docker swarm aliases and functions created <<\n";

################################################################################
