#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# script variable definitions
  unset action_list IFS
  IFS=' ' action_list=("$@")

# function definitions
  fnc_help_compose_stop(){
    echo -e "${blu:?}[-  This script STOPS or brings DOWN a single Docker container using a pre-written compose file  -]${def:?}"
    echo -e " -"
    echo -e " - SYNTAX: # dcd | dcp | dcr ${cyn:?}stack_name${def:?}"
    # echo -e " - SYNTAX: # dcd ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}-h │ --help   ${def:?}| Displays this help message."
    echo -e " -     ${cyn:?}-d | --Down   ${def:?}| Brings ${red:?}Down${def:?} docker container(s) and associated network(s)."
    echo -e " -     ${cyn:?}-p | --stoP   ${def:?}| ${ylw:?}stoPs${def:?} currently running docker container(s)."
    echo -e " -     ${cyn:?}-r | --Remove ${def:?}| ${ylw:?}stoPs${def:?} and ${red:?}Removes${def:?} listed docker container(s)."
    echo
    exit 1 # Exit script after printing help
    }
  case "$1" in ("-h"|*"help"*) fnc_help_compose_stop ;; esac

  fnc_intro_compose_stop(){ echo -e "${blu:?}[-  ${RED:?}STOPPING${blu:?} LISTED DOCKER CONTAINERS  -]${def:?}"; }
  fnc_outro_compose_stop(){ echo -e "${blu:?}[-  LISTED DOCKER CONTAINERS ${RED:?}STOPPED${blu:?}  -]${def:?}"; }
  fnc_invalid_syntax(){ echo -e "${YLW:?} >> INVALID OPTION SYNTAX, USE THE ${cyn:?}-help${YLW:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  fnc_nothing_to_do(){ echo -e "${YLW:?} -> No compose or stack specified. Expected synatax: ${def:?}dcd ${cyn:?}stack_name${def:?}"; }
  fnc_list_cleanup(){ IFS=$'\n'; action_list=( $(for stack in "${action_list[@]}" ; do echo "${stack}" ; done | sort -u) ); }
  fnc_configs_list_all(){ IFS=$'\n'; action_list=($(docker container list --format {{.Names}})); fnc_list_cleanup; }
  fnc_env_file_remove(){ [[ -f "${docker_compose}/${1}/.env" ]] && rm -f "${docker_compose}/${1}/.env"; }
  fnc_docker_stop(){ docker stop -f "${1}"; }
  fnc_docker_container_rm(){ docker container rm -f "${1}"; fnc_env_file_remove "${1}"; }
  fnc_docker_compose_action(){ docker compose -f "${docker_compose}/${1}/${var_configs_file}" "${action}"; }
  fnc_docker_compose_down(){ docker compose -f "${docker_compose}/${1}/${var_configs_file}" down; } # fnc_env_file_remove "${1}"; }
  fnc_docker_compose_stop(){ docker compose -f "${docker_compose}/${1}/${var_configs_file}" stop; }

  # NOTE: below function order must not change

  fnc_container_action(){
    for stack in "${action_list[@]}"; do
      if [[ -f "${docker_compose}/${stack}/${var_configs_file}" ]]; then
        docker compose -f "${docker_compose}/${stack}/${var_configs_file}" "${action}"
      else
        if [[ "${action}" == "down" ]]; then
          fnc_docker_stop "${stack}"
          fnc_docker_container_rm "${stack}"
        elif [[ "${action}" == "stop" ]]; then
          fnc_docker_stop "${stack}"
        fi
      fi
      sleep 1
    done
  }

  fnc_container_stop(){
    for stack in "${action_list[@]}"; do
      # TODO: check if compose file exists, if not, try to stop container instead
      if [[ -f "${docker_compose}/${stack}/${var_configs_file}" ]]; then
        fnc_docker_compose_stop "${stack}"
      else
        fnc_docker_stop "${stack}"
      fi
      sleep 1
    done
    }
  fnc_container_remove(){
    for stack in "${action_list[@]}"; do
      # TODO: check if compose file exists, if not, try to stop and remove container instead
      if [[ -f "${docker_compose}/${stack}/${var_configs_file}" ]]; then
        fnc_docker_compose_down "${stack}"
      else
        fnc_docker_stop "${stack}"
        fnc_docker_container_rm "${stack}"
      fi
      fnc_env_file_remove "${stack}"
      sleep 1
    done
    }

# option logic action determination
  case "${1}" in
    ("")
      fnc_nothing_to_do
      ;;
    (-*) # validate entered option exists
      case "${1}" in
        ("-d"|"--down")
          fnc_container_remove "${action_list[@]}"
          ;;
        ("-s"|"--stop")
          fnc_container_stop "${action_list[@]}"
          ;;
        ("-r"|"--remove")
          fnc_container_remove "${action_list[@]}"
          ;;
        ("-l"|"--list")
          fnc_configs_list_all
          echo "${action_list[*]}"
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

# fnc_outro_compose_stop