#!/bin/sh
## Docker shortcut commands and aliases file
# Load config variables from file
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/scripts/.docker_vars.env

helpFunction() {
  echo -e "${blu}[-> Custom bash commands created to manage a QNAP based Docker Swarm <-]${DEF}"
  echo
  echo -e "  NOTE: Commands have 'options' which can be listed using the '-help' flag after the command, e.g. ${cyn}dls -help${def} "
  echo -e "  ${blu}COMMAND${DEF}        │ ${blu}SCRIPT FILE NAME${DEF}      │ ${blu}COMMAND DESCRIPTION${DEF}"
  echo -e "  ───────────────┼───────────────────────┼────────────────────────────"
  echo -e "  ${cyn}dlist${DEF}          │ ${ylw}docker_commands_list${DEF}  │ lists the custom Docker Swarm commands created for managing a QNAP Docker Swarm"
  echo -e "  ${cyn}dcd${DEF}            │ ${ylw}docker_compose_dn${DEF}     │ stops (brings 'down') a docker-compose container"
  echo -e "  ${cyn}dcu${DEF}            │ ${ylw}docker_compose_up${DEF}     │ starts (brings 'up') a docker-compose container"
  echo -e "  ${cyn}dlg${DEF}            │ ${ylw}docker_list_configs${DEF}   │ lists config files in ${YLW}../{compose,swarm}/configs/${cyn}{stackname}${def} folder structure"
  echo -e "  ${cyn}dlc${DEF}            │ ${ylw}docker_list_container${DEF} │ lists currently deployed docker containers and/or services"
  echo -e "  ${cyn}dln${DEF}            │ ${ylw}docker_list_network${DEF}   │ lists currently created docker networks"
  echo -e "  ${cyn}dls${DEF}            │ ${ylw}docker_list_stack${DEF}     │ lists currently deployed docker swarm stacks and services"
  echo -e "  ${cyn}dsf${DEF}            │ ${ylw}docker_stack_folders${DEF}  │ creates swarm folder structure for (1 - 9 listed) stacks"
  echo -e "  ${cyn}dsb  │ bounce${DEF}  │ ${ylw}docker_stack_bounce${DEF}   │ removes stack then recreates it using '${ylw}\$swarm_configs/${cyn}stackname${DEF}/${cyn}stackname.yml${DEF}'"
  echo -e "  ${cyn}dsd  │ dsup${DEF}    │ ${ylw}docker_stack_deploy${DEF}   │ deploys stack, or a list of stacks defined in '${ylw}\$docker_vars/${cyn}swarm_stacks.conf${DEF}'"
  echo -e "  ${cyn}dsr  │ dsrm${DEF}    │ ${ylw}docker_stack_remove${DEF}   │ removes stack, or ${cyn}-all${DEF} stacks listed via 'docker stack ls'"
  echo -e "  ${cyn}dve  │ dverror${DEF} │ ${ylw}docker_service_error${DEF}  │ displays a list of docker services with last error"
  echo -e "  ${cyn}dvl  │ dvlogs${DEF}  │ ${ylw}docker_service_logs${DEF}   │ displays a list of docker service and container logs"
  echo -e "  ${cyn}dwin │ dwinit${DEF}  │ ${ylw}docker_swarm_init${DEF}     │ swarm initialization script, does NOT download scripts from repository"
  echo -e "  ${cyn}dwlv │ dwclr${DEF}   │ ${ylw}docker_swarm_leave${DEF}    │ USE WITH CAUTION! - prunes docker system, leaves swarm"
  echo -e "  ${cyn}dwup │ dwsetup${DEF} │ ${ylw}docker_swarm_setup${DEF}    │ swarm setup script, which downloads install script from online repository"
  echo -e "  ${cyn}dprn${DEF}           │ ${ylw}docker_system_prune${DEF}   │ prunes the Docker system of unused containers, images, networks, and volumes"
  echo -e "  ${cyn}dprn${DEF}           │ ${ylw}docker_system_prune${DEF}   │ prunes the Docker system of unused containers, images, networks, and volumes"
  echo
  echo -e "  NOTE: Aliases do not have options, and will only act as a shortcut which prints out the 'target command' in place of the alias name."
  echo -e "  ${blu}ALIAS${DEF}   │ ${blu}TARGET COMMAND${DEF}   │ ${blu}ALIAS DESCRIPTION${DEF}"
  echo -e "  ────────┼──────────────────┼────────────────────────────"
  echo -e "  ${cyn}dk${DEF}      │ ${ylw}docker${DEF}           │ 'docker' command alias"
  echo -e "  ${cyn}dki${DEF}     │ ${ylw}docker images${DEF}    │ 'docker images' command alias"
  echo -e "  ${cyn}dkn${DEF}     │ ${ylw}docker network${DEF}   │ 'docker network' command alias"
  echo -e "  ${cyn}dkv${DEF}     │ ${ylw}docker service${DEF}   │ 'docker service' command alias"
  echo -e "  ${cyn}dkl${DEF}     │ ${ylw}docker logs${DEF}      │ 'docker logs' command alias"
  echo -e "  ${cyn}dklf${DEF}    │ ${ylw}docker logs -f${DEF}   │ 'docker logs -f' command alias"
  echo -e "  ${cyn}dkrm${DEF}    │ ${ylw}docker rm${DEF}        │ 'docker rm \`docker ps --no-trunc -aq\`' shortcut"
  echo -e "  ${cyn}dkrmi${DEF}   │ ${ylw}docker rmi ...${DEF}   │ 'docker rmi \$(docker images --filter \"dangling=true\" -q --no-trunc)' shortcut"
  echo -e "  ${cyn}dkt${DEF}     │ ${ylw}docker stats ...${DEF} │ 'docker stats --format \"table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\"' shortcut"
  echo -e "  ${cyn}dkps${DEF}    │ ${ylw}docker ps ...${DEF}    │ 'docker ps --format \"table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}\"' shortcut"
  echo -e "  ${cyn}dc${DEF}      │ ${ylw}docker-compose${DEF}   │ 'docker-compose' command alias"
  echo -e "  ${cyn}dm${DEF}      │ ${ylw}docker-machine${DEF}   │ 'docker-machine' command alias"
  echo -e "  ${cyn}dccfg${DEF}   │ ${ylw}dlg -compose${DEF}     │ custom command alias"
  echo -e "  ${cyn}dwcfg${DEF}   │ ${ylw}dlg -swarm${DEF}       │ custom command alias"
  echo -e "  ${cyn}bounce${DEF}  │ ${ylw}dsb -all${DEF}         │ custom command alias"
  echo -e "  ${cyn}dsup${DEF}    │ ${ylw}dsd -all${DEF}         │ custom command alias"
  echo -e "  ${cyn}dsrm${DEF}    │ ${ylw}dsr -all${DEF}         │ custom command alias"
  echo -e "  ${cyn}dverror${DEF} │ ${ylw}dve${DEF}              │ custom command alias"
  echo -e "  ${cyn}dvlogs${DEF}  │ ${ylw}dvl${DEF}              │ custom command alias"
  echo -e "  ${cyn}dwinit${DEF}  │ ${ylw}dwin traefik${DEF}     │ custom command alias"
  echo -e "  ${cyn}dwclr${DEF}   │ ${ylw}dwlv -all${DEF}        │ custom command alias"
  echo -e "  ${cyn}dcmd${DEF}    │ ${ylw}dlist${DEF}            │ custom command alias"
  echo
  exit 1
  }

# logical action check
  case "${1}" in 
    ("-x"|"-execute") ;; # register docker aliases and custom commands for qnap devices
    (*) helpFunction ;;
  esac

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

  alias dc='docker-compose'

  alias dm='docker-machine'
  alias dmssh='docker-machine ssh'

  # docker_commands_list -- lists the below custom docker commands
  dlist(){ sh /share/docker/scripts/docker_commands_list.sh "$1"; }
  alias dcmd='dlist'
  # docker_system_stats == displays resources used by current docker stacks/containers
  dstats(){ sh /share/docker/scripts/docker_system_stats.sh "${1}"; }
  alias dtop='docker stats --format "table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}  {{.MemPerc}}  {{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"'
  # docker_compose_dn -- stops the entered container
  dcd(){ sh /share/docker/scripts/docker_compose_dn.sh "$1"; }
  # docker_compose_up -- starts the entered container using preconfigured docker_compose files
  dcu(){ sh /share/docker/scripts/docker_compose_up.sh "$1"; }
  # docker_compose_logs -- displays 50 log entries for the indicated docker-compose container
  dcl(){ sh /share/docker/scripts/docker_compose_logs.sh "$1"; }
  # docker_list_configs -- lists existing stack config files for either swarm or compose filepaths
  dlg(){ sh /share/docker/scripts/docker_list_configs.sh $1; }
  # dccfg(){ sh /share/docker/scripts/docker_list_configs.sh -compose; }
  # dwcfg(){ sh /share/docker/scripts/docker_list_configs.sh -swarm; }
  alias dccfg="dlg -compose"
  alias dwcfg="dlg -swarm"
  # docker_list_container -- lists all currently deployed containers and/or services
  dlc(){ sh /share/docker/scripts/docker_list_container.sh $1 $2; }
  # docker_list_stack -- lists all stacks and number of services inside each stack
  dls(){ sh /share/docker/scripts/docker_list_stack.sh $1 $2; }
  # docker_list_network -- lists current docker networks
  dln(){ sh /share/docker/scripts/docker_list_network.sh $1 $2; }
  # docker_list_volume -- lists unused docker volumes
  dlv(){ sh /share/docker/scripts/docker_list_volume.sh $1 $2; }
  # docker_stack_bounce -- removes then re-deploys the listed stacks or '-all' stacks with config files in the folder structure
  dsb(){ sh /share/docker/scripts/docker_stack_bounce.sh "$1"; }
  # bounce(){ sh /share/docker/scripts/docker_stack_bounce.sh -all; }
  alias bounce="dsb -all"
  # docker_stack_deploy -- deploys a single stack as defind in the configs folder structure
  dsd(){ sh /share/docker/scripts/docker_stack_deploy.sh "$1"; }
  # dsup(){ sh /share/docker/scripts/docker_stack_deploy.sh -all; }
  alias dsup="dsd -all"
  # docker_stack_folders -- creates the folder structure required for each listed stack name (up to 9 per command)
  dsf(){ sh /share/docker/scripts/docker_stack_folders.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"; }
  # docker_stack_remove -- removes a single stack
  dsr(){ sh /share/docker/scripts/docker_stack_remove.sh "$1"; }
  alias dsrm="dsr -all"
  # dsclr(){ sh /share/docker/scripts/docker_stack_remove.sh -all; }
  # docker_system_prune -- prunes the docker system (removes unused images and containers and networks and volumes)
  dprn(){ sh /share/docker/scripts/docker_system_prune.sh $1; }
  # docker cleanup scripts
  dclean(){ sh /share/docker/scripts/docker_system_clean.sh $1; }
  # docker_service_errors -- displays 'docker ps --no-trunk <servicename>' command output
  dve(){ sh /share/docker/scripts/docker_service_error.sh "$1" "$2"; }
  alias dverror="dve"
  # docker_service_logs -- displays 'docker service logs <servicename>' command output
  dvl(){ sh /share/docker/scripts/docker_service_logs.sh "$1" "$2"; }
  alias dvlogs="dvl"
  # docker_swarm_initialize -- Initializes a Docker Swarm using the docker_swarm_init.sh script
  dwin(){ sh /share/docker/scripts/docker_swarm_init.sh "${1}"; }
  alias dwinit="dwin traefik"
  # docker_swarm_setup -- Downloads and executes the docker_swarm_setup.sh script
  dwup(){ sh /share/docker/scripts/docker_swarm_setup.sh "$1"; }
    # sh mkdir -pm 766 /share/docker/scripts && curl -fsSL https://raw.githubusercontent.com/Drauku/QNAP-Docker-Swarm-Setup/master/scripts/docker_swarm_setup.sh > /share/docker/scripts/docker_swarm_setup.sh && . /share/docker/scripts/docker_swarm_setup.sh -setup; 
  alias dwsetup="dwup traefik"
  # docker_swarm_leave -- LEAVES the docker swarm. USE WITH CAUTION!
  dwlv(){ sh /share/docker/scripts/docker_swarm_leave.sh "$1"; }
  alias dwclr="dwlv -all" #
  # docker_swarm_clear -- REMOVES all swarm stacks, REMOVES the overlay network, and LEAVES the swarm. USE WITH CAUTION!
  # dwclr(){ sh /share/docker/scripts/docker_swarm_leave.sh -all; }

# echo -e "${blu} >> Docker aliases for QNAP devices imported${def}"
