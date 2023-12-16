#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env
  # source /opt/docker/swarm/stackslist-swarm.conf

# script variable definitions
  unset bounce_list IFS

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-> This script bounces (removes then re-deploys) a single or pre-defined list of Docker Swarm stack <-]${def:?}"
    echo -e " -"
    echo -e " - SYNTAX: # dsb ${cyn:?}stack_name${def:?}"
    echo -e " - SYNTAX: # dsb ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}-a | --all     ${def:?}│ Bounces all stacks with a corresponding folder inside the '${ylw:?}${docker_swarm}/${def:?}' path."
    echo -e " -     ${cyn:?}-d | --default ${def:?}│ Bounces the 'default' array of stacks defined in '${ylw:?}${docker_secrets}/${cyn:?}stackslist-swarm.conf${def:?}'"
    echo -e " -     ${cyn:?}-p | --preset  ${def:?}│ Bounces the 'preset' array of stacks defined in '${ylw:?}${docker_secrets}/${cyn:?}stackslist-swarm.conf${def:?}'"
    echo -e " -     ${cyn:?}-h │ --help    ${def:?}│ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu:?}[-> STOP THEN RESTART LISTED CONTAINERS <-]${def:?}"; echo -e "${cyn:?} -> ${bounce_list[*]} ${def:?}"; echo; }
  fnc_nothing_to_do(){ echo -e "${ylw:?} -> no containers exist to bounce${def:?}"; }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE -${cyn:?}help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  fnc_list_all(){ IFS=$'\n'; bounce_list=( $(docker stack ls --format {{.Name}}) ); }
  fnc_list_preset(){ IFS=$'\n'; bounce_list=( "${stacks_preset[@]}" ); }
  fnc_list_default(){ IFS=$'\n'; bounce_list=( "${stacks_default[@]}" ); }
  fnc_docker_stack_stop(){ sh ${docker_scripts}/docker_stack_stop.sh "${bounce_list[@]}"; }
  fnc_docker_stack_start(){ sh ${docker_scripts}/docker_stack_start.sh "${bounce_list[@]}"; }
  fnc_script_outro(){ echo -e "[-- ${grn:?}BOUNCE (REMOVE & REDEPLOY) STACK SCRIPT COMPLETE${def:?} --]"; echo; }

# determine script output according to option entered
  case "${1}" in
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-a"|"--all") fnc_list_all ;;
        ("-d"|"--default") fnc_list_default ;;
        ("-p"|"--preset") fnc_list_preset ;;
        (*) fnc_invalid_syntax ;;
      esac
    ;;
    (*) bounce_list=("$@") ;;
  esac

# # display script intro
#   fnc_script_intro
# remove all stacks in list defined above
  fnc_docker_stack_stop
# wait 4 sec for ports to fall off assignment
  sleep 4
# (re)deploy all stacks in list defined above
  fnc_docker_stack_start
# # display script outro
#   fnc_script_outro