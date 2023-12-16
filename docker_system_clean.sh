#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# function definitions
  fnc_help_system_clean(){
    echo -e "${blu:?}[-> This script cleans (removes) '${cyn:?}container${blu:?}' ${cyn:?}images${def:?}, ${cyn:?}volumes${def:?} and ${CUR}unused${def:?} ${cyn:?}networks${def:?} <-]${def:?} "
    echo -e " -"
    echo -e " - SYNTAX: # dclean"
    echo -e " - SYNTAX: # dclean ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn:?}-a │ --all  ${def:?}│ Stops all containers then removes all ${cyn:?}container${blu:?} ${cyn:?}images${def:?}, ${cyn:?}volumes${def:?} and ${cyn:?}networks${def:?}"
    echo -e " -     ${cyn:?}-c │ --containers  ${def:?}│ Stops all containers then removes all ${CUR}exited ${cyn:?}container${def:?}"
    echo -e " -     ${cyn:?}-i │ --images  ${def:?}│ Stops all containers then removes all ${CUR}dangling ${cyn:?}images${def:?}"
    echo -e " -     ${cyn:?}-n │ --networks  ${def:?}│ Stops all containers then removes all ${CUR}unused ${cyn:?}networks${def:?}"
    echo -e " -     ${cyn:?}-v │ --volumes  ${def:?}│ Stops all containers then removes all ${cyn:?}volumes${def:?}"
    echo -e " -"
    echo -e " -     ${cyn:?}-h │ --help ${def:?}│ Displays this help message"
    echo
    exit 1 # Exit script after printing help
    }
  case "$1" in ("-h"|*"help"*) fnc_help_system_clean ;; esac

  fnc_script_intro(){ echo -e "${blu:?}[-  ${ylw:?}STARTING${blu:?} CLEANUP OF THE DOCKER SYSTEM (CONTAINERS, IMAGES, VOLUMES, NETWORKS)  -]${def:?}"; }
  fnc_script_outro(){ echo -e "${blu:?}[-  DOCKER SYSTEM CLEANUP ${grn:?}COMPLETED${blu:?} -]${def:?}"; echo; }
  fnc_nothing_to_do(){ echo -e "${ylw:?} -> No cleanup to be done.${def:?}"; }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE ${cyn:?}-help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  fnc_operation_message(){ echo -e "${blu:?}[-> REMOVE UNUSED DOCKER ${mgn:?}${operation_type}${def:?}"; }
  fnc_clean_volumes(){
    fnc_operation_message;
    #docker volume ls -qf dangling=true | xargs -r docker volume rm;
    VOLUMES_DANGLING=$(docker volume ls -qf dangling=true);
    if [[ ! ${VOLUMES_DANGLING} = "" ]];
    then docker volume rm ${VOLUMES_DANGLING};
    else echo -e " - ${ylw:?}No dangling volumes to remove.${def:?}";
    fi
    echo
  }
  fnc_clean_networks(){
    fnc_operation_message;
    #docker network ls | grep "bridge";
    NETWORKS_BRIDGED="$(docker network ls | grep "bridge" | awk '/ / { print $1 }')";
    if [[ ! ${NETWORKS_BRIDGED} = "" ]];
    then docker network rm ${NETWORKS_BRIDGED};
    else echo -e " - No disconnected, bridged networks to remove.";
    fi
    echo
  }
  fnc_clean_images(){
    fnc_operation_message;
    #docker images
    IMAGES_DANGLING=$(docker images --filter "dangling=true" -q --no-trunc);
    # IMAGES_DANGLING="$(docker images --filter "dangling=false" -q)";
    if [[ ! ${IMAGES_DANGLING} = "" ]]
    then docker rmi ${IMAGES_DANGLING};
    else echo -e " - ${ylw:?}No dangling images to remove.${def:?}";
    fi
    #docker images | grep "none"
    IMAGES_NONE=$(docker images | grep "none" | awk '/ / { print $3 }');
    if [[ ! ${IMAGES_NONE} = "" ]];
    then docker rmi ${IMAGES_NONE};
    else echo -e " - ${ylw:?}No unassigned images to remove.${def:?}";
    fi
    echo
  }
  fnc_clean_containers(){
    fnc_operation_message;
    #docker ps
    #docker ps -a
    CONTAINERS_EXITED=$(docker ps -qa --no-trunc --filter "status=exited");
    if [[ ! ${CONTAINERS_EXITED} = "" ]];
    then docker rm ${CONTAINERS_EXITED};
    else echo -e " - ${ylw:?}No exited containers to remove.${def:?}";
    fi
    echo
  }

# option logic action determination
  case "${1}" in
    ("")
      fnc_invalid_syntax
      ;;
    (-*) # validate entered option exists
      # fnc_script_intro
      case "${1}" in
        ("-a"|"--all")
          operation_type="containers"; fnc_clean_containers
          operation_type="images"; fnc_clean_images
          # operation_type="networks"; fnc_clean_networks
          # operation_type="volumes"; fnc_clean_volumes
          ;;
        ("-c"|"--containers")
          operation_type="containers"; fnc_clean_containers
          ;;
        ("-i"|"--images")
          operation_type="images"; fnc_clean_images
          ;;
        ("-n"|"--networks")
          operation_type="networks"; fnc_clean_networks
          ;;
        ("-v"|"--volumes")
          operation_type="volumes"; fnc_clean_volumes
          ;;
        (*)
          fnc_invalid_syntax
          ;;
      esac
      ;;
    (*)
      fnc_invalid_syntax
      ;;
  esac

  fnc_script_outro