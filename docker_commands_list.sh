#!/bin/sh
# external variable sources
  source /opt/docker/scripts/.script_vars.conf

# function definitions
  fnc_list_syntax() {
    echo -e "${blu}[-> Bash scripts and Docker aliases created to increase Docker command execution speed. <-]${DEF}"
    echo -e " -"
    echo -e " - SYNTAX: # dlist | dlist ${cyn}-option${DEF}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn}-a │ --aliases   ${DEF}│ Displays the list of Docker Aliases."
    echo -e " -     ${cyn}-s │ --scripts   ${DEF}│ Displays the list of Docker Scripts."
    echo -e " -     ${cyn}-f │ --functions ${DEF}│ Displays both the list of Docker Scripts and Aliases."
    echo -e " -     ${cyn}-c │ --create    ${DEF}│ Register and create docker aliases and custom commands."
    }
  fnc_list_aliases() {
    echo -e " -"
    echo -e " - NOTE: Aliases do not have options, and are only shortcuts for the target command."
    echo -e " -"
    echo -e " -- ${blu}ALIAS${DEF} -│- ${blu}TARGET COMMAND${DEF} -│-   ${blu}ALIAS DESCRIPTION${DEF}   --"
    echo -e " ────────────────────────────────────────────────────────"
    echo -e " -${cyn} dk      ${DEF}│${ylw} docker           ${DEF}│ '${cyn}docker${DEF}' command alias"
    echo -e " -${cyn} dki     ${DEF}│${ylw} docker images    ${DEF}│ '${cyn}docker ${grn}images${DEF}' command alias"
    echo -e " -${cyn} dkn     ${DEF}│${ylw} docker network   ${DEF}│ '${cyn}docker ${grn}network${DEF}' command alias"
    echo -e " -${cyn} dkv     ${DEF}│${ylw} docker service   ${DEF}│ '${cyn}docker ${grn}service${DEF}' command alias"
    echo -e " -${cyn} dkl     ${DEF}│${ylw} docker logs      ${DEF}│ '${cyn}docker ${grn}logs${DEF}' command alias"
    echo -e " -${cyn} dklf    ${DEF}│${ylw} docker logs -f   ${DEF}│ '${cyn}docker ${grn}logs -f${DEF}' command alias"
    echo -e " -${cyn} dkrm    ${DEF}│${ylw} docker rm        ${DEF}│ '${cyn}docker ${grn}rm${DEF}' (removes no-trunc list) shortcut"
    echo -e " -${cyn} dkrmi   ${DEF}│${ylw} docker rmi ...   ${DEF}│ '${cyn}docker ${grn}rmi${DEF}' (removes dangling images) shortcut"
    echo -e " -${cyn} dkt     ${DEF}│${ylw} docker stats ... ${DEF}│ '${cyn}docker ${grn}stats${DEF}' (lists stats using custom columns) shortcut"
    echo -e " -${cyn} dkps    ${DEF}│${ylw} docker ps ...    ${DEF}│ '${cyn}docker ${grn}ps${DEF}' (lists processes using custom columns) shortcut"
    echo -e " -${cyn} dc      ${DEF}│${ylw} docker-compose   ${DEF}│ '${cyn}docker-compose${DEF}' command alias"
    echo -e " -${cyn} dm      ${DEF}│${ylw} docker-machine   ${DEF}│ '${cyn}docker-machine${DEF}' command alias"
    echo -e " -${cyn} dccfg   ${DEF}│${ylw} dlg --compose    ${DEF}│ '${cyn}docker ${grn}logs${DEF}' custom command alias"
    echo -e " -${cyn} dwcfg   ${DEF}│${ylw} dlg --swarm      ${DEF}│ '${cyn}docker ${grn}logs${DEF}' custom command alias"
    echo -e " -${cyn} bounce  ${DEF}│${ylw} dsb --all        ${DEF}│ ${cyn}stop${DEF} and ${cyn}restart${DEF} swarm stacks custom command alias"
    echo -e " -${cyn} dsup    ${DEF}│${ylw} dsd --all        ${DEF}│ ${cyn}start${DEF} ${grn}swarm stack${DEF} custom command alias"
    echo -e " -${cyn} dsrm    ${DEF}│${ylw} dsr --all        ${DEF}│ ${cyn}remove${DEF} ${grn}swarm stack${DEF} custom command alias"
    echo -e " -${cyn} dverror ${DEF}│${ylw} dve              ${DEF}│ ${cyn}display${DEF} ${grn}container${DEF} errors custom command alias"
    echo -e " -${cyn} dvlogs  ${DEF}│${ylw} dvl              ${DEF}│ ${cyn}display${DEF} ${grn}container${DEF} logs custom command alias"
    echo -e " -${cyn} dwinit  ${DEF}│${ylw} dwin traefik     ${DEF}│ ${cyn}initialize${DEF} ${grn}swarm${DEF} custom command alias"
    echo -e " -${cyn} dwclr   ${DEF}│${ylw} dwlv --all       ${DEF}│ ${cyn}leave${DEF} and ${cyn}remove${DEF} ${grn}swarm${DEF} custom command alias"
    echo -e " -${cyn} dcmd    ${DEF}│${ylw} dlist            ${DEF}│ ${cyn}list${DEF} all custom docker commands alias"
    echo
    exit 1
    }
  fnc_list_scripts() {
    echo -e " -"
    echo -e " - NOTE: Commands have '${cyn}options${DEF}' which can be listed using the '${cyn}-help${def}' flag after the command, e.g. ${CYN}dls --${cyn}help${def} "
    echo -e " -"
    echo -e " --     ${blu}COMMAND${DEF}      -│-   ${blu}SCRIPT FILE NAME${DEF}   -│-  ${blu}COMMAND DESCRIPTION${DEF} --"
    echo -e " ────────────────────────────────────────────────────────────────────────"
    echo -e " -${cyn} dcmd / dlist       ${DEF}│ ${ylw}docker_commands_list   ${DEF}│ lists custom Docker commands for a QNAP Docker environment"
    echo -e " --${blu}    DOCKER_LIST   ${DEF}-│------------------------│-------------------------"
    echo -e " -${cyn} dlc                ${DEF}│ ${ylw}docker_list_container  ${DEF}│ ${cyn}lists${DEF} currently deployed ${grn}docker containers${DEF} and/or services"
    echo -e " -${cyn} dlg / dcg / dsg    ${DEF}│ ${ylw}docker_list_configs    ${DEF}│ ${cyn}lists${DEF} ${grn}config files${DEF} in the custom QNAP Docker folder structure"
    echo -e " -${cyn} dli / dlimg        ${DEF}│ ${ylw}docker_system_image    ${DEF}│ ${cyn}lists${DEF} ${grn}docker images${DEF} currently stored on this system"
    echo -e " -${cyn} dln                ${DEF}│ ${ylw}docker_system_network  ${DEF}│ ${cyn}lists${DEF} currently created docker ${grn}networks${DEF}"
    echo -e " -${cyn} dls                ${DEF}│ ${ylw}docker_list_stack      ${DEF}│ ${cyn}lists${DEF} currently deployed ${grn}docker swarm stacks${DEF} and services"
    echo -e " -${cyn} dlv                ${DEF}│ ${ylw}docker_system_volume   ${DEF}│ ${cyn}lists${DEF} currently created docker ${grn}volumes${DEF}"
    echo -e " --${blu} DOCKER_COMPOSE   ${DEF}-│------------------------│-------------------------"
    echo -e " -${cyn} dcf / dcfolders    ${DEF}│ ${ylw}docker_compose_folders ${DEF}│ ${cyn}creates ${grn}compose folder structure${DEF} for (1 - 9 listed) stacks"
    echo -e " -${cyn} dcb / dcbounce     ${DEF}│ ${ylw}docker_compose_bounce  ${DEF}│ ${cyn}removes${DEF} then ${cyn}recreates${DEF} a docker-compose container "
    echo -e " -${cyn} dcs / dcstart      ${DEF}│ ${ylw}docker_compose_start   ${DEF}│ ${cyn}starts${DEF} (brings 'up') a docker-compose container"
    echo -e " -${cyn} dcp / dcstop       ${DEF}│ ${ylw}docker_compose_stop    ${DEF}│ ${cyn}stops${DEF} (brings 'down') a docker-compose container"
    echo -e " --${blu} DOCKER_SERVICE   ${DEF}-│------------------------│-------------------------"
    echo -e " -${cyn} dve / dverror      ${DEF}│ ${ylw}docker_service_error   ${DEF}│ ${cyn}lists${DEF} docker services with ${grn}last error${DEF}"
    echo -e " -${cyn} dvl / dvlogs       ${DEF}│ ${ylw}docker_service_logs    ${DEF}│ ${cyn}lists${DEF} docker service and container ${grn}logs${DEF}"
    echo -e " --${blu}  DOCKER_STACK    ${DEF}-│------------------------│-------------------------"
    echo -e " -${cyn} dsf / dwfolders    ${DEF}│ ${ylw}docker_stack_folders   ${DEF}│ ${cyn}creates ${grn}stack folder structure${DEF} for (1 - 9 listed) stacks"
    echo -e " -${cyn} dsb / dsbounce     ${DEF}│ ${ylw}docker_stack_bounce    ${DEF}│ ${cyn}removes${DEF} then ${cyn}recreates${DEF} a docker-stack container"
    echo -e " -${cyn} dss / dsstart      ${DEF}│ ${ylw}docker_stack_start     ${DEF}│ ${cyn}deploys ${grn}stack${DEF}, or a list of stacks in '${ylw}.../${cyn}swarm_stacks.conf${DEF}'"
    echo -e " -${cyn} dsp / dsstop       ${DEF}│ ${ylw}docker_stack_stop      ${DEF}│ ${cyn}removes ${grn}stack${DEF}, or ${cyn}-all${DEF} stacks listed via 'docker stack ls'"
    echo -e " --${blu}  DOCKER_SWARM    ${DEF}-│------------------------│-------------------------"
    echo -e " -${cyn} dwin / dwinit      ${DEF}│ ${ylw}docker_swarm_init      ${DEF}│ ${grn}swarm initialization script${DEF}, does ${ylw}NOT${DEF} download new scripts"
    echo -e " -${cyn} dwup / dwsup       ${DEF}│ ${ylw}docker_swarm_setup     ${DEF}│ ${grn}swarm setup script${DEF}, ${ylw}DOES${DEF} download new install scripts"
    echo -e " -${cyn} dwlv / dwclr       ${DEF}│ ${ylw}docker_swarm_leave     ${DEF}│ ${red}USE WITH CAUTION!${DEF} - prunes & clears all docker stacks, ${grn}leaves swarm${DEF}"
    echo -e " --${blu}  DOCKER_SYSTEM   ${DEF}-│------------------------│-------------------------"
    echo -e " -${cyn} dcln / dclean      ${DEF}│ ${ylw}docker_system_clean    ${DEF}│ ${cyn}stops${DEF} and ${cyn}removes ${grn}ALL containers${DEF}, images, networks, and volumes"
    echo -e " -${cyn} dprn / dprune      ${DEF}│ ${ylw}docker_system_prune    ${DEF}│ ${cyn}prunes${DEF} ${grn}UNUSED containers${DEF}, images, networks, and volumes"
    echo
    # exit 1
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
    # alias dkex='docker exec -it $(docker ps -f name=${1} --format "{{.ID}}") /bin/sh'
    # alias dkex='docker ps -f name=${1}'

    alias dkc='docker-compose'

    alias dkm='docker-machine'
    alias dkmssh='docker-machine ssh'

    # docker_commands_list -- lists the below custom docker commands
    dlist(){ sh "${docker_scripts}/docker_commands_list.sh" "${@}"; }
    alias dcmd="dlist";

    alias dappdata="cd ${docker_appdata}/${1}"
    alias dappd="cd ${docker_appdata}/${1}"
    alias dcconfigs="cd ${docker_compose}/${1}"
    alias dcconf="cd ${docker_compose}/${1}"
    alias dwconfigs="cd ${docker_swarm}/${1}"
    alias dwconf="cd ${docker_swarm}/${1}"

    # alias jump="cd ../../${PWD##*/}"

    # # docker_folders_create -- creates the folder structure required for each listed docker container
    # dkfolders(){ sh "${docker_scripts}/docker_folders_create.sh" "${@}"; }
    # alias dcf="dkfolders -c";
    # alias dsf="dkfolders -w";
    # alias dwf="dkfolders -w";
    # # alias dcf='dkfolders -c "$1"';
    # # alias dsf='dkfolders -w "$1"';
    # # alias dwf='dkfolders -w "$1"';

    # docker_compose_bounce -- stops then re-creates the listed containers or '-all' container-stacks with config files in the folder structure
    dcbounce(){ sh "${docker_scripts}/docker_compose_bounce.sh" "${@}"; }
    alias dcb="dcbounce";
    alias dcb="dcbounce";
    alias cbounce="dcbounce --all";

    # docker_compose_folders -- creates the folder structure required for each listed compose stack name (up to 9 per command)
    # dcfolders(){ sh "${docker_scripts}/docker_compose_folders.sh" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"; }
    dcfolders(){ sh "${docker_scripts}/docker_compose_folders.sh" "${@}"; }
    alias dcf="dcfolders";

    # docker_compose_start -- starts the entered container using preconfigured docker_compose files
    dcstart(){ sh "${docker_scripts}/docker_compose_start.sh" "${@}"; }
    alias dcu="dcstart"; # "Up"
    alias dcs="dcstart"; # "Start"
    alias dct="dcstart"; # "starT"

    # docker_compose_stop -- stops the entered container
    dcstop(){ sh "${docker_scripts}/docker_compose_stop.sh" "${@}"; }
    alias dcd="dcstop"; # "Down"
    alias dcr="dcstop"; # "Remove"
    alias dcp="dcstop"; # "stoP"

    # docker_compose_logs -- displays 50 log entries for the indicated docker-compose container
    dclogs(){ sh "${docker_scripts}/docker_compose_logs.sh" "${@}"; }
    alias dcl="dclogs";

    # docker_compose_networks -- creates required networks for docker-compose container manipulation via scripts
    dcnet(){ sh "${docker_scripts}/docker_compose_networks.sh"; }
    alias dcn="dcnet";

    # docker_list_configs -- lists existing stack config files for either swarm or compose filepaths
    dlconfigs(){ sh "${docker_scripts}/docker_list_configs.sh" "${1}"; }
    alias dlg="dlconfigs";
    alias dccfg="dlconfigs --compose";
    alias dcg="dlconfigs --compose";
    alias dscfg="dlconfigs --swarm";
    alias dsg="dlconfigs --swarm";
    alias dwcfg="dlconfigs --swarm";
    alias dwg="dlconfigs --swarm";

    # docker_list_container -- lists all currently deployed containers and/or services
    dlcntnr(){ sh "${docker_scripts}/docker_list_container.sh" "${1}" "${2}"; }
    alias dlc="dlcntnr";

    # docker_list_stack -- lists all stacks and number of services inside each stack
    dlstack(){ sh "${docker_scripts}/docker_list_stack.sh" "${1}" "${2}"; }
    alias dls="dlstack";
    alias dlw="dlstack";

    # docker_stack_bounce -- removes then re-deploys the listed stacks or '-all' stacks with config files in the folder structure
    # dwbounce(){ sh "${docker_scripts}/docker_stack_bounce.sh" "${@}"; }
    dwbounce(){
      docker stack rm "${1}"
      docker stack deploy "${1}" -c "/opt/docker/swarm/${1}/${1}-stack.yml"
      }
    alias dsb="dwbounce";
    alias dwb="dwbounce";
    alias bounce="dwbounce --all";

    # # docker_stack_folders -- creates the folder structure required for each listed stack name (up to 9 per command)
    # dwfolders(){ sh "${docker_scripts}/docker_stack_folders.sh" "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"; }
    dwfolders(){ sh "${docker_scripts}/docker_stack_folders.sh" "${@}"; }
    alias dsf="dwfolders";
    alias dwf="dwfolders";

    # docker_stack_deploy -- deploys a single stack as defind in the configs folder structure
    # dwstart(){ sh "${docker_scripts}/docker_stack_start.sh" "${@}"; }
    dwstart(){ docker stack deploy "${1}" -c "/opt/docker/swarm/${1}/${1}-stack.yml"; }
    alias dsd="dwstart"; # "Deploy"
    alias dss="dwstart"; # "Start"
    alias dsu="dwstart"; # "Up"
    alias dsup="dwstart --all";
    alias dwd="dwstart"; # "Deploy"
    alias dws="dwstart"; # "Start"
    alias dwu="dwstart"; # "Up"
    alias dwup="dwstart --all";

    # docker_stack_remove -- removes a single stack
    # dwstop(){ sh "${docker_scripts}/docker_stack_stop.sh" "${@}"; }
    dwstop(){ docker stack rm "${1}"; }
    alias dsr="dwstop"; # "Remove"
    alias dsp="dwstop"; # "stoP"
    alias dsrm="dwstop --all";
    alias dwr="dwstop"; # "Remove"
    alias dwp="dwstop"; # "stoP"
    alias dwrm="dwstop --all";

    # docker_service_errors -- displays 'docker ps --no-trunk <servicename>' command output
    dverror(){ sh "${docker_scripts}/docker_service_error.sh" "${1}" "${2}"; }
    alias dve="dverror";

    # docker_service_logs -- displays 'docker service logs <servicename>' command output
    dvlogs(){ sh "${docker_scripts}/docker_service_logs.sh" "${1}" "${2}"; }
    alias dvl="dvlogs";

    # docker_swarm_init -- Initializes a Docker Swarm using the docker_swarm_init.sh script
    dwinit(){ sh "${docker_scripts}/docker_swarm_init.sh" "${1}"; }
    alias dsin="dwinit traefik";
    alias dwin="dwinit traefik";
    # alias dwsetup="dwinit -setup"; # Downloads and executes the docker_swarm_setup.sh script (NOT YET WORKING)

    # docker_swarm_setup -- Downloads and executes the docker_swarm_setup.sh script (NOT YET WORKING)
    dwsetup(){ sh "${docker_scripts}/docker_swarm_setup.sh" "${@}"; }
    alias dssup="dwsetup traefik";
    alias dwsup="dwsetup traefik";
    # sh mkdir -pm 766 ${docker_scripts} && curl -fsSL https://raw.githubusercontent.com/Drauku/QNAP-Docker-Swarm-Setup/master/scripts/docker_swarm_setup.sh > "${docker_scripts}/docker_swarm_setup.sh" && . "${docker_scripts}/docker_swarm_setup.sh";

    # docker_swarm_leave -- LEAVES the docker swarm. USE WITH CAUTION!
    dwleave(){ sh "${docker_scripts}/docker_swarm_leave.sh" "${@}"; }
    alias dslv="dwleave"
    alias dwlv="dwleave"
    alias dsclr="dwleave --all";
    alias dwclr="dwleave --all";

    # docker_system_clean -- similar to prune, but performs more in-depth removal functions
    dclean(){ sh "${docker_scripts}/docker_system_clean.sh" "${1}"; }
    alias dkc="dclean";
    alias dyc="dclean";
    alias dcln="dclean";

    # docker_system_image -- manage docker container images from the docker repository
    dimages(){ sh "${docker_scripts}/docker_system_image.sh" "${1}"; }
    alias dli="dimages -l";
    alias dki="dimages";
    alias dyi="dimages";
    alias dimage="dimages";

    # docker_system_network -- lists current docker networks
    dnet(){ sh "${docker_scripts}/docker_system_network.sh" "${1}" "${2}"; }
    alias dln="dnet";
    alias dyn="dnet";

    # docker_system_prune -- prunes the docker system (removes unused images and containers and networks and volumes)
    dprune(){ sh "${docker_scripts}/docker_system_prune.sh" "${1}"; }
    alias dkp="dprune";
    alias dyp="dprune";
    alias dprn="dprune";

    # docker_system_stats -- displays resources used by current docker stacks/containers
    dstats(){ sh "${docker_scripts}/docker_system_stats.sh" "${1}"; }
    alias dks="dstats";
    alias dys="dstats";
    alias dtop="dstats --live";
    alias dstat="dstats --live";

    # docker_system_volume -- lists unused docker volumes
    dvol(){ sh "${docker_scripts}/docker_system_volume.sh" "${1}" "${2}"; }
    alias dlv="dvol";
    alias dyv="dvol";

    echo -e "${blu} >> Created Docker terminal functions and aliases. Type 'dlist' to display defined commands.${def}";
    }

# logical action check
  case "${1}" in
    ("-a"|"--aliases") fnc_list_syntax; fnc_list_aliases ;;
    ("-s"|"--scripts") fnc_list_syntax; fnc_list_scripts ;;
    ("-f"|"--functions") fnc_list_syntax; fnc_list_scripts; fnc_list_aliases ;;
    ("-c"|"--create")
      fnc_create_aliases "" # register docker aliases and custom commands for qnap devices
      [ ! -e "${docker_scripts}/profile.sh" ] && ln -s /opt/etc/profile "${docker_scripts}/profile.sh" # create shortcut to 'entware-std' profile
      ;;
    (*) fnc_list_syntax ;;
  esac
