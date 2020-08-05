#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/scripts/.docker_vars.env
  source /share/docker/swarm/swarm_stacks.conf
  bounce_list=""

# Help message for script
helpFunction(){
  echo -e "${blu}[-> This script bounces (removes then re-deploys) a single or pre-defined list of Docker Swarm stack <-]${DEF}"
  echo
  echo -e "SYNTAX: # dsb ${cyn}stack_name${DEF}"
  echo -e "SYNTAX: # dsb -${cyn}option${DEF}"
  echo -e "  VALID OPTIONS:"
  echo -e "        -${cyn}all${DEF}        │ Bounces all stacks with a corresponding folder inside the '${YLW}${swarm_configs}/${DEF}' path."
  echo -e "        -${cyn}listed${DEF}     │ Bounces the 'listed' array of stacks defined in '${YLW}${docker_vars}/${cyn}swarm_stacks.conf${DEF}'"
  echo -e "        -${cyn}default${DEF}    │ Bounces the 'default' array of stacks defined in '${YLW}${docker_vars}/${cyn}swarm_stacks.conf${DEF}'"
  echo -e "        -${cyn}h${DEF} │ -${cyn}help${DEF} │ Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

  if [[ $1 = "-all" ]]; then
    IFS=$'\n' bounce_list=( $(docker stack ls --format {{.Name}}) ); 
  elif [[ $1 = "-listed" ]]; then
    IFS=$'\n' bounce_list=( "${stacks_listed[@]}" );
  elif [[ $1 = "-default" ]]; then
    IFS=$'\n' bounce_list=( "${stacks_default[@]}" );
  elif [[ -z "$1" ]] || [[ $1 = "" ]] || [[ $1 = "-h" ]] || [[ $1 = "-help" ]] ; then
    helpFunction
  else
    bounce_list=("$@")
  fi

# Remove 'traefik' from the bounce_list array, unless it's the only stack listed
  if [[ ! ${bounce_list[0]} = [tT][rR][aA][eE][fF][iI][kK] ]]; then
    for i in "${!bounce_list[@]}"; do
      if [[ "${bounce_list[i]}" = [tT][rR][aA][eE][fF][iI][kK] ]]; then
        unset 'bounce_list[i]'
      fi
    done
    # Fix null entry remaining from using 'unset' to remove 'traefik' from list
    i=0
    for entry in "${bounce_list[@]}"; do
      fixed_bounce_list[$i]=$entry
      ((++i))
    done
    unset bounce_list IFS
    bounce_list="${fixed_bounce_list[@]}"
    unset fixed_bounce_list
  fi

# Remove all stacks in list defined above
  . ${docker_scripts}/docker_stack_remove.sh "${bounce_list[@]}"

# Deploy all stacks in list defined above
  . ${docker_scripts}/docker_stack_deploy.sh "${bounce_list[@]}"

# Clear the 'bounce_list' array now that we are done with it
  unset bounce_list IFS

  # echo -e "[-- ${GRN}BOUNCE (REMOVE & REDEPLOY) STACK SCRIPT COMPLETE${DEF} --]"
  # echo