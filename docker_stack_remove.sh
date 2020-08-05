#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/scripts/.docker_vars.env
  source /share/docker/swarm/swarm_stacks.conf
  unset remove_list IFS

# Help message for script
helpFunction(){
  echo -e "${blu}[-> This script removes a single or pre-defined list of Docker Swarm stack(s) <-]${DEF}"
  echo
  echo -e "  SYNTAX: # dsr ${cyn}stack_name${DEF}"
  echo -e "  SYNTAX: # dsr -${cyn}option${DEF}"
  echo -e "    VALID OPTIONS:"
  echo -e "      -${cyn}all${DEF}       │ Removes all stacks currently listed with 'docker stack ls' command."
  echo -e "      -${cyn}listed${DEF}    │ Removes the '${cyn}listed${DEF}' array of stacks defined in '${YLW}${docker_vars}/${cyn}swarm_stacks.conf${DEF}'"
  echo -e "      -${cyn}default${DEF}   │ Removes the '${cyn}default${DEF}' array of stacks defined in '${YLW}${docker_vars}/${cyn}swarm_stacks.conf${DEF}'"
  echo -e "      -${cyn}h${DEF} │ -${cyn}help${DEF} │ Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# determine script output according to option entered
  case "${1}" in 
    (-*)
      case "${1}" in
        (""|"-h"|"-help"|"--help") helpFunction ;;
        ("-all") IFS=$'\n'; remove_list=("$(docker stack ls --format {{.Name}})") ;;
        ("-listed") IFS=$'\n'; remove_list=("${stacks_listed[@]}") ;;
        ("-default") IFS=$'\n'; remove_list=("${stacks_default[@]}") ;;
        (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1 ;;
      esac
    ;;
    (*) remove_list=("$@") ;;
  esac

# Remove indicated stacks
  # echo -e "${blu}[-> REMOVING LISTED STACK(S) <-]${def}"
  # de-duplicate and remove carriage returns in remove_list entries
  remove_list=(`for stack in "${remove_list[@]}"; do echo "${stack}"; done | sort -u`)
  # echo " -> ${remove_list[@]}"; echo

# Remove indicated stack(s)
  if [[ ! "${remove_list}" ]]; 
  then echo -e "${YLW} -> no docker stacks to remove${DEF} "; 
  else
    for stack in "${remove_list[@]}"; do
      if [ ! "$(docker service ls --filter label=com.docker.stack.namespace=$stack -q)" ];
      then echo -e " ${red}ERROR: ${YLW}STACK NAME${DEF} '${cyn}$stack${DEF}' ${YLW}NOT FOUND${DEF} "; # echo; exit 1
      else # echo -e "${CYN} -> REMOVE '${cyn}$stack${CYN}' STACK <-${DEF}";
        docker stack rm "$stack"
        [ -f "${swarm_configs}/${stack}/.env" ] && rm -f "${swarm_configs}/${stack}/.env"
        # Pause until stack is removed
        while [ "$(docker service ls --filter label=com.docker.stack.namespace=$stack -q)" ] || [ "$(docker network ls --filter label=com.docker.stack.namespace=$stack -q)" ]; 
        do sleep 1; 
        done
        echo -e "${RED} -- '${cyn}$stack${RED}' STACK ${red}REMOVED${RED} -- ${DEF}"; echo
      fi
    done
  fi

# Print script complete message
  # echo -e "${GRN}[>> STACK REMOVE SCRIPT COMPLETE <<]${DEF}"
  # echo