#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env
  # source /opt/docker/swarm/.swarm_stacks.conf

# script variable definitions
  unset remove_list IFS

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-> This script removes a single or pre-defined list of Docker Swarm stack(s) <-]${def:?}"
    echo -e " -"
    echo -e " - SYNTAX: # dsr ${cyn:?}stack_name${def:?}"
    echo -e " - SYNTAX: # dsr ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}-a | --all     ${def:?}│ ${ylw:?}CAUTION${def:?}: Removes ${BLD}all${def:?} stacks currently listed with 'docker stack ls' command."
    echo -e " -     ${cyn:?}-d | --default ${def:?}│ Removes the '${cyn:?}default${def:?}' array of stacks defined in '${ylw:?}${docker_vars}/${cyn:?}swarm_stacks.conf${def:?}'"
    echo -e " -     ${cyn:?}-p | --preset  ${def:?}│ Removes the '${cyn:?}preset${def:?}' array of stacks defined in '${ylw:?}${docker_vars}/${cyn:?}swarm_stacks.conf${def:?}'"
    echo -e " -     ${cyn:?}-h │ --help    ${def:?}│ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu:?}[-> REMOVE THE INDICATED DOCKER STACK(S) <-]${def:?}"; }
  fnc_script_outro(){ echo -e "${grn:?}[>> STACK REMOVE SCRIPT COMPLETE <<]${def:?}"; echo; }
  fnc_nothing_to_do(){ echo -e "${ylw:?} -> between 1 and 9 names must be entered for this command to work${def:?}"; exit 1; }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE -${cyn:?}help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }

  # fnc_stack_remove_list(){ ; }

  fnc_docker_service_list(){ docker service ls --filter label=com.docker.stack.namespace=$stack -q; }
  fnc_docker_network_list(){ docker network ls --filter label=com.docker.stack.namespace=$stack -q; }

  fnc_msg_no_stacks(){ echo -e "${ylw:?} -> no docker stacks to remove${def:?}"; echo; }
  fnc_stack_remove_error(){ echo -e " ${red:?}ERROR: ${ylw:?}STACK NAME${def:?} '${cyn:?}$stack${def:?}' ${ylw:?}NOT FOUND${def:?} "; echo; }
  fnc_stack_remove_success(){ echo -e "${red:?} -- '${cyn:?}$stack${red:?}' STACK ${red:?}REMOVED${red:?} -- ${def:?}"; echo; }

# determine script output according to option entered
  case "${1}" in
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-a"|"--all") IFS=$'\n'; remove_list=("$(docker stack ls --format {{.Name}})") ;;
        ("-d"|"--default") IFS=$'\n'; remove_list=("${stacks_default[@]}") ;;
        ("-p"|"--preset") IFS=$'\n'; remove_list=("${stacks_preset[@]}") ;;
        (*) fnc_invalid_syntax ;;
      esac
    ;;
    (*) remove_list=("$@") ;;
  esac

# Remove indicated stacks
  # echo -e "${blu:?}[-> REMOVING LISTED STACK(S) <-]${def:?}"
  # de-duplicate and remove carriage returns in remove_list entries
  remove_list=(`for stack in "${remove_list[@]}"; do echo "${stack}"; done | sort -u`)
  # echo " -> ${remove_list[@]}"; echo

# Remove indicated stack(s)
  if [[ ! "${remove_list}" ]]
  then fnc_msg_no_stacks
  else
    for stack in "${remove_list[@]}"; do
      if [ ! "$(fnc_docker_service_list)" ];
      then fnc_stack_remove_error
      else # echo -e "${cyn:?} -> REMOVE '${cyn:?}$stack${cyn:?}' STACK <-${def:?}"
        docker stack rm "$stack"
        #[ -f "${docker_swarm}/${stack}/.env" ] && rm -f "${docker_swarm}/${stack}/.env"
        # Pause until stack is removed
        while [ "$(fnc_docker_service_list)" ] || [ "$(fnc_docker_network_list)" ]
        do sleep 1;
        done
        fnc_stack_remove_success
      fi
    done
  fi

  # fnc_script_outro