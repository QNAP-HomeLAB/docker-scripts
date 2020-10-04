#!/bin/bash
# external variable sources
  source /share/docker/scripts/.bash_colors.env

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script lists current '${CYN}stacknames${blu}' and the number of '${cyn}services${blu}' in that stack <-]${def} "
    echo -e "${blu} ->   It will also list services inside a '${CYN}stacknames${blu}' when passing one of the below options <-]${def} "
    echo
    echo -e "SYNTAX: # dls -${cyn}option${def}"
    echo -e "  VALID OPTION(S):"
    echo -e "    -h │ -help   Displays this help message."
    echo
    echo -e "SYNTAX: # dls ${cyn}stackname${def}"
    echo -e "SYNTAX: # dls ${cyn}stackname${def} -${cyn}option${def}"
    echo -e "  VALID OPTION(S):"
    echo -e "    -ps   Displays '${CYN}docker container ps --no-trunc ${cyn}stackname${def}' output with non-truncated entries and select columns."
    echo -e "    -sv   Displays '${CYN}docker container services ${cyn}stackname${def}' output with custom selected columns."
    echo -e "    -n │ --net │ --network  Displays '${CYN}docker container ls' output with networking specific columns."
    echo -e "    -v │ --vol │ --volumes  Displays '${CYN}docker container ls' output with volume/mount specific columns."
    echo
    exit 1 # Exit after printing help
    };
  # to list possible --format tags, type 'docker command --format='((json .}}''
  fnc_script_intro(){ echo -e "${blu}[-> LIST OF CURRENT DOCKER CONTAINERS <-]${DEF} "; };
  fnc_nothing_to_do(){ echo -e "${YLW} -> no current docker containers exist${DEF}"; };
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE '--${cyn}help${YLW}' OPTION TO DISPLAY PROPER SYNTAX${DEF} <<"; exit 1; };
  fnc_check_containers(){ docker container ls -a -q; };
  fnc_check_errors(){ docker service ps "${1}" --format "{{.Error}}"; };
  fnc_list_service(){ docker service ps "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Ports}}"; };
  fnc_list_service_errors(){ docker service ps "${1}" --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}"; };
  fnc_list_container(){ docker container ls --format "table {{.ID}} ~ {{.Names}}\t{{.Image}}\t{{.Command}}\t{{.Status}}\t{{.RunningFor}}"; };
  fnc_list_container_network(){ docker container ls --format "table {{.ID}} ~ {{.Names}}\t{{.Networks}}\t{{.Ports}}\t{{.Status}}"; };
  fnc_list_container_volumes(){ docker container ls --format "table {{.ID}} ~ {{.Names}}\t{{.LocalVolumes}}\t{{.Mounts}}\t{{.Status}}"; };
  fnc_list_container_errors(){ docker container ps --no-trunc --format "table {{.Node}}\t{{.ID}}\t{{.Name}}\t{{.CurrentState}}\t{{.Error}}" "${1}"; };

# output determination logic
  case "${1}" in 
    ("") fnc_script_intro;
      if [ ! "$(fnc_check_containers)" ]; 
      then fnc_nothing_to_do;
      # else docker container ls;
      else fnc_list_container;
      fi
      ;;
    (-*)
      case "${1}" in
        (""|"-h"|"-help"|"--help") fnc_help ;;
        ("-n"|"--net"|"--network") fnc_script_intro; fnc_list_container_network ;;
        ("-v"|"--vol"|"--volumes") fnc_script_intro; fnc_list_container_volumes ;;
        (*) fnc_invalid_syntax ;;
      esac
      ;;
    (*)
      case "${2}" in
        ("") fnc_script_intro;
          if [ ! "$(fnc_check_errors)" ]; then fnc_list_service; else fnc_list_service_errors; fi
          ;;
        (-*)
          case "${2}" in
            ("-ps") fnc_script_intro; fnc_list_container_errors ;;
            ("-sv") fnc_script_intro; fnc_list_container ;;
            (*) fnc_invalid_syntax 1 ;;
          esac
      esac
      ;;
  esac
  echo