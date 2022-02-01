#!/bin/sh
# external variable sources
  source /share/docker/scripts/.script_vars.conf

# function definitions
  fnc_help() {
    echo -e "${blu}[-> Custom bash commands created to manage a QNAP based Docker Swarm <-]${DEF}"
    echo -e " -"
    echo -e " - NOTE: Commands have '${cyn}options${DEF}' which can be listed using the '-help' flag after the command, e.g. ${CYN}dls --${cyn}help${def} "
    echo -e " -"
    echo -e " - ${blu}COMMAND         ${DEF}│ ${blu}SCRIPT FILE NAME       ${DEF}│ ${blu}COMMAND DESCRIPTION${DEF}"
    echo -e " - ────────────────┼────────────────────────┼────────────────────────"
    echo -e " - ${cyn}dcmd │ dlist    ${DEF}│ ${ylw}docker_commands_list   ${DEF}│ lists the custom Docker Swarm commands created for managing a QNAP Docker Swarm"
    echo -e " - ${blu}DOCKER_LIST     ${DEF}│                        │"
    echo -e " - ${cyn}dlc             ${DEF}│ ${ylw}docker_list_container  ${DEF}│ lists currently deployed docker containers and/or services"
    echo -e " - ${cyn}dls             ${DEF}│ ${ylw}docker_list_stack      ${DEF}│ lists currently deployed docker swarm stacks and services"
    echo -e " - ${cyn}dlg │ dcg │ dwg ${DEF}│ ${ylw}docker_list_configs    ${DEF}│ lists config files in ${YLW}../{compose,swarm}/configs/${cyn}{stackname}${def} folder structure"
    echo -e " - ${cyn}dln             ${DEF}│ ${ylw}docker_list_network    ${DEF}│ lists currently created docker networks"
    echo -e " - ${cyn}dlv             ${DEF}│ ${ylw}docker_list_volumes    ${DEF}│ lists currently created docker volumes"
    echo -e " - ${blu}DOCKER_COMPOSE  ${DEF}│                        │"
    echo -e " - ${cyn}dcf             ${DEF}│ ${ylw}docker_compose_folders ${DEF}│ creates swarm folder structure for (1 - 9 listed) stacks"
    echo -e " - ${cyn}dcb             ${DEF}│ ${ylw}docker_compose_bounce  ${DEF}│ removes container then recreates it using '${ylw}\$compose_configs/${cyn}stackname${DEF}/${cyn}stackname-compose.yml${DEF}'"
    echo -e " - ${cyn}dcs │ dcu       ${DEF}│ ${ylw}docker_compose_start   ${DEF}│ starts (brings 'up') a docker-compose container"
    echo -e " - ${cyn}dcp │ dcd       ${DEF}│ ${ylw}docker_compose_stop    ${DEF}│ stops (brings 'down') a docker-compose container"
    echo -e " - ${blu}DOCKER_SERVICE  ${DEF}│                        │"
    echo -e " - ${cyn}dve │ dverror   ${DEF}│ ${ylw}docker_service_error   ${DEF}│ displays a list of docker services with last error"
    echo -e " - ${cyn}dvl │ dvlogs    ${DEF}│ ${ylw}docker_service_logs    ${DEF}│ displays a list of docker service and container logs"
    echo -e " - ${blu}DOCKER_SWARM    ${DEF}│                        │"
    echo -e " - ${cyn}dsf             ${DEF}│ ${ylw}docker_stack_folders   ${DEF}│ creates swarm folder structure for (1 - 9 listed) stacks"
    echo -e " - ${cyn}dsb │ bounce    ${DEF}│ ${ylw}docker_stack_bounce    ${DEF}│ removes stack then recreates it using '${ylw}\$swarm_configs/${cyn}stackname${DEF}/${cyn}stackname.yml${DEF}'"
    echo -e " - ${cyn}dss │ dwstart   ${DEF}│ ${ylw}docker_stack_start     ${DEF}│ deploys stack, or a list of stacks defined in '${ylw}\$docker_vars/${cyn}swarm_stacks.conf${DEF}'"
    echo -e " - ${cyn}dsp │ dwstop    ${DEF}│ ${ylw}docker_stack_stop      ${DEF}│ removes stack, or ${cyn}-all${DEF} stacks listed via 'docker stack ls'"
    echo -e " - ${blu}DOCKER_SWARM    ${DEF}│                        │"
    echo -e " - ${cyn}dwin │ dwinit   ${DEF}│ ${ylw}docker_swarm_init      ${DEF}│ swarm initialization script, does NOT download scripts from repository"
    echo -e " - ${cyn}dwlv │ dwclr    ${DEF}│ ${ylw}docker_swarm_leave     ${DEF}│ USE WITH CAUTION! - prunes docker system, leaves swarm"
    echo -e " - ${cyn}dwup │ dwsup    ${DEF}│ ${ylw}docker_swarm_setup     ${DEF}│ swarm setup script, which downloads install script from online repository"
    echo -e " - ${blu}DOCKER_SYSTEM   ${DEF}│                        │"
    echo -e " - ${cyn}dclean          ${DEF}│ ${ylw}docker_system_clean    ${DEF}│ stops and cleans the Docker system of all containers, images, networks, and volumes"
    echo -e " - ${cyn}dprn            ${DEF}│ ${ylw}docker_system_prune    ${DEF}│ prunes the Docker system of unused containers, images, networks, and volumes"
    echo
    # echo -e " - NOTE: Aliases do not have options, and will only act as a shortcut which prints out the 'target command' in place of the alias name."
    # echo -e " - ${blu}ALIAS   ${DEF}│ ${blu}TARGET COMMAND   ${DEF}│ ${blu}ALIAS DESCRIPTION${DEF}"
    # echo -e " - ────────┼──────────────────┼────────────────────────────"
    # echo -e " - ${cyn}dk      ${DEF}│ ${ylw}docker           ${DEF}│ 'docker' command alias"
    # echo -e " - ${cyn}dki     ${DEF}│ ${ylw}docker images    ${DEF}│ 'docker images' command alias"
    # echo -e " - ${cyn}dkn     ${DEF}│ ${ylw}docker network   ${DEF}│ 'docker network' command alias"
    # echo -e " - ${cyn}dkv     ${DEF}│ ${ylw}docker service   ${DEF}│ 'docker service' command alias"
    # echo -e " - ${cyn}dkl     ${DEF}│ ${ylw}docker logs      ${DEF}│ 'docker logs' command alias"
    # echo -e " - ${cyn}dklf    ${DEF}│ ${ylw}docker logs -f   ${DEF}│ 'docker logs -f' command alias"
    # echo -e " - ${cyn}dkrm    ${DEF}│ ${ylw}docker rm        ${DEF}│ 'docker rm \`docker ps --no-trunc -aq\`' shortcut"
    # echo -e " - ${cyn}dkrmi   ${DEF}│ ${ylw}docker rmi ...   ${DEF}│ 'docker rmi \$(docker images --filter \"dangling=true\" -q --no-trunc)' shortcut"
    # echo -e " - ${cyn}dkt     ${DEF}│ ${ylw}docker stats ... ${DEF}│ 'docker stats --format \"table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\"' shortcut"
    # echo -e " - ${cyn}dkps    ${DEF}│ ${ylw}docker ps ...    ${DEF}│ 'docker ps --format \"table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\"' shortcut"
    # echo -e " - ${cyn}dc      ${DEF}│ ${ylw}docker-compose   ${DEF}│ 'docker-compose' command alias"
    # echo -e " - ${cyn}dm      ${DEF}│ ${ylw}docker-machine   ${DEF}│ 'docker-machine' command alias"
    # echo -e " - ${cyn}dccfg   ${DEF}│ ${ylw}dlg --compose    ${DEF}│ custom command alias"
    # echo -e " - ${cyn}dwcfg   ${DEF}│ ${ylw}dlg --swarm      ${DEF}│ custom command alias"
    # echo -e " - ${cyn}bounce  ${DEF}│ ${ylw}dsb --all        ${DEF}│ custom command alias"
    # echo -e " - ${cyn}dsup    ${DEF}│ ${ylw}dsd --all        ${DEF}│ custom command alias"
    # echo -e " - ${cyn}dsrm    ${DEF}│ ${ylw}dsr --all        ${DEF}│ custom command alias"
    # echo -e " - ${cyn}dverror ${DEF}│ ${ylw}dve              ${DEF}│ custom command alias"
    # echo -e " - ${cyn}dvlogs  ${DEF}│ ${ylw}dvl              ${DEF}│ custom command alias"
    # echo -e " - ${cyn}dwinit  ${DEF}│ ${ylw}dwin traefik     ${DEF}│ custom command alias"
    # echo -e " - ${cyn}dwclr   ${DEF}│ ${ylw}dwlv --all       ${DEF}│ custom command alias"
    # echo -e " - ${cyn}dcmd    ${DEF}│ ${ylw}dlist            ${DEF}│ custom command alias"
    # echo
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

    alias dkc='docker-compose'

    alias dkm='docker-machine'
    alias dkmssh='docker-machine ssh'

    # docker_commands_list -- lists the below custom docker commands
    dlist(){ sh /share/docker/scripts/docker_commands_list.sh "$1"; }
    alias dcmd="dlist";

    # # docker_folders_create -- creates the folder structure required for each listed docker container
    # dkfolders(){ sh /share/docker/scripts/docker_folders_create.sh "$1"; }
    # alias dcf="dkfolders -c";
    # alias dsf="dkfolders -w";
    # alias dwf="dkfolders -w";
    # # alias dcf='dkfolders -c "$1"';
    # # alias dsf='dkfolders -w "$1"';
    # # alias dwf='dkfolders -w "$1"';

    # docker_compose_folders -- creates the folder structure required for each listed compose stack name (up to 9 per command)
    dcfolders(){ sh /share/docker/scripts/docker_compose_folders.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"; }
    # dcfolders(){ sh /share/docker/scripts/docker_compose_folders.sh "$1"; }
    alias dcf="dcfolders";

    # docker_compose_start -- starts the entered container using preconfigured docker_compose files
    dcstart(){ sh /share/docker/scripts/docker_compose_start.sh "$1"; }
    alias dcu="dcstart"; # "Up"
    alias dcs="dcstart"; # "Start"
    alias dct="dcstart"; # "starT"

    # docker_compose_stop -- stops the entered container
    dcstop(){ sh /share/docker/scripts/docker_compose_stop.sh "$1"; }
    alias dcd="dcstop"; # "Down"
    alias dcr="dcstop"; # "Remove"
    alias dcp="dcstop"; # "stoP"

    # docker_compose_logs -- displays 50 log entries for the indicated docker-compose container
    dclogs(){ sh /share/docker/scripts/docker_compose_logs.sh "$1"; }
    alias dcl="dclogs";

    # docker_list_configs -- lists existing stack config files for either swarm or compose filepaths
    dlconfigs(){ sh /share/docker/scripts/docker_list_configs.sh $1; }
    alias dlg="dlconfigs";
    alias dccfg="dlconfigs --compose";
    alias dcg="dlconfigs --compose";
    alias dscfg="dlconfigs --swarm";
    alias dsg="dlconfigs --swarm";
    alias dwcfg="dlconfigs --swarm";
    alias dwg="dlconfigs --swarm";

    # docker_list_container -- lists all currently deployed containers and/or services
    dlcntnr(){ sh /share/docker/scripts/docker_list_container.sh $1 $2; }
    alias dlc="dlcntnr";

    # docker_list_stack -- lists all stacks and number of services inside each stack
    dlstack(){ sh /share/docker/scripts/docker_list_stack.sh $1 $2; }
    alias dls="dlstack";
    alias dlw="dlstack";

    # docker_list_network -- lists current docker networks
    dlnet(){ sh /share/docker/scripts/docker_list_network.sh $1 $2; }
    alias dln="dlnet";

    # docker_list_volume -- lists unused docker volumes
    dlvol(){ sh /share/docker/scripts/docker_list_volume.sh $1 $2; }
    alias dlv="dlvol";

    # docker_stack_bounce -- removes then re-deploys the listed stacks or '-all' stacks with config files in the folder structure
    dwbounce(){ sh /share/docker/scripts/docker_stack_bounce.sh "$1"; }
    alias dsb="dwbounce";
    alias dwb="dwbounce";
    alias bounce="dwbounce --all";

    # # docker_stack_folders -- creates the folder structure required for each listed stack name (up to 9 per command)
    dwfolders(){ sh /share/docker/scripts/docker_stack_folders.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"; }
    # dwfolders(){ sh /share/docker/scripts/docker_stack_folders.sh "$1"; }
    alias dsf="dwfolders";
    alias dwf="dwfolders";

    # docker_stack_deploy -- deploys a single stack as defind in the configs folder structure
    dwstart(){ sh /share/docker/scripts/docker_stack_start.sh "$1"; }
    alias dsd="dwstart"; # "Deploy"
    alias dss="dwstart"; # "Start"
    alias dsu="dwstart"; # "Up"
    alias dsup="dwstart --all";
    alias dwd="dwstart"; # "Deploy"
    alias dws="dwstart"; # "Start"
    alias dwu="dwstart"; # "Up"
    alias dwup="dwstart --all";

    # docker_stack_remove -- removes a single stack
    dwstop(){ sh /share/docker/scripts/docker_stack_stop.sh "$1"; }
    alias dsr="dwstop"; # "Remove"
    alias dsp="dwstop"; # "stoP"
    alias dsrm="dwstop --all";
    alias dwr="dwstop"; # "Remove"
    alias dwp="dwstop"; # "stoP"
    alias dwrm="dwstop --all";

    # docker_service_errors -- displays 'docker ps --no-trunk <servicename>' command output
    dverror(){ sh /share/docker/scripts/docker_service_error.sh "$1" "$2"; }
    alias dve="dverror";

    # docker_service_logs -- displays 'docker service logs <servicename>' command output
    dvlogs(){ sh /share/docker/scripts/docker_service_logs.sh "$1" "$2"; }
    alias dvl="dvlogs";

    # docker_swarm_init -- Initializes a Docker Swarm using the docker_swarm_init.sh script
    dwinit(){ sh /share/docker/scripts/docker_swarm_init.sh "${1}"; }
    alias dsin="dwinit traefik";
    alias dwin="dwinit traefik";
    # alias dwsetup="dwinit -setup"; # Downloads and executes the docker_swarm_setup.sh script (NOT YET WORKING)

    # docker_swarm_setup -- Downloads and executes the docker_swarm_setup.sh script (NOT YET WORKING)
    dwsetup(){ sh /share/docker/scripts/docker_swarm_setup.sh "$1"; }
    alias dssup="dwsetup traefik";
    alias dwsup="dwsetup traefik";
    # sh mkdir -pm 766 /share/docker/scripts && curl -fsSL https://raw.githubusercontent.com/Drauku/QNAP-Docker-Swarm-Setup/master/scripts/docker_swarm_setup.sh > /share/docker/scripts/docker_swarm_setup.sh && . /share/docker/scripts/docker_swarm_setup.sh; 

    # docker_swarm_leave -- LEAVES the docker swarm. USE WITH CAUTION!
    dwleave(){ sh /share/docker/scripts/docker_swarm_leave.sh "$1"; }
    alias dslv="dwleave"
    alias dwlv="dwleave"
    alias dsclr="dwleave --all";
    alias dwclr="dwleave --all";

    # docker_system_clean -- similar to prune, but performs more in-depth removal functions
    dclean(){ sh /share/docker/scripts/docker_system_clean.sh $1; }
    alias dyc="dclean";
    alias dcln="dclean";

    # docker_system_prune -- prunes the docker system (removes unused images and containers and networks and volumes)
    dprune(){ sh /share/docker/scripts/docker_system_prune.sh $1; }
    alias dyp="dprune";
    alias dprn="dprune";

    # docker_system_stats -- displays resources used by current docker stacks/containers
    dstats(){ sh /share/docker/scripts/docker_system_stats.sh "${1}"; }
    alias dys="dstats";
    alias dtop="dstats --live";
    alias dstat="dstats --live";

  echo -e "${blu} >> Created Docker command aliases for QNAP devices${def}"
}

# logical action check
  case "${1}" in 
    ("-x"|"-exe"|"--execute") 
      fnc_create_aliases # register docker aliases and custom commands for qnap devices
      # ln -sf /opt/etc/profile /share/docker/scripts/profile.sh # force-creates shortcut to 'entware-std' profile
      [ ! -e /share/docker/scripts/profile.sh ] && ln -s /opt/etc/profile /share/docker/scripts/profile.sh # create shortcut to 'entware-std' profile
      ;;
    (*) fnc_help ;;
  esac
