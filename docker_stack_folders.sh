#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/scripts/.docker_vars.env

# Help message for script
helpFunction(){
  echo -e "${blu}[-> This script creates ${CYN}Drauku's${blu} folder structure for the listed stack(s). <-]${DEF}"
  echo -e "      ${blu}(modified from ${CYN}gkoerk's${blu} famously awesome folder structure for stacks.)${DEF}"
  echo
  echo -e "  Enter up to nine(9) stack_names in a single command, separated by a 'space' character: "
  echo -e "    SYNTAX: dsf ${cyn}stack_name1${DEF} ${cyn}stack_name2${DEF} ... ${cyn}stack_name9${DEF}"
  echo -e "    SYNTAX: dsf -${cyn}option${DEF}"
  echo -e "      VALID OPTIONS:"
  echo -e "        -${cyn}h${DEF} │ -${cyn}help${DEF}   Displays this help message."
  echo
  echo -e "    The below folder structure is created for each 'stack_name' entered with this command:"
  echo -e "        ${YLW}${swarm_appdata}/${cyn}stack_name${DEF}"
  echo -e "        ${YLW}${swarm_configs}/${cyn}stack_name${DEF}"
  # echo -e "        ${YLW}${swarm_runtime}/${cyn}stack_name${DEF}"
  # echo -e "        ${YLW}/share/swarm/secrets/${cyn}stack_name${DEF}"
  echo
  exit 1 # Exit script after printing help
}

# determine script output according to option entered
  case "${1}" in 
    (-*) # validate and perform option
      case "${1}" in
        (""|"-h"|"-help"|"--help") helpFunction ;;
        (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1 ;;
      esac
    ;;
    (*) # Create folder structure
      # echo -e "${blu}[-> CREATE DOCKER SWARM FOLDER STRUCTURE FOR LISTED STACKS <-]${def}"
      # echo " -> $@"
      # echo
      mkdir -p ${swarm_appdata}/{$1,$2,$3,$4,$5,$6,$7,$8,$9};
      mkdir -p ${swarm_configs}/{$1,$2,$3,$4,$5,$6,$7,$8,$9};
      # mkdir -p ${swarm_runtime}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}
      # mkdir -p ${secrets_folder}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}

      # # Change all swarm folders to the 'dockuser' 'user:group' values
      # chown -R ${var_user}:${var_group} ${docker_folder};
      # echo "FOLDER OWNERSHIP UPDATED"
      # echo 
      ;;
  esac

# Print script complete message
  # echo -e "${GRN} -> SWARM STACK FOLDERS CREATED${DEF}"
  # echo