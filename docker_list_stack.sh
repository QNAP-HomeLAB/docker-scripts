#!/bin/bash

# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-> This script lists current '${cyn:?}stacknames${blu:?}' and the number of '${cyn:?}services${blu:?}' in that stack <-]${def:?} "
    echo -e "${blu:?} ->   It will also list services inside a '${cyn:?}stacknames${blu:?}' when passing one of the below options <-]${def:?} "
    echo -e " -"
    echo -e " - SYNTAX: # dls ${cyn:?}stackname${def:?} │ this is the same as with '-sv' option"
    echo -e " - SYNTAX: # dls ${cyn:?}stackname${def:?} ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn:?}-e | --errors${def:?}   │ Displays '${cyn:?}docker stack ps --no-trunc ${cyn:?}stackname${def:?}' output with non-truncated entries and select columns."
    echo -e " -     ${cyn:?}-s | --services${def:?} │ Displays '${cyn:?}docker stack services ${cyn:?}stackname${def:?}' output with custom selected columns."
    echo -e " -"
    echo -e " - SYNTAX: # dls ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn:?}-h | --help${def:?} │ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu:?}[-> LIST OF CURRENT DOCKER SWARM STACKS <-]${def:?} "; }
  fnc_script_error(){ echo -e "${blu:?}[-> LIST OF DOCKER SWARM STACK ${red:?}ERRORS${blu:?} <-]${def:?} "; }
  fnc_nothing_to_do(){ echo -e "${ylw:?} -> no current docker swarm stacks exist${def:?}"; }
  fnc_not_swarm_node(){ echo -e "${ylw:?} -> this docker node is not a swarm manager ${def:?}"; }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE '${cyn:?}--help${ylw:?}' OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; }
  fnc_stack_lst(){ docker stack ls; }
  fnc_stack_svc(){ docker stack services "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Ports}}"; }
  fnc_stack_err(){ docker stack ps --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}" "${1}"; }
  fnc_stack_chk(){ docker stack ps --no-trunc --format "{{.Error}}" "${1}"; }

  # fnc_node_lst(){ docker node ps "$(docker node ls -q)" --format "table {{.Node}}\t{{.Name}}\t{{.CurrentState}}" --filter desired-state=Running | uniq; }

# determine script output according to option entered
  case "${1}" in
    ("")
      fnc_script_intro;
      case "$(fnc_stack_lst)" in
        ("NAME                SERVICES")
          fnc_nothing_to_do;
          ;;
        ("Error response from daemon: This node is not a swarm manager. Use \"docker swarm init\" or \"docker swarm join\" to connect this node to swarm and try again.")
          fnc_not_swarm_node;
          ;;
        (*)
          fnc_stack_lst;
          ;;
      esac
      ;;
    (-*) # confirm entered option is valid
      case "${1}" in
        ("-"|"-h"|"-help"|"--help")
          fnc_help
          ;;
        (*)
          fnc_invalid_syntax
          ;;
      esac
      ;;
    (*)
      case "${2}" in
        (-*) # confirm entered option is valid
          case "${2}" in
            ("-e"|"--errors")
              fnc_script_error;
              fnc_stack_err "${1}" "${2}";
              ;;
            ("-s"|"--services")
              fnc_script_intro;
              fnc_stack_svc "${1}" "${2}";
              ;;
            (*)
              fnc_invalid_syntax;
              ;;
          esac
          ;;
        (*)
          fnc_script_intro;
          case "$(fnc_stack_chk "${1}" "${2}")" in
            ("")
              fnc_stack_svc "${1}" "${2}";
              ;;
            (*)
              fnc_stack_err "${1}" "${2}";
              ;;
          esac
          ;;
      esac
      ;;
  esac
  echo

# to list possible --format tags, type 'docker command --format='{{json .}}''

# docker stack services traefik --format='{{json .}}'
# {{.ID}}
# {{.Image}}
# {{.Mode}}
# {{.Name}}
# {{.Ports}}
# {{.Replicas}}

# docker service ps traefik_app --format='{{json .}}'
# {{.CurrentState}}
# {{.DesiredState}}
# {{.Error}}
# {{.ID}}
# {{.Image}}
# {{.Name}}
# {{.Node}}
# {{.Ports}}

  # fnc_service_lst(){ docker service ps "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Image}}\t{{.Node}}\t{{.CurrentState}}"; }
  # fnc_service_err(){ docker service ps "${1}" --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}"; }
  # fnc_container_lst(){ docker service ps --no-trunc --format "table {{.Node}}\t{{.ID}}\t{{.Names}}\t{{.Error}}" "${1}"; }
  # fnc_container_err(){ docker service ps --no-trunc --format "table {{.Node}}\t{{.ID}}\t{{.Names}}\t{{.Error}}" "${1}"; }
