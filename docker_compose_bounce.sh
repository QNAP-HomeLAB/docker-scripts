#!/bin/bash

# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.conf
  # source /opt/docker/compose/stackslist-compose.conf

# script variable definitions
  unset bounce_list IFS

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-> This script bounces (removes then re-deploys) a single or pre-defined list of Docker Swarm stack <-]${def:?}"
    echo -e " -"
    echo -e " - SYNTAX: # dsb ${cyn:?}stack_name${def:?}"
    echo -e " - SYNTAX: # dsb ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}-a | --all     ${def:?}│ Bounces all containers with a corresponding folder inside the '${YLW:?}${docker_compose}/${def:?}' path."
    echo -e " -     ${cyn:?}-p | --preset  ${def:?}│ Bounces the 'preset' array of containers defined in '${YLW:?}${docker_vars}/${cyn:?}compose_stacks.conf${def:?}'"
    echo -e " -     ${cyn:?}-d | --default ${def:?}│ Bounces the 'default' array of containers defined in '${YLW:?}${docker_vars}/${cyn:?}compose_stacks.conf${def:?}'"
    echo -e " -     ${cyn:?}-h │ --help    ${def:?}│ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }
  case "$1" in ("-h"|*"help"*) fnc_help ;; esac

  fnc_script_intro(){ echo -e "${blu:?}[-> STOPS THEN RESTARTS LISTED CONTAINERS <-]${def:?}"; echo -e "${cyn:?} -> ${bounce_list[*]} ${def:?}"; echo; }
  fnc_script_outro(){ echo -e "[-- ${GRN:?}BOUNCE (REMOVE & REDEPLOY) STACK SCRIPT COMPLETE${def:?} --]"; echo; }
  fnc_nothing_to_do(){ echo -e "${YLW:?} -> no containers exist to bounce${def:?}"; }
  fnc_invalid_syntax(){ echo -e "${YLW:?} >> INVALID OPTION SYNTAX, USE THE -${cyn:?}help${YLW:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  fnc_list_all(){ IFS=$'\n'; bounce_list=( "$(docker container list --format "{{.Names}}")" ); }
  fnc_list_default(){ IFS=$'\n'; bounce_list=( "${stacks_default[@]}" ); }
  fnc_list_preset(){ IFS=$'\n'; bounce_list=( "${stacks_preset[@]}" ); }
  fnc_docker_compose_stop(){ bash "${docker_scripts}/docker_compose_stop.sh" "${bounce_list[*]}"; }
  fnc_docker_compose_start(){ bash "${docker_scripts}/docker_compose_start.sh" "${bounce_list[*]}"; }

# determine script output according to option entered
  case "${1}" in
    (-*)
      case "${1}" in
        ("-a"|"--all") fnc_list_all ;;
        ("-d"|"--default") fnc_list_default ;;
        ("-p"|"--preset") fnc_list_preset ;;
        (*) fnc_invalid_syntax ;;
      esac
      ;;
    (*)
      container_list=("$(docker container list --format {{.Names}})")
      for name in ${!container_list}; do

        # case "${bounce_list[@]}" in
        #   (*${name}*)
        #     echo "present"
        #     ;;
        #   (*)
        #     echo "not present"
        #     ;;
        # esac

        if [[ " ${bounce_list[*]} " == *"${name}"* ]]; then
          break
        fi

      done
      bounce_list=("${@}")
      ;;
  esac

# # display script intro
#   fnc_script_intro
# remove all stacks in list defined above
  fnc_docker_compose_stop "${bounce_list[*]}"
  # . /opt/docker/scripts/.docker_compose_stop.sh "${bounce_list[*]}"
  # dcd "${bounce_list[*]}"

# (re)deploy all stacks in list defined above
  fnc_docker_compose_start "${bounce_list[*]}"
  # . /opt/docker/scripts/.docker_compose_start.sh "${bounce_list[*]}"
  # dcu "${bounce_list[*]}"

# # display script outro
#   fnc_script_outro