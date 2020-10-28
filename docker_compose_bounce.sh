#!/bin/bash
# external variable sources
  source /share/docker/scripts/.script_vars.conf
  source /share/docker/secrets/.compose_stacks.conf

# script variable definitions
  unset bounce_list IFS

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script bounces (removes then re-deploys) a single or pre-defined list of Docker Swarm stack <-]${DEF}"
    echo -e " -"
    echo -e " - SYNTAX: # dsb ${cyn}stack_name${DEF}"
    echo -e " - SYNTAX: # dsb ${cyn}-option${DEF}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn}-a | --all     ${DEF}│ Bounces all stacks with a corresponding folder inside the '${YLW}${compose_configs}/${DEF}' path."
    echo -e " -     ${cyn}-p | --preset  ${DEF}│ Bounces the 'preset' array of stacks defined in '${YLW}${docker_vars}/${cyn}compose_stacks.conf${DEF}'"
    echo -e " -     ${cyn}-d | --default ${DEF}│ Bounces the 'default' array of stacks defined in '${YLW}${docker_vars}/${cyn}compose_stacks.conf${DEF}'"
    echo -e " -     ${cyn}-h │ --help    ${DEF}│ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu}[-> STOP THEN RESTART LISTED CONTAINERS <-]${DEF}"; echo -e "${cyn} -> ${bounce_list[@]} ${DEF}"; echo; }
  fnc_script_outro(){ echo -e "[-- ${GRN}BOUNCE (REMOVE & REDEPLOY) STACK SCRIPT COMPLETE${DEF} --]"; echo; }
  fnc_nothing_to_do(){ echo -e "${YLW} -> no containers exist to bounce${DEF}"; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_list_all(){ IFS=$'\n'; bounce_list=( $(docker stack ls --format {{.Name}}) ); }
  fnc_list_preset(){ IFS=$'\n'; bounce_list=( "${stacks_preset[@]}" ); }
  fnc_list_default(){ IFS=$'\n'; bounce_list=( "${stacks_default[@]}" ); }
  fnc_docker_stack_stop(){ sh ${docker_scripts}/docker_stack_stop.sh "${bounce_list[@]}"; }
  fnc_docker_stack_start(){ sh ${docker_scripts}/docker_stack_start.sh "${bounce_list[@]}"; }

# determine script output according to option entered
  case "${1}" in 
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-a"|"--all") fnc_list_all ;;
        ("-p"|"--preset") fnc_list_preset ;;
        ("-d"|"--default") fnc_list_default ;;
        (*) fnc_invalid_syntax ;;
      esac
    ;;
    (*) bounce_list=("$@") ;;
  esac

# # display script intro
#   fnc_script_intro
# remove all stacks in list defined above
  fnc_docker_stack_stop
# (re)deploy all stacks in list defined above
  fnc_docker_stack_start
# # display script outro
#   fnc_script_outro