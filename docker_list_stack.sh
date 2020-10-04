#!/bin/bash
# external variable & command sources
  source /share/docker/scripts/.bash_colors.env

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script lists current '${CYN}stacknames${blu}' and the number of '${cyn}services${blu}' in that stack <-]${def} "
    echo -e "${blu} ->   It will also list services inside a '${CYN}stacknames${blu}' when passing one of the below options <-]${def} "
    echo
    echo -e "  SYNTAX: # dls ${cyn}stackname${def} │ this is the same as with '-sv' option"
    echo -e "  SYNTAX: # dls ${cyn}stackname${def} -${cyn}option${def}"
    echo -e "    VALID OPTION(S):"
    echo -e "      -${cyn}sv${def} │ Displays '${CYN}docker stack services ${cyn}stackname${def}' output with custom selected columns."
    echo -e "      -${cyn}ps${def} │ Displays '${CYN}docker stack ps --no-trunc ${cyn}stackname${def}' output with non-truncated entries and select columns."
    echo
    echo -e "  SYNTAX: # dls -${cyn}option${def}"
    echo -e "    VALID OPTION(S):"
    echo -e "      ${CYN}-h${def} | ${CYN}-help${def} │ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }
  # to list possible --format tags, type 'docker command --format='((json .}}''
  fnc_script_intro(){ echo -e "${blu}[-> LIST OF CURRENT DOCKER SWARM STACKS <-]${DEF} "; }
  fnc_nothing_to_do(){ echo -e "${YLW} -> no current docker swarm stacks exist${DEF}"; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE '${DEF}--${cyn}help${YLW}' OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_list_services(){ docker service ps "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Ports}}"; }
  fnc_list_service_errors(){ docker service ps "${1}" --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}"; }
  fnc_list_stacks(){ docker stack ls; }
  fnc_list_stack_services(){ docker stack services "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Replicas}}\t{{.Image}}\t{{.CurrentState}}\t{{.Ports}}"; }
  fnc_list_stack_errors(){ docker stack ps --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}" "${1}"; }
  fnc_list_container_network(){ docker container ls --format "table {{.ID}} ~ {{.Names}}\t{{.Networks}}\t{{.Ports}}\t{{.Status}}"; }
  fnc_list_container_volumes(){ docker container ls --format "table {{.ID}} ~ {{.Names}}\t{{.LocalVolumes}}\t{{.Mounts}}\t{{.Status}}"; }
  fnc_list_container_errors(){ docker container ps --no-trunc --format "table {{.ID}} ~ {{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}" "${1}"; }

# determine script output according to option entered
  case "${1}" in 
    ("") fnc_script_intro;
      if [ ! "$(docker stack ls)" = "NAME                SERVICES" ];
      then fnc_list_stacks;
      else fnc_nothing_to_do;
      fi
      ;;
    (-*)
      case "${1}" in
        ("-"|"-h"|"-help"|"--help") fnc_help ;;
        (*) fnc_invalid_syntax ;;
      esac
      ;;
    (*) fnc_script_intro;
      case "${2}" in
        ("") fnc_list_stack_services ;;
        (-*)
          case "${2}" in
            ("-sv") fnc_list_stack_services ;;
            ("-er"|"--errors") fnc_list_stack_errors ;;
            (*) fnc_invalid_syntax ;;
          esac
          ;;
        (*) fnc_invalid_syntax ;;
      esac
      ;;
  esac
  echo