#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/.bash-colors.env
  source /share/docker/scripts/.docker_vars.env
  source /share/docker/vars/swarm_stacks.conf
  remove_list=""

# Help message for script
helpFunction(){
  echo -e "${blu}[-> This script removes a single or pre-defined list of Docker Swarm stack(s) <-]${DEF}"
  echo
  echo -e "  SYNTAX: # dsr ${CYN}stack_name${DEF}"
  echo -e "  SYNTAX: # dsr -${CYN}option${DEF}"
  echo -e "    VALID OPTIONS:"
  echo -e "      -${CYN}all${DEF}       │ Removes all stacks currently listed with 'docker stack ls' command."
  echo -e "      -${CYN}listed${DEF}    │ Removes the '${CYN}listed${DEF}' array of stacks defined in '${YLW}${docker_vars}/${CYN}swarm_stacks.conf${DEF}'"
  echo -e "      -${CYN}default${DEF}   │ Removes the '${CYN}default${DEF}' array of stacks defined in '${YLW}${docker_vars}/${CYN}swarm_stacks.conf${DEF}'"
  echo -e "      -${CYN}h${DEF} │ -${CYN}help${DEF} │ Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# Command header
  # echo -e "${blu}[-> DOCKER SWARM STACK REMOVAL SCRIPT <-]${def}"

# determine script output according to option entered
  case "${1}" in 
    (-*)
      case "${1}" in
        (""|"-h"|"-help"|"--help") helpFunction ;;
        ("-all") IFS=$'\n'; remove_list=( "$(docker stack ls --format {{.Name}})" ) ;;
        ("-listed") IFS=$'\n'; remove_list=( "${stacks_listed[@]}" ) ;;
        ("-default") IFS=$'\n'; remove_list=( "${stacks_default[@]}" ) ;;
        (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1 ;;
      esac
    ;;
    (*) remove_list=("$@")
    ;;
  esac

# # Define which stack to remove using command options
#   if [[ $1 = "" ]] || [[ $1 = "-h" ]] || [[ $1 = "-help" ]] ; then helpFunction
#   elif [[ $1 = "-all" ]]; then IFS=$'\n' remove_list=( "$(docker stack ls --format {{.Name}})" ); 
#   elif [[ $1 = "-listed" ]]; then IFS=$'\n' remove_list=( "${stacks_listed[@]}" );
#   elif [[ $1 = "-default" ]]; then IFS=$'\n' remove_list=( "${stacks_default[@]}" );
#   else remove_list=("$@")
#   fi

# Remove indicated stacks
  # echo -e "${blu}[-> REMOVING LISTED STACK(S) <-]${def}"
  # de-duplicate remove_list entries
  remove_list=(`for stack in "${remove_list[@]}" ; do echo "$stack" ; done | sort -u`)
  # echo " -> ${remove_list[@]}"
  # echo

# Remove indicated stack(s)
  for stack in "${remove_list[@]}"; do
    if [ ! "$(docker service ls --filter label=com.docker.stack.namespace=$stack -q)" ];
      then echo -e " ${red}ERROR: ${YLW}STACK NAME${DEF} '${CYN}$stack${DEF}' ${YLW}NOT FOUND${DEF} ";
      # echo; exit 1
    else
      # echo -e "${CYN} -> REMOVE '${cyn}$stack${CYN}' STACK <-${DEF}";
      docker stack rm "$stack"
      [[ -f ${swarm_configs}/${stack}/.env ]] && rm -f ${swarm_configs}/${stack}/.env
      # Pause until stack is removed
      while [ "$(docker service ls --filter label=com.docker.stack.namespace=$stack -q)" ] || [ "$(docker network ls --filter label=com.docker.stack.namespace=$stack -q)" ]; 
        do sleep 1; 
      done
      echo -e "${RED} -- '${cyn}$stack${RED}' STACK ${red}REMOVED${RED} -- ${DEF}"; echo
    fi
  done

# Clear the 'remove_list' array now that we are done with it
  unset remove_list IFS

# Print script complete message
  # echo -e "${GRN}[-- STACK REMOVE SCRIPT COMPLETE --]${DEF}"
  # echo