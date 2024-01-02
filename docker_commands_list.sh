#!/bin/bash

## Folder hierarchy for Drauku's directory structure, modified from gkoerk's famously awesome folder structure for stacks.
  export docker_folder="/opt/docker"
  export docker_appdata="${docker_folder}/appdata"
  export docker_compose="${docker_folder}/compose"
  export docker_runtime="${docker_folder}/runtime"
  export docker_scripts="${docker_folder}/scripts"
  export docker_secrets="${docker_folder}/secrets"
  export docker_swarm="${docker_folder}/swarm"

## external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# function definitions
  fnc_help_docker_commands() {
    echo -e " ┌────────────────────────────────────────────────────────────────────────"
    echo -e " │ ${blu:?}Bash scripts and Docker aliases created to increase Docker command execution speed.${def:?}"
    echo -e " │ "
    echo -e " │ SYNTAX: # dlist | dlist ${cyn:?}-option${def:?}"
    echo -e " │   VALID OPTIONS:"
    echo -e " │     ${cyn:?} -a ${def:?}│${cyn:?} --aliases   ${def:?}│ Displays the list of Docker Aliases."
    echo -e " │     ${cyn:?} -s ${def:?}│${cyn:?} --scripts   ${def:?}│ Displays the list of Docker Scripts."
    echo -e " │     ${cyn:?} -f ${def:?}│${cyn:?} --functions ${def:?}│ Displays both the list of Docker Scripts and Aliases."
    echo -e " │     ${cyn:?} -c ${def:?}│${cyn:?} --create    ${def:?}│ Register and create docker aliases and custom commands."
    echo -e " │     ${cyn:?} -h ${def:?}│${cyn:?} --help      ${def:?}│ Displays this help message."
    echo -e " └────────────────────────────────────────────────────────────────────────"
    echo
    exit 1 # Exit script after printing help
    }
  case "${1}" in ("-h"|*"help"*) fnc_help_docker_commands ;; esac

# echo -e " ┌────────────────────────────────────────────────────────────────────────"
# echo -e " │ "
# echo -e " └────────────────────────────────────────────────────────────────────────"
# echo -e " ┌─────────┬──────────────────┬───────────────────────────────────────────"
# echo -e " ├─────────┼──────────────────┼───────────────────────────────────────────"
# echo -e " └─────────┴──────────────────┴───────────────────────────────────────────"
# ┌ ─ ┬ ─ ┐
# │   │   │
# ├ ─ ┼ ─ ┤
# │   │   │
# └ ─ ┴ ─ ┘

# docker_commands_list -- function and alias for this script file
  fnc_docker_commands(){ sh "${docker_scripts}/docker_commands_list.sh" "${@}"; }
  alias dcmd="fnc_docker_commands"
  alias dlist="fnc_docker_commands -f";
  # alias dscripts='source /opt/docker/scripts/docker_commands_list.sh --create'

  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE ${cyn:?}-help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; }

## docker script definitions
  # src="/opt/docker/scripts/docker_commands_list.sh"
  # . $src && echo " >> '$src' successfully loaded" || echo " -- ERROR: could not import '$src'"
  # [ -e $src ] && . $src || echo " -- ERROR: '$src' does not exist"

  fnc_list_aliases() {
    echo -e " ┌─────────┬──────────────────┬───────────────────────────────────────────"
    echo -e " │  ${blu:?}ALIAS${def:?}  │  ${blu:?}TARGET COMMAND${def:?}  │   ${blu:?}ALIAS DESCRIPTION${def:?}"
    echo -e " ├─────────┼──────────────────┼───────────────────────────────────────────"
    echo -e " │${cyn:?} dk      ${def:?}│${ylw:?} docker           ${def:?}│ '${cyn:?}docker${def:?}' command alias"
    echo -e " │${cyn:?} dki     ${def:?}│${ylw:?} docker images    ${def:?}│ '${cyn:?}docker ${grn:?}images${def:?}' command alias"
    echo -e " │${cyn:?} dkn     ${def:?}│${ylw:?} docker network   ${def:?}│ '${cyn:?}docker ${grn:?}network${def:?}' command alias"
    echo -e " │${cyn:?} dkv     ${def:?}│${ylw:?} docker service   ${def:?}│ '${cyn:?}docker ${grn:?}service${def:?}' command alias"
    echo -e " │${cyn:?} dkl     ${def:?}│${ylw:?} docker logs      ${def:?}│ '${cyn:?}docker ${grn:?}logs${def:?}' command alias"
    echo -e " │${cyn:?} dklf    ${def:?}│${ylw:?} docker logs -f   ${def:?}│ '${cyn:?}docker ${grn:?}logs -f${def:?}' command alias"
    echo -e " │${cyn:?} dkrm    ${def:?}│${ylw:?} docker rm        ${def:?}│ '${cyn:?}docker ${grn:?}rm${def:?}' (removes no-trunc list) shortcut"
    echo -e " │${cyn:?} dkrmi   ${def:?}│${ylw:?} docker rmi ...   ${def:?}│ '${cyn:?}docker ${grn:?}rmi${def:?}' (removes dangling images) shortcut"
    echo -e " │${cyn:?} dkt     ${def:?}│${ylw:?} docker stats ... ${def:?}│ '${cyn:?}docker ${grn:?}stats${def:?}' (lists stats using custom columns) shortcut"
    echo -e " │${cyn:?} dkps    ${def:?}│${ylw:?} docker ps ...    ${def:?}│ '${cyn:?}docker ${grn:?}ps${def:?}' (lists processes using custom columns) shortcut"
    echo -e " │${cyn:?} dc      ${def:?}│${ylw:?} docker compose   ${def:?}│ '${cyn:?}docker compose${def:?}' command alias"
    # echo -e " │${cyn:?} dm      ${def:?}│${ylw:?} docker-machine   ${def:?}│ '${cyn:?}docker-machine${def:?}' command alias"
    echo -e " │${cyn:?} dccfg   ${def:?}│${ylw:?} dlg --compose    ${def:?}│ '${cyn:?}docker ${grn:?}logs${def:?}' custom command alias"
    echo -e " │${cyn:?} dwcfg   ${def:?}│${ylw:?} dlg --swarm      ${def:?}│ '${cyn:?}docker ${grn:?}logs${def:?}' custom command alias"
    echo -e " │${cyn:?} bounce  ${def:?}│${ylw:?} dsb --all        ${def:?}│ ${cyn:?}stop${def:?} and ${cyn:?}restart${def:?} swarm stacks custom command alias"
    echo -e " │${cyn:?} dsup    ${def:?}│${ylw:?} dsd --all        ${def:?}│ ${cyn:?}start${def:?} ${grn:?}swarm stack${def:?} custom command alias"
    echo -e " │${cyn:?} dsrm    ${def:?}│${ylw:?} dsr --all        ${def:?}│ ${cyn:?}remove${def:?} ${grn:?}swarm stack${def:?} custom command alias"
    echo -e " │${cyn:?} dverror ${def:?}│${ylw:?} dve              ${def:?}│ ${cyn:?}display${def:?} ${grn:?}container${def:?} errors custom command alias"
    echo -e " │${cyn:?} dvlogs  ${def:?}│${ylw:?} dvl              ${def:?}│ ${cyn:?}display${def:?} ${grn:?}container${def:?} logs custom command alias"
    echo -e " │${cyn:?} dwinit  ${def:?}│${ylw:?} dwin traefik     ${def:?}│ ${cyn:?}initialize${def:?} ${grn:?}swarm${def:?} custom command alias"
    echo -e " │${cyn:?} dwclr   ${def:?}│${ylw:?} dwlv --all       ${def:?}│ ${cyn:?}leave${def:?} and ${cyn:?}remove${def:?} ${grn:?}swarm${def:?} custom command alias"
    echo -e " │${cyn:?} dcmd    ${def:?}│${ylw:?} dlist            ${def:?}│ ${cyn:?}list${def:?} available custom Docker function aliases for use in terminal."
    echo -e " └─────────┴──────────────────┴───────────────────────────────────────────"
    echo -e "   NOTE: Aliases do not have options, and are only shortcuts for the target command."
    echo
    }
  fnc_list_scripts() {
    echo -e " ┌────────────────────┬─────────────────────────┬──────────────────────────"
    echo -e " │       ${blu:?}COMMAND${def:?}      │    ${blu:?}SCRIPT FILE NAME${def:?}     │   ${blu:?}COMMAND DESCRIPTION${def:?}"
    echo -e " ├────────────────────┼─────────────────────────┼──────────────────────────"
    echo -e " │${cyn:?} dcmd / dlist       ${def:?}│ ${ylw:?}docker_commands_list    ${def:?}│ ${cyn:?}lists${def:?} available custom Docker function aliases for use in terminal."
    echo -e " ├──${blu:?} docker list ${def:?}─────┼─────────────────────────┼──────────────────────────"
    echo -e " │${cyn:?} dlc                ${def:?}│ ${ylw:?}docker_list_container   ${def:?}│ ${cyn:?}lists${def:?} currently deployed ${grn:?}docker containers${def:?} and/or services"
    echo -e " │${cyn:?} dlg / dcg / dsg    ${def:?}│ ${ylw:?}docker_list_configs     ${def:?}│ ${cyn:?}lists${def:?} ${grn:?}config files${def:?} in the custom QNAP Docker folder structure"
    echo -e " │${cyn:?} dli / dlimg        ${def:?}│ ${ylw:?}docker_system_image     ${def:?}│ ${cyn:?}lists${def:?} ${grn:?}docker images${def:?} currently stored on this system"
    echo -e " │${cyn:?} dln                ${def:?}│ ${ylw:?}docker_system_network   ${def:?}│ ${cyn:?}lists${def:?} currently created docker ${grn:?}networks${def:?}"
    echo -e " │${cyn:?} dls                ${def:?}│ ${ylw:?}docker_list_stack       ${def:?}│ ${cyn:?}lists${def:?} currently deployed ${grn:?}docker swarm stacks${def:?} and services"
    echo -e " │${cyn:?} dlv                ${def:?}│ ${ylw:?}docker_system_volume    ${def:?}│ ${cyn:?}lists${def:?} currently created docker ${grn:?}volumes${def:?}"
    echo -e " ├──${blu:?} docker compose ${def:?}──┼─────────────────────────┼──────────────────────────"
    echo -e " │${cyn:?} dcf / dcfolders    ${def:?}│ ${ylw:?}docker_compose_folders  ${def:?}│ ${cyn:?}creates ${grn:?}compose folder structure${def:?}" # for (1 - 9 listed) stacks"
    echo -e " │${cyn:?} dcb / dcbounce     ${def:?}│ ${ylw:?}docker_compose_bounce   ${def:?}│ ${cyn:?}removes${def:?} then ${cyn:?}recreates${def:?} a docker compose container "
    echo -e " │${cyn:?} dcl / dclogs       ${def:?}│ ${ylw:?}docker_compose_logs     ${def:?}│ ${cyn:?}lists${def:?} docker compose ${grn:?}logs${def:?}"
    echo -e " │${cyn:?} dcn / dcnet        ${def:?}│ ${ylw:?}docker_compose_networks ${def:?}│ ${cyn:?}creates${def:?} docker compose ${grn:?}networks${def:?}"
    echo -e " │${cyn:?} dcs / dcstart      ${def:?}│ ${ylw:?}docker_compose_start    ${def:?}│ ${cyn:?}starts${def:?} (brings 'up') a docker compose container"
    echo -e " │${cyn:?} dcp / dcstop       ${def:?}│ ${ylw:?}docker_compose_stop     ${def:?}│ ${cyn:?}stops${def:?} (brings 'down') a docker compose container"
    echo -e " │${cyn:?} dct / dctest       ${def:?}│ ${ylw:?}docker_compose_test     ${def:?}│ ${cyn:?}tests${def:?} a docker compose file config by displaying all variables villed in"
    echo -e " ├──${blu:?} docker service ${def:?}──┼─────────────────────────┼──────────────────────────"
    echo -e " │${cyn:?} dve / dverror      ${def:?}│ ${ylw:?}docker_service_error    ${def:?}│ ${cyn:?}lists${def:?} docker services with ${grn:?}last error${def:?}"
    echo -e " │${cyn:?} dvl / dvlogs       ${def:?}│ ${ylw:?}docker_service_logs     ${def:?}│ ${cyn:?}lists${def:?} docker service and container ${grn:?}logs${def:?}"
    echo -e " ├──${blu:?} docker stack ${def:?}────┼─────────────────────────┼──────────────────────────"
    echo -e " │${cyn:?} dsf / dwfolder     ${def:?}│ ${ylw:?}docker_stack_folders    ${def:?}│ ${cyn:?}creates ${grn:?}stack folder structure${def:?}" # for (1 - 9 listed) stacks"
    echo -e " │${cyn:?} dsb / dsbounce     ${def:?}│ ${ylw:?}docker_stack_bounce     ${def:?}│ ${cyn:?}removes${def:?} then ${cyn:?}recreates${def:?} a docker stack container"
    echo -e " │${cyn:?} dss / dsstart      ${def:?}│ ${ylw:?}docker_stack_start      ${def:?}│ ${cyn:?}deploys ${grn:?}stack${def:?}, or a list of stacks in '${ylw:?}.../${cyn:?}swarm_stacks.conf${def:?}'"
    echo -e " │${cyn:?} dsp / dsstop       ${def:?}│ ${ylw:?}docker_stack_stop       ${def:?}│ ${cyn:?}removes ${grn:?}stack${def:?}, or ${cyn:?}-all${def:?} stacks listed via 'docker stack ls'"
    echo -e " ├──${blu:?} docker swarm ${def:?}────┼─────────────────────────┼──────────────────────────"
    echo -e " │${cyn:?} dwin / dwinit      ${def:?}│ ${ylw:?}docker_swarm_init       ${def:?}│ ${grn:?}swarm initialization script${def:?}, does ${ylw:?}NOT${def:?} download new scripts"
    echo -e " │${cyn:?} dwup / dwsup       ${def:?}│ ${ylw:?}docker_swarm_setup      ${def:?}│ ${grn:?}swarm setup script${def:?}, ${ylw:?}DOES${def:?} download new install scripts"
    echo -e " │${cyn:?} dwlv / dwclr       ${def:?}│ ${ylw:?}docker_swarm_leave      ${def:?}│ ${red:?}USE WITH CAUTION!${def:?} prunes & clears all docker stacks, ${grn:?}leaves swarm${def:?}"
    echo -e " ├──${blu:?} docker system ${def:?}───┼─────────────────────────┼──────────────────────────"
    echo -e " │${cyn:?} dcln / dclean      ${def:?}│ ${ylw:?}docker_system_clean     ${def:?}│ ${cyn:?}stops${def:?} and ${cyn:?}removes ${grn:?}ALL containers${def:?}, images, networks, and volumes"
    echo -e " │${cyn:?} dprn / dprune      ${def:?}│ ${ylw:?}docker_system_prune     ${def:?}│ ${cyn:?}prunes${def:?} ${grn:?}UNUSED containers${def:?}, images, networks, and volumes"
    echo -e " └────────────────────┴─────────────────────────┴──────────────────────────"
    echo -e "   NOTE: Commands accept '${cyn:?}options${def:?}' which can be listed using the '${cyn:?}--help${def:?}' flag after the command, e.g. ${cyn:?}dls --${cyn:?}help${def:?} "
    echo
    }
  fnc_create_aliases(){
    # docker alias list
    alias dk='docker'
    alias dki='docker images'
    alias dkn='docker network'
    alias dkv='docker service'
    alias dkrm='docker rm'
    alias dkl='docker logs'
    alias dklf='docker logs -f'
    alias dkrm='docker rm `docker ps --no-trunc -aq`'
    alias dkrmi='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
    alias dkt='docker stats --format "table {{.Name}}\t{{.CPUPerc}}  {{.MemPerc}}\t{{.MemUsage}}\t{{.NetIO}}"'
    alias dkps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"'
    alias dkc='docker compose'
    # alias dkm='docker-machine'
    # alias dkmssh='docker-machine ssh'

    docker_version(){ docker --version && docker compose version; }
    alias dkver="docker_version"

    docker_compose_info(){ docker ps -f name="${1}"; }
    alias dcinfo="docker_compose_info"

    docker_exec(){ docker exec -it "$(docker ps -f name="${1}" --format "{{.ID}}")" /bin/sh; }
    alias dkex="docker_exec"
    alias dkx="docker_exec"

    ipcheck(){ echo "Container IP: $(docker container exec -it "${*}" curl ipinfo.io)"; }
    alias checkip='ipcheck'
    # portcheck(){ curl -sq -b cookies.txt "http://${QIP}:${QPORT}/container-station/api/v1/system/port/tcp/${1}"; }
    # alias checkport='portcheck'
    vpncheck(){ echo "     Host IP: $(wget -qO- ifconfig.me)" && echo "Container IP: $(docker container exec -it "${*}" wget -qO- ipinfo.io/ip)"; }
    alias checkvpn='vpncheck'

    ## folder and file permissions
    export perms_cert="a-rwx,u=rwX,g=,o=" # 600 # -rw-rw----
    export perms_conf="a-rwx,u+rwX,g=rwX,o=rX" # 664 # -rw-rw-r--
    export perms_data="a-rwx,u+rwX,g=rwX,o=" # 660 # -rw-rw----
    # export docker_dir="a=rwx,o-w" # 775 # -rwxrwxr-x

    docker_file_permissions(){
        case "${1}" in
            ("-a"|"--all") files_dir="${docker_folder}" ;;
            ("-l"|"--local") files_dir="${docker_compose}/${1}" ;;
            ("-w"|"--swarm") files_dir="${docker_swarm}/${1}" ;;
            (*)
              echo "invalid syntax"
        esac
        # update restricted access file permissions to 600
        files_restricted=("acme.json" "*.crt" "*.key" "*.pub" "*.ppk" "*.pem");
        for file in "${files_restricted[@]}"; do
            ${var_sudo:-} find "$files_dir" -iname "$file" -type f -exec chmod "$perms_cert" {} +
        done
        # update limited access file permissions to 660
        files_limited=(".conf" "*.env" ".log" "*.secret");
        for file in "${files_limited[@]}"; do
            ${var_sudo:-} find "$files_dir" -iname "$file" -type f -exec chmod "$perms_data" {} +
        done
        # # update general access file permissions to 664
        # files_general=("*.yml" "*.yaml" "*.toml");
        # for file in "${files_general[@]}"; do
        #     ${var_sudo}find "$docker_dir" -iname "$file" -type f -exec chmod "$perms_conf" {} +
        # done
        }


    appdata(){ cd "${docker_appdata}/${1}" || return; }
    compose(){ cd "${docker_compose}/${1}" || return; }
    secrets(){ cd "${docker_secrets}/${1}" || return; }
    swarm(){ cd "${docker_swarm}/${1}" || return; }

    # docker_compose_bounce -- stops then re-creates the listed containers or '-all' container-stacks with config files in the folder structure
    docker_compose_bounce(){ sh "${docker_scripts}/docker_compose_bounce.sh" "${@}"; }
    alias dcb="docker_compose_bounce";
    # alias dcbounce="docker_compose_bounce --all";

    # docker_compose_folders -- creates the folder structure required for each listed compose stack name (up to 9 per command)
    docker_compose_folders(){ sh "${docker_scripts}/docker_compose_folders.sh" "${@}"; }
    alias dcf="docker_compose_folders";

    # docker_compose_edit -- opens a ../compose.yml file in nano text editor
    docker_compose_edit(){ nano "${docker_compose}/$1/compose.yml"; }
    alias dce="docker_compose_edit"

    # docker_compose_start -- starts the entered container using preconfigured docker_compose files
    docker_compose_start(){ sh "${docker_scripts}/docker_compose_start.sh" "${@}"; }
    alias dcu="docker_compose_start"; # "Up"
    alias dcs="docker_compose_start"; # "Start"

    # docker_compose_stop -- stops the entered container
    docker_compose_stop(){ sh "${docker_scripts}/docker_compose_stop.sh" "${@}"; }
    alias dcd="docker_compose_stop"; # "Down"
    alias dcp="docker_compose_stop -p"; # "stoP"
    alias dcr="docker_compose_stop -r"; # "Remove"

    # docker_compose_test -- displays the indicated compose file with variables/secrets filled in
    docker_compose_test(){ sh "${docker_scripts}/docker_compose_test.sh" "${@}"; }
    alias dcc="docker_compose_test";
    alias dct="docker_compose_test";
    alias dctest="docker_compose_test";

    # docker_compose_logs -- displays 50 log entries for the indicated docker compose container
    docker_compose_logs(){ sh "${docker_scripts}/docker_compose_logs.sh" "${@}"; }
    alias dcl="docker_compose_logs";

    # docker_compose_networks -- creates required networks for docker compose container manipulation via scripts
    docker_compose_networks(){ sh "${docker_scripts}/docker_compose_networks.sh" "${@}"; }
    alias dcn="docker_compose_networks";

    # # docker_folders_create -- creates the folder structure required for each listed docker container
    # dkfolders(){ sh "${docker_scripts}/docker_folders_create.sh" "${@}"; }
    # alias dcf="dkfolders -c";
    # alias dsf="dkfolders -w";
    # alias dwf="dkfolders -w";
    # # alias dcf='dkfolders -c "$1"';
    # # alias dsf='dkfolders -w "$1"';
    # # alias dwf='dkfolders -w "$1"';

    # docker_list_configs -- lists existing stack config files for either swarm or compose filepaths
    docker_list_configs(){ sh "${docker_scripts}/docker_list_configs.sh" "${1}"; }
    alias dlg="docker_list_configs";
    alias dccfg="docker_list_configs --compose";
    alias dcg="docker_list_configs --compose";
    alias dscfg="docker_list_configs --swarm";
    alias dsg="docker_list_configs --swarm";
    alias dwcfg="docker_list_configs --swarm";
    alias dwg="docker_list_configs --swarm";

    # docker_list_container -- lists all currently deployed containers and/or services
    docker_list_container(){ sh "${docker_scripts}/docker_list_container.sh" "${1}" "${2}"; }
    alias dlc="docker_list_container";

    # docker_list_stack -- lists all stacks and number of services inside each stack
    docker_list_stack(){ sh "${docker_scripts}/docker_list_stack.sh" "${1}" "${2}"; }
    alias dls="docker_list_stack";
    alias dlw="docker_list_stack";

    bounce(){
      if [[ $1 = "-all" ]]; then
          IFS=$'\n';
          list=( "$(docker stack ls --format '{{.Name}}')" );
        else
          list=("$*")
      fi
      for i in "${list[@]}"; do
        docker stack rm "$i"
      done
      for i in "${list[@]}"; do
        while [ "$(docker service ls --filter label=com.docker.stack.namespace="$i" -q)" ] || [ "$(docker network ls --filter label=com.docker.stack.namespace="$i" -q)" ]; do sleep 1; done
      done
      for i in "${list[@]}"; do
        docker stack deploy "$i" -c /share/docker/swarm/"$i"/compose.yml
      done
      unset list IFS
      }
    # docker_stack_bounce -- removes then re-deploys the listed stacks or '-all' stacks with config files in the folder structure
    # docker_stack_bounce(){ sh "${docker_scripts}/docker_stack_bounce.sh" "${@}"; }
    docker_stack_bounce(){
      limit=15
      docker stack rm "${1}"
      until [ -z "$(docker service ls --filter label=com.docker.stack.namespace="$1" -q)" ] || [ "$limit" -lt 0 ]; do
        sleep 1;
        ((limit--))
      done
      limit=15
      until [ -z "$(docker network ls --filter label=com.docker.stack.namespace="$1" -q)" ] || [ "$limit" -lt 0 ]; do
        sleep 1;
        ((limit--))
      done
      docker stack deploy "${1}" -c "${docker_swarm}/${1}/compose.yml"
      }
    alias dsb="docker_stack_bounce";
    alias dwb="docker_stack_bounce";
    # alias dwbounce="docker_stack_bounce --all";

    # # docker_stack_folders -- creates the folder structure required for each listed stack name (up to 9 per command)
    # docker_stack_folders(){ sh "${docker_scripts}/docker_stack_folders.sh" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"; }
    # docker_stack_folders -- creates the folder structure required for each listed stack name
    docker_stack_folders(){ sh "${docker_scripts}/docker_stack_folders.sh" "${@}"; }
    alias dsf="docker_stack_folders";
    alias dwf="docker_stack_folders";
    alias dwdir="docker_stack_folders";
    alias dwfolder="docker_stack_folders";

    # docker_stack_deploy -- deploys a single stack as defind in the configs folder structure
    # docker_stack_start(){ sh "${docker_scripts}/docker_stack_start.sh" "${@}"; }
    # docker_stack_start(){ docker stack deploy "${1}" -c "${docker_swarm}/${1}/compose.yml"; }
    docker_stack_start(){ docker stack deploy "${1}" -c "${docker_swarm}/${1}/compose.yml"; }
    alias dsd="docker_stack_start"; # "Deploy"
    alias dss="docker_stack_start"; # "Start"
    alias dsu="docker_stack_start"; # "Up"
    alias dsup="docker_stack_start --all";
    alias dwd="docker_stack_start"; # "Deploy"
    alias dws="docker_stack_start"; # "Start"
    alias dwu="docker_stack_start"; # "Up"
    alias dwup="docker_stack_start --all";

    # docker_stack_remove -- removes a single stack
    # docker_stack_stop(){ sh "${docker_scripts}/docker_stack_stop.sh" "${@}"; }
    docker_stack_stop(){ docker stack rm "${1}"; }
    alias dsr="docker_stack_stop"; # "Remove"
    alias dsp="docker_stack_stop"; # "stoP"
    alias dsrm="docker_stack_stop --all";
    alias dwr="docker_stack_stop"; # "Remove"
    alias dwp="docker_stack_stop"; # "stoP"
    alias dwrm="docker_stack_stop --all";

    # docker_service_errors -- displays 'docker ps --no-trunk <servicename>' command output
    docker_service_error(){ sh "${docker_scripts}/docker_service_error.sh" "${1}" "${2}"; }
    alias dse="docker_service_error";
    alias dwe="docker_service_error";
    alias dve="docker_service_error";
    alias dverror="docker_service_error";

    # docker_service_logs -- displays 'docker service logs <servicename>' command output
    docker_service_logs(){ sh "${docker_scripts}/docker_service_logs.sh" "${1}" "${2}"; }
    alias dsl="docker_service_logs";
    alias dwl="docker_service_logs";
    alias dvl="docker_service_logs";
    alias dvlogs="docker_service_logs";

    # docker_swarm_init -- Initializes a Docker Swarm using the docker_swarm_init.sh script
    docker_swarm_init(){ sh "${docker_scripts}/docker_swarm_init.sh" "${1}"; }
    alias dsin="docker_swarm_init traefik";
    alias dwin="docker_swarm_init traefik";
    alias dwinit="docker_swarm_init traefik";
    # alias docker_swarm_setup="docker_swarm_init -setup"; # Downloads and executes the docker_swarm_setup.sh script (NOT YET WORKING)

    # docker_swarm_setup -- Downloads and executes the docker_swarm_setup.sh script (NOT YET WORKING)
    docker_swarm_setup(){ sh "${docker_scripts}/docker_swarm_setup.sh" "${@}"; }
    alias dssup="docker_swarm_setup traefik";
    alias dwsup="docker_swarm_setup traefik";
    # sh mkdir -pm 766 ${docker_scripts} && curl -fsSL https://raw.githubusercontent.com/Drauku/QNAP-Docker-Swarm-Setup/master/scripts/docker_swarm_setup.sh > "${docker_scripts}/docker_swarm_setup.sh" && . "${docker_scripts}/docker_swarm_setup.sh";

    # docker_swarm_leave -- LEAVES the docker swarm. USE WITH CAUTION!
    docker_swarm_leave(){ sh "${docker_scripts}/docker_swarm_leave.sh" "${@}"; }
    alias dslv="docker_swarm_leave"
    alias dwlv="docker_swarm_leave"
    alias dsclr="docker_swarm_leave --all";
    alias dwclr="docker_swarm_leave --all";

    docker_backup(){ sh "${docker_scripts}/docker_system_backup.sh"; }
    alias dbk="docker_backup";
    alias dkbk="docker_backup";
    alias dback="docker_backup";

    # docker_system_clean -- similar to prune, but performs more in-depth removal functions
    docker_system_clean(){ sh "${docker_scripts}/docker_system_clean.sh" "${1}"; }
    alias dkc="docker_system_clean";
    alias dyc="docker_system_clean";
    alias dclean="docker_system_clean";

    # docker_system_image -- manage docker container images from the docker repository
    docker_system_images(){ sh "${docker_scripts}/docker_system_image.sh" "${1}"; }
    alias dli="docker_system_images -l";
    alias dki="docker_system_images";
    alias dyi="docker_system_images";
    alias dimage="docker_system_images";

    # docker_system_network -- lists current docker networks
    docker_system_network(){ sh "${docker_scripts}/docker_system_network.sh" "${1}" "${2}"; }
    alias dln="docker_system_network";
    alias dyn="docker_system_network";

    # docker_system_prune -- prunes the docker system (removes unused images and containers and networks and volumes)
    docker_system_prune(){ sh "${docker_scripts}/docker_system_prune.sh" "${1}"; }
    alias dprn="docker_system_prune";
    alias dyp="docker_system_prune";

    # docker_system_stats -- displays resources used by current docker stacks/containers
    docker_system_stats(){ sh "${docker_scripts}/docker_system_stats.sh" "${1}"; }
    alias dks="docker_system_stats";
    alias dys="docker_system_stats";
    alias dtop="docker_system_stats --live";
    alias dstat="docker_system_stats --live";

    # docker_system_volume -- lists unused docker volumes
    docker_system_volume(){ sh "${docker_scripts}/docker_system_volume.sh" "${1}" "${2}"; }
    alias dlv="docker_system_volume";
    alias dyv="docker_system_volume";

    echo -e "${blu:?} >> Docker terminal aliases and functions ${grn:?}created${blu:?}. Type 'dlist' to display defined commands.${def:?}\n";
    }

# logical action check
  case "${1}" in
    ("-a"|"--aliases")
      fnc_list_aliases;
      ;;
    ("-s"|"--scripts")
      fnc_list_scripts;
      ;;
    ("-f"|"--functions")
      fnc_list_aliases;
      fnc_list_scripts;
      ;;
    (""|"-c"|"--create")
      fnc_create_aliases ""; # register docker aliases and custom commands
      # [ ! -e "${docker_scripts}/.profile" ] && ln -s /opt/etc/profile "${docker_scripts}/.profile" # create link to 'entware-std' profile
      ;;
    (*)
      fnc_invalid_syntax;
      ;;
  esac
