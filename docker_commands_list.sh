#!/bin/sh
## Docker shortcut commands and aliases file
# Load config variables from file
  source /share/docker/scripts/.bash-colors.env
  source /share/docker/scripts/.docker_vars.env

helpFunction() {
  echo -e "${blu}[-> Custom bash commands created to manage a QNAP based Docker Swarm <-]${DEF}"
  echo
  echo -e "  ${BLU}COMMAND${DEF}        │ ${BLU}SCRIPT FILE NAME${DEF}      │ ${BLU}COMMAND DESCRIPTION${DEF}"
  echo -e "  ${cyn}dlist${DEF}          │ ${ylw}docker_commands_list${DEF}  │ lists the custom Docker Swarm commands created for managing a QNAP Docker Swarm"
  echo -e "  ${cyn}dcd${DEF}            │ ${ylw}docker_compose_dn${DEF}     │ stops (brings 'down') a docker-compose container"
  echo -e "  ${cyn}dcu${DEF}            │ ${ylw}docker_compose_up${DEF}     │ starts (brings 'up') a docker-compose container"
  echo -e "  ${cyn}dlg${DEF}            │ ${ylw}docker_list_configs${DEF}   │ lists config files in ${YLW}../{compose,swarm}/configs/${cyn}{stackname}${def} folder structure (${cyn}dccfg │ dwcfg${def})"
  echo -e "  ${cyn}dlc${DEF}            │ ${ylw}docker_list_container${DEF} │ lists currently deployed docker containers and/or services"
  echo -e "  ${cyn}dln${DEF}            │ ${ylw}docker_list_network${DEF}   │ lists currently created docker networks"
  echo -e "  ${cyn}dls${DEF}            │ ${ylw}docker_list_stack${DEF}     │ lists currently deployed docker swarm stacks and services"
  echo -e "  ${cyn}dsf${DEF}            │ ${ylw}docker_stack_folders${DEF}  │ creates swarm folder structure for (1 - 9 listed) stacks"
  echo -e "  ${cyn}dsb  │ bounce${DEF}  │ ${ylw}docker_stack_bounce${DEF}   │ removes stack then recreates it using '${ylw}\$swarm_configs/${cyn}stackname${DEF}/${cyn}stackname.yml${DEF}' (bounce == '${cyn}dsb -all${DEF}')"
  echo -e "  ${cyn}dsd  │ dsup${DEF}    │ ${ylw}docker_stack_deploy${DEF}   │ deploys stack, or a list of stacks defined in '${ylw}\$docker_vars/${cyn}swarm_stacks.conf${DEF}' (dsup == '${cyn}dsd -all${DEF}')"
  echo -e "  ${cyn}dsr  │ dsclr${DEF}   │ ${ylw}docker_stack_remove${DEF}   │ removes stack, or ${cyn}-all${DEF} stacks listed via 'docker stack ls' (dsclr == '${cyn}dsr -all${DEF}')"
  echo -e "  ${cyn}dve  │ dverror${DEF} │ ${ylw}docker_service_error${DEF}  │ displays a list of docker services with last error"
  echo -e "  ${cyn}dvl  │ dvlogs${DEF}  │ ${ylw}docker_service_logs${DEF}   │ displays a list of docker service and container logs"
  echo -e "  ${cyn}dwup │ dwinit${DEF}  │ ${ylw}docker_swarm_setup${DEF}    │ swarm setup script, (${cyn}dwinit${DEF} == 'dwup -init' which downloads install script from github)"
  echo -e "  ${cyn}dwlv │ dwclr${DEF}   │ ${ylw}docker_swarm_leave${DEF}    │ USE WITH CAUTION! - prunes docker system, leaves swarm (dwclr == 'dwlv -${cyn}all${DEF}')"
  echo -e "  ${cyn}dprn${DEF}           │ ${ylw}docker_system_prune${DEF}   │ prunes the Docker system of unused containers, images, networks, and volumes"
  echo
  }

# logical action check
  case "${1}" in 
    ("-x"|"-execute") # register docker aliases and custom commands for qnap devices
  # if [[ "${1}" = "-x" ]] || [[ "${1}" = "-execute" ]]; then
    # 'dk' docker aliases
    alias dk='docker'
    alias dki='docker images'
    alias dkn='docker network'
    alias dkv='docker service'
    alias dkrm='docker rm'
    alias dkl='docker logs'
    alias dklf='docker logs -f'
    alias dkrm='docker rm `docker ps --no-trunc -aq`'
    alias dkrmi='docker rmi $(docker images --filter "dangling=true" -q --no-trunc)'
    alias dkt='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"'
    alias dkps='docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Image}}"'
    alias dkm='docker-machine'
    alias dkmx='docker-machine ssh'

    # docker_commands_list -- lists the below custom docker commands
    dlist(){ sh ${docker_scripts}/docker_commands_list.sh "$1"; }
    # docker_compose_dn -- stops the entered container
    dcd(){ sh ${docker_scripts}/docker_compose_dn.sh "$1"; }
    # docker_compose_up -- starts the entered container using preconfigured docker_compose files
    dcu(){ sh ${docker_scripts}/docker_compose_up.sh "$1"; }
    # docker_compose_logs -- displays 50 log entries for the indicated docker-compose container
    dcl(){ sh ${docker_scripts}/docker_compose_logs.sh "$1"; }
    # docker_list_configs -- lists existing stack config files for either swarm or compose filepaths
    dlg(){ sh ${docker_scripts}/docker_list_configs.sh $1; }
    # dccfg(){ sh ${docker_scripts}/docker_list_configs.sh -compose; }
    # dwcfg(){ sh ${docker_scripts}/docker_list_configs.sh -swarm; }
    alias dccfg="dlg -compose"
    alias dwcfg="dlg -swarm"
    # docker_list_container -- lists all currently deployed containers and/or services
    dlc(){ sh ${docker_scripts}/docker_list_container.sh $1 $2; }
    # docker_list_stack -- lists all stacks and number of services inside each stack
    dls(){ sh ${docker_scripts}/docker_list_stack.sh $1 $2; }
    # docker_list_network -- lists current docker networks
    dln(){ sh ${docker_scripts}/docker_list_network.sh $1 $2; }
    # docker_list_volume -- lists unused docker volumes
    dlv(){ sh ${docker_scripts}/docker_list_volume.sh $1 $2; }
    # docker_stack_bounce -- removes then re-deploys the listed stacks or '-all' stacks with config files in the folder structure
    dsb(){ sh ${docker_scripts}/docker_stack_bounce.sh "$1"; }
    # bounce(){ sh ${docker_scripts}/docker_stack_bounce.sh -all; }
    alias bounce="dsb -all"
    # docker_stack_deploy -- deploys a single stack as defind in the configs folder structure
    dsd(){ sh ${docker_scripts}/docker_stack_deploy.sh "$1"; }
    # dsup(){ sh ${docker_scripts}/docker_stack_deploy.sh -all; }
    alias dsup="dsd -all"
    # docker_stack_folders -- creates the folder structure required for each listed stack name (up to 9 per command)
    dsf(){ sh ${docker_scripts}/docker_stack_folders.sh "$1" "$2" "$3" "$4" "$5" "$6" "$7" "$8" "$9"; }
    # docker_stack_remove -- removes a single stack
    dsr(){ sh ${docker_scripts}/docker_stack_remove.sh "$1"; }
    # docker_stack_remove -- removes all swarm stack
    dsclr(){ sh ${docker_scripts}/docker_stack_remove.sh -all; }
    # docker_system_prune -- prunes the docker system (removes unused images and containers and networks and volumes)
    dprn(){ sh ${docker_scripts}/docker_system_prune.sh $1; }
    # docker cleanup scripts
    dclean(){ sh ${docker_scripts}/docker_system_clean.sh $1; }
    # docker_service_errors -- displays 'docker ps --no-trunk <servicename>' command output
    dve(){ sh ${docker_scripts}/docker_service_error.sh "$1" "$2"; }
    alias dverror="dve"
    # docker_service_logs -- displays 'docker service logs <servicename>' command output
    dvl(){ sh ${docker_scripts}/docker_service_logs.sh "$1" "$2"; }
    alias dvlogs="dvl"
    # docker_swarm_initialize -- Downloads and executes the docker_swarm_setup.sh script
      # sh mkdir -pm 766 ${docker_scripts} && curl -fsSL https://raw.githubusercontent.com/Drauku/QNAP-Docker-Swarm-Setup/master/scripts/docker_swarm_setup.sh > ${docker_scripts}/docker_swarm_setup.sh && . ${docker_scripts}/docker_swarm_setup.sh -setup; 
    dwinit(){ sh ${docker_scripts}/docker_swarm_init.sh traefik; }
    dwup(){ sh ${docker_scripts}/docker_swarm_init.sh "$1"; }
    # docker_swarm_leave -- LEAVES the docker swarm. USE WITH CAUTION!
    dwlv(){ sh ${docker_scripts}/docker_swarm_leave.sh "$1"; }
    # docker_swarm_clear -- REMOVES all swarm stacks, REMOVES the overlay network, and LEAVES the swarm. USE WITH CAUTION!
    dwclr(){ sh ${docker_scripts}/docker_swarm_leave.sh -all; }
    echo -e "${blu} >> Docker aliases for QNAP devices imported${def}"
  # else helpFunction
  # fi
    ;;
    (*) helpFunction ;;
  esac

# helpFunction() {
#   echo -e "${blu}[-> Custom sh commands created to manage a QNAP based Docker Swarm <-]${DEF}"
#   echo -e "┌────────────────┬───────────────────────┬───────────────────────────────────────────────────────────────────────────────────────────────────────┐"
#   echo -e "│  ${BLU}COMMAND       ${def}│ ${BLU}SCRIPT FILE NAME      ${def}│ ${BLU}COMMAND DESCRIPTION${DEF}                                                                                   │"
#   echo -e "├────────────────┼───────────────────────┼───────────────────────────────────────────────────────────────────────────────────────────────────────┤"
#   echo -e "│  ${cyn}dlist${DEF}         │ ${ylw}docker_commands_list${DEF}  │ lists the custom Docker Swarm commands created for managing a QNAP Docker Swarm                       │"
#   echo -e "│  ${cyn}dcd${DEF}           │ ${ylw}docker_compose_dn${DEF}     │ stops (brings 'down') a docker-compose container                                                      │"
#   echo -e "│  ${cyn}dcu${DEF}           │ ${ylw}docker_compose_up${DEF}     │ starts (brings 'up') a docker-compose container                                                       │"
#   echo -e "│  ${cyn}dlg${DEF}           │ ${ylw}docker_list_configs${DEF}   │ lists config files in ${YLW}../{compose,swarm}/configs/${cyn}{stackname}${def} folder structure (${cyn}dccfg | dwcfg${def})         │"
#   echo -e "│  ${cyn}dlc${DEF}           │ ${ylw}docker_list_container${DEF} │ lists currently deployed docker containers and/or services                                            │"
#   echo -e "│  ${cyn}dln${DEF}           │ ${ylw}docker_list_network${DEF}   │ lists currently created docker networks                                                               │"
#   echo -e "│  ${cyn}dls${DEF}           │ ${ylw}docker_list_stack${DEF}     │ lists currently deployed docker swarm stacks and services                                             │"
#   echo -e "│  ${cyn}dsf${DEF}           │ ${ylw}docker_stack_folders${DEF}  │ creates swarm folder structure for (1 - 9 listed) stacks                                              │"
#   echo -e "│  ${cyn}dsb │ bounce${DEF}  │ ${ylw}docker_stack_bounce${DEF}   │ removes stack then recreates it using '${ylw}\$swarm_configs/${cyn}stackname${DEF}/${cyn}stackname.yml${DEF}' (bounce == '${cyn}dsb -all${DEF}') │"
#   echo -e "│  ${cyn}dsd │ dsup${DEF}    │ ${ylw}docker_stack_deploy${DEF}   │ deploys stack, or a list of stacks defined in '${ylw}\$docker_vars/${cyn}swarm_stacks.conf${DEF}' (dsup == '${cyn}dsd -all${DEF}')    │"
#   echo -e "│  ${cyn}dsr │ dsclr${DEF}   │ ${ylw}docker_stack_remove${DEF}   │ removes stack, or ${cyn}-all${DEF} stacks listed via 'docker stack ls' (dsclr == '${cyn}dsr -all${DEF}')                      │"
#   echo -e "│  ${cyn}dve │ dverror${DEF} │ ${ylw}docker_service_error${DEF}  │ displays a list of docker services with last error                                                    │"
#   echo -e "│  ${cyn}dvl │ dvlogs${DEF}  │ ${ylw}docker_service_logs${DEF}   │ displays a list of docker service and container logs                                                  │"
#   echo -e "│  ${cyn}dwup │ dwinit${DEF} │ ${ylw}docker_swarm_setup${DEF}    │ swarm setup script, (${cyn}dwinit${DEF} == 'dwup -init' which downloads install script from github)               │"
#   echo -e "│  ${cyn}dwlv │ dwclr${DEF}  │ ${ylw}docker_swarm_leave${DEF}    │ USE WITH CAUTION! - prunes docker system, leaves swarm (dwclr == 'dwlv -${cyn}all${DEF}')                         │"
#   echo -e "│  ${cyn}dprn${DEF}          │ ${ylw}docker_system_prune${DEF}   │ prunes the Docker system of unused containers, images, networks, and volumes                          │"
#   echo -e "└────────────────┴───────────────────────┴───────────────────────────────────────────────────────────────────────────────────────────────────────┘"
#   }

