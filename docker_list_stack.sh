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
  fnc_script_intro(){ echo -e "${blu}[-> LIST OF CURRENT DOCKER SWARM STACKS <-]${DEF} "; }
  fnc_script_error(){ echo -e "${blu}[-> LIST OF DOCKER SWARM STACK ${red}ERRORS${blu} <-]${DEF} "; }
  fnc_nothing_to_do(){ echo -e "${YLW} -> no current docker swarm stacks exist${DEF}"; }
  fnc_not_swarm_node(){ echo -e "${YLW} -> this docker node is not a swarm manager ${DEF}"; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE '${DEF}--${cyn}help${YLW}' OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; }
  # to list possible --format tags, type 'docker command --format='((json .}}''
  fnc_stack_lst(){ docker stack ls; }
  fnc_stack_svc(){ docker stack services "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Replicas}}\t{{.Image}}\t{{.Ports}}"; }
  fnc_stack_err(){ docker stack ps --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}" "${1}"; }
  fnc_error_check(){ docker stack ps --no-trunc --format "{{.Error}}" "${1}"; }
  fnc_service_lst(){ docker service ps "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Ports}}"; }
  fnc_service_err(){ docker service ps "${1}" --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}"; }

  # fnc_check_errors(){ docker service ps "${1}" --format "{{.Error}}"; }
  # fnc_list_service_all(){ docker service ps "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Ports}}"; }
  # fnc_list_service_err(){ docker service ps "${1}" --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}"; }
  # fnc_list_container_err(){ docker service ps --no-trunc --format "table {{.Node}}\t{{.ID}}\t{{.Names}}\t{{.Error}}" "${1}"; }
  # fnc_docker_node_list(){ docker node ps $(docker node ls -q) --format "table {{.Node}}\t{{.Name}}\t{{.CurrentState}}" --filter desired-state=Running | uniq; }

# determine script output according to option entered
  case "${1}" in 
    ("") fnc_script_intro; 
      case "$(docker stack ls)" in
        ("NAME                SERVICES") fnc_nothing_to_do ;;
        # Error*) fnc_not_swarm_node ;;
        ("Error response from daemon: This node is not a swarm manager. Use \"docker swarm init\" or \"docker swarm join\" to connect this node to swarm and try again.") fnc_not_swarm_node ;;
        (*) fnc_stack_lst ;;
      esac
      ;;
    (-*)
      case "${1}" in
        ("-"|"-h"|"-help"|"--help") fnc_help ;;
        (*) fnc_invalid_syntax ;;
      esac
      ;;
    (*) 
      case "${2}" in
        (-*)
          case "${2}" in
            ("-sv"|"--services") fnc_script_intro; fnc_stack_svc ;;
            ("-er"|"--errors") fnc_script_error; fnc_stack_err ${1} ${2} ;;
            (*) fnc_invalid_syntax ;;
          esac
          ;;
        (*) 
          case fnc_error_check in 
            ("") fnc_script_intro; fnc_stack_svc ${1} ${2} ;;
            (*) fnc_script_error; fnc_stack_err ${1} ${2} ;; 
          esac
          ;;
      esac
      ;;
  esac
  echo

# docker container --format='{{json .}}'
# {{.Command}}
# {{.CreatedAt}}
# {{.ID}}
# {{.Image}}
# {{.Labels}}
# {{.LocalVolumes}}
# {{.Mounts}}
# {{.Names}}
# {{.Networks}}
# {{.Ports}}
# {{.RunningFor}}
# {{.Size}}
# {{.Status}}


# ONLY WITH SWARM

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
