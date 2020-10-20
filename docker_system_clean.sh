#!/bin/bash
# external variable sources
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/secrets/.docker_vars.env

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script cleans (removes) '${CYN}container${blu}' ${cyn}images${def}, ${cyn}volumes${def} and ${CUR}unused${def} ${cyn}networks${def} <-]${def} "
    echo
    echo -e "  SYNTAX: # dclean"
    echo -e "  SYNTAX: # dclean -${cyn}option${def}"
    echo -e "    VALID OPTION(S):"
    echo -e "      -a │ --all    Stops all containers then removes all '${CYN}container${blu}' ${cyn}images${def}, ${cyn}volumes${def} and ${CUR}unused${def} ${cyn}networks${def}"
    echo -e "      -h │ --help   Displays this help message"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_dclean(){
    echo -e "${blu} -> REMOVE UNUSED DOCKER ${CYN}VOLUMES${DEF}";
      #docker volume ls -qf dangling=true | xargs -r docker volume rm;
      VOLUMES_DANGLING=$(docker volume ls -qf dangling=true);
      if [[ ! ${VOLUMES_DANGLING} = "" ]];
      then docker volume rm ${NETWORKS_DANGLING};
      else echo -e " - ${YLW}No dangling volumes to remove.${DEF}";
      fi
      echo
    #echo -e "${blu} -> REMOVE UNUSED DOCKER ${CYN}NETWORKS${DEF} ";
    #  #docker network ls | grep "bridge";
    #  NETWORKS_BRIDGED="$(docker network ls | grep "bridge" | awk '/ / { print $1 }')";
    #  if [[ ! ${NETWORKS_BRIDGED} = "" ]];
    #  then docker network rm ${NETWORKS_BRIDGED};
    #  else echo -e " - No disconnected, bridged networks to remove.";
    #  fi
    #  echo
    echo -e "${blu} -> REMOVE UNUSED DOCKER ${CYN}IMAGES${DEF}";
      #docker images
      #IMAGES_DANGLING=$(docker images --filter "dangling=true" -q --no-trunc);
      IMAGES_DANGLING="$(docker images --filter "dangling=false" -q)";
      if [[ ! ${IMAGES_DANGLING} = "" ]]
      then docker rmi ${IMAGES_DANGLING};
      else echo -e " - ${YLW}No dangling images to remove.${DEF}";
      fi
      #docker images | grep "none"
      IMAGES_NONE=$(docker images | grep "none" | awk '/ / { print $3 }');
      if [[ ! ${IMAGES_NONE} = "" ]];
      then docker rmi ${IMAGES_NONE};
      else echo -e " - ${YLW}No unassigned images to remove.${DEF}";
      fi
      echo
    echo -e "${blu} -> REMOVE UNUSED DOCKER ${CYN}CONTAINERS${DEF}";
      #docker ps
      #docker ps -a
      CONTAINERS_EXITED=$(docker ps -qa --no-trunc --filter "status=exited");
      if [[ ! ${CONTAINERS_EXITED} = "" ]];
      then docker rm ${CONTAINERS_EXITED};
      else echo -e " - ${YLW}No exited containers to remove.${DEF}";
      fi
      echo
    }