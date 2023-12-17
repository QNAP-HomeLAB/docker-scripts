#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# script variable definitions
  unset stacks_list IFS
  IFS=' ' stacks_list=("$@")

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

  fnc_intro_compose_stop(){ echo -e "${blu:?}[-  ${red:?}STOPPING${blu:?} LISTED DOCKER CONTAINERS  -]${def:?}"; }
  fnc_outro_compose_stop(){ echo -e "${blu:?}[-  LISTED DOCKER CONTAINERS ${red:?}STOPPED${blu:?}  -]${def:?}"; }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE ${cyn:?}-help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  fnc_nothing_to_do(){ echo -e "${ylw:?} -> No compose or stack specified. Expected synatax: ${def:?}dcd ${cyn:?}stack_name${def:?}"; }

  # fnc_remove_cmd_option(){ for i in "${!stacks_list[@]}"; do if [[ "${stacks_list[i]}" = "-*" || "${stacks_list[i]}" = "." ]]; then unset "${stacks_list[i]}"; fi; done; }
  fnc_remove_cmd_option() { # remove args starting with '-' from array
    local filtered=()
    local args="$@"
    for arg in "${args[@]}"; do
      # if [[ $arg = . ]]; then unset $args[#]; fi
      # if [[ $arg = \-* ]]; then options+=("$arg"); fi
      if [[ $arg != \-* && $arg != . ]]; then filtered+=("$arg"); fi
    done
    option_list=("${options[@]}")
    stacks_list=("${filtered[@]}")
  }

  # fnc_list_sort(){ IFS=$'\n'; stacks_list=( $(for stack in "${stacks_list[@]}" ; do echo "${stack}" ; done | sort -u) ); }
  fnc_list_sort(){ sort_list="${stacks_list[*]}"; IFS=$'\n' read -r stacks_list <<< "$( for stack in "${sort_list[@]}" ; do echo "${stack}" ; done | sort -u )"; }
  # fnc_list_sort(){
  #   stacks_list=();
  #   while IFS=$'' read -r line; do stacks_list+=("$line"); done < <( for stack in "${stacks_list[@]}" ; do echo "${stack}" ; done | sort -u );
  #   }
  fnc_configs_list_all(){ IFS=$'\n'; stacks_list=($(docker container list --format {{.Names}})); fnc_list_sort; }
  # fnc_configs_list_all(){
  #   stacks_list=();
  #   while IFS=$'' read -r line; do stacks_list+=("$line"); done < <( docker container list --format "{{.Names}}" ); fnc_list_sort;
  #   }
  # fnc_configs_list_all(){ IFS=$'\n' read -r -q stacks_list <<< "$( docker container list --format "{{.Names}}" )"; fnc_list_sort; }
  fnc_env_file_remove(){ if [[ -f "${docker_compose:?}/${1}/.env" ]]; then rm -f "${docker_compose:?}/${1}/.env"; fi; }
  fnc_docker_stop(){ docker stop "${1}"; }
  fnc_docker_container_rm(){ docker container rm -f "${1}"; } #fnc_env_file_remove "${1}"; }
  fnc_docker_compose_down(){ docker compose -f "${docker_compose:?}/${1}/${var_configs_file:?}" down; } # fnc_env_file_remove "${1}"; }
  fnc_docker_compose_stop(){ docker compose -f "${docker_compose:?}/${1}/${var_configs_file:?}" stop; }

#### NOTE: below function order must not change

  # TODO: this function might replace individual "rm/down/stop" functions with an "action" variable assigned during case logic
  fnc_container_action(){
    for stack in "${stacks_list[@]}"; do
      if [[ -f "${docker_compose:?}/${stack}/${var_configs_file:?}" ]]; then
        docker compose -f "${docker_compose:?}/${stack}/${var_configs_file:?}" "${action}"
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
    for stack in "${stacks_list[@]}"; do
      # TODO: check if compose file exists, if not, try to stop container instead
      if [[ -f "${docker_compose:?}/${stack}/${var_configs_file:?}" ]]; then
        fnc_docker_compose_stop "${stack}"
      else
        fnc_docker_stop "${stack}"
      fi
      sleep 1
    done
    }
  fnc_container_remove(){
    # stacks_list=($(fnc_remove_cmd_option "${stacks_list[@]}"))
    fnc_remove_cmd_option "${stacks_list[@]}"
    for stack in "${stacks_list[@]}"; do
      # TODO: check if compose file exists, if not, try to stop and remove container instead
      if [[ -f "${docker_compose:?}/${stack}/${var_configs_file:?}" ]]; then
        fnc_docker_compose_down "${stack}"
      else
        fnc_docker_stop "${stack}"
        fnc_docker_container_rm "${stack}"
      fi
      # fnc_env_file_remove "${stack}"
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
        ("-a"|"--all")
          unset stacks_list
          fnc_configs_list_all
          action="down"
          fnc_remove_cmd_option "${stacks_list[@]}"
          fnc_container_remove "${stacks_list[@]}"
          ;;
        ("-d"|"--down")
          # unset "stacks_list[0]"
          action="down"
          fnc_remove_cmd_option "${stacks_list[@]}"
          fnc_container_remove "${stacks_list[@]}"
          ;;
        ("-p"|"--stop")
          # unset "stacks_list[0]"
          action="stop"
          fnc_remove_cmd_option "${stacks_list[@]}"
          fnc_container_stop "${stacks_list[@]}"
          ;;
        ("-r"|"--remove")
          # unset "stacks_list[0]"
          action="rm"
          fnc_remove_cmd_option "${stacks_list[@]}"
          fnc_container_remove "${stacks_list[@]}"
          ;;
        ("-l"|"--list")
          # unset "stacks_list[0]"
          action="ls"
          fnc_remove_cmd_option "${stacks_list[@]}"
          fnc_configs_list_all
          echo "${stacks_list[*]}"
          ;;
        (*)
          fnc_invalid_syntax
          ;;
      esac
      ;;
    (*)
      # fnc_invalid_syntax
      action="down"
      fnc_remove_cmd_option "${stacks_list[@]}"
      fnc_container_remove "${stacks_list[@]}"
      ;;
  esac

# fnc_outro_compose_stop