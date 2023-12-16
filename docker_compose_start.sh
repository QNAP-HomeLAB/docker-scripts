#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# script variable definitions
  unset stacks_list IFS
  bounce_list=""

# function definitions
  fnc_help_compose_start(){
    echo -e " - ${blu:?}[-> This script STARTS 'up' a single Docker container using a pre-written compose file <-]${def:?}"
    echo -e " -"
    echo -e " - SYNTAX: # dcu | dcs | dct"
    echo -e " - SYNTAX: # dcu ${cyn:?}stack_name${def:?}"
    echo -e " - SYNTAX: # dcu ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}-h │ --help ${def:?}| Displays this help message."
    echo -e " -     ${cyn:?}-a | --all  ${def:?}| Deploys all stacks with a config file inside the '${ylw:?}${docker_compose:?}/${def:?}' path."
    echo -e " -                         NOTE: config files must follow this naming format: '${cyn:?}/stackname${cyn:?}/compose.yml${def:?}'"
    echo
    exit 1 # Exit script after printing help
    }
  case "$1" in ("-h"|*"help"*) fnc_help_compose_start ;; esac

  fnc_script_intro(){ echo -e "${blu:?}[-  ${grn:?}STARTING${blu:?} LISTED DOCKER CONTAINERS  -]${def:?}"; }
  fnc_script_outro(){ echo -e "${blu:?}[-  List of Docker containers ${grn:?}STARTED${blu:?} <-]${def:?}"; }
  fnc_nothing_to_do(){ echo -e "${ylw:?} -> no configuration file exists for the entered stack(s)${def:?}"; }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE ${cyn:?}--help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }

  # # fnc_remove_cmd_option(){ for i in "${!stacks_list[@]}"; do if [[ "${stacks_list[i]}" = "-*" || "${stacks_list[i]}" = "." ]]; then unset "${stacks_list[i]}"; fi; done; }
  # fnc_remove_cmd_option() { # remove elements starting with '-' from array
  #   local filtered=()
  #   for element in "$@"; do
  #     if [[ $element != \-* && $element != . ]]; then
  #       filtered+=("$element")
  #     fi
  #   done
  #   stacks_list=("${filtered[@]}")
  # }

  ## consolidate list_processing in bounce and start functions
  ## track down permissions issue with .env, preventing script to run - DONE, was missing 'w' permission for group
  ## - figure out why sudo function isn't working

  # fnc_check_sudo_usage(){
  #   case "$(awk -F'=' '/^ID=/ { gsub("\"","",$2); print tolower($2) } ' /etc/*-release 2> /dev/null)" in
  #     ("qts"|"quts"|"debian")
  #       unset var_sudo IFS;
  #       case "$(id -un)" in
  #         ("admin"|"root")
  #           unset var_sudo IFS;
  #           ;;
  #         (*)
  #           var_sudo="/usr/bin/sudo ";
  #           ;;
  #       esac
  #       ;;
  #     (*)
  #       var_sudo="/usr/bin/sudo ";
  #       ;;
  #   esac
  #   }

  fnc_list_all_running(){ IFS=$'\n' bounce_list=("$(docker container list --format '{{.Names}}')"); }
  fnc_list_sort(){ deploy_list=( "$(for stack in "${deploy_list[@]}" ; do echo "$stack" ; done | sort -u)" ); }
  # fnc_subdirectories_list=( "$(IFS=$'\n'; cd "${docker_compose:?}" && find . -type d -not -path '*/\.*' | sed 's/^\.\///g')" )
  fnc_configs_folder_list(){ IFS=$'\n'; configs_folder_list=( "$(cd "${docker_compose:?}" && find . -maxdepth 1 -type d -not -path '*/\.*' | sed 's/^\.\///g')" ); }
  fnc_deploy_list_cleanup(){ # check that each folder has a .yml config file and clean up the array
    unset configs_list IFS;
    for i in "${!configs_folder_list[@]}"; do
      # remove '.' folder name from printed list
      if [[ "${configs_folder_list[i]}" = "." ]]; then unset "${configs_folder_list[i]}"; fi
      if [[ -f "${docker_compose:?}"/"${configs_folder_list[i]}"/"${var_configs_file:?}" ]]
      then configs_list="${configs_list} ${configs_folder_list[i]}"
      fi
    done
    unset deploy_list IFS;
    IFS=$'\n'; deploy_list=( "${configs_list[@]}" )
    }
  fnc_bounce_list(){ # populate list of stacks to be started
    # fnc_check_sudo_usage;
    if [[ "${bounce_list[*]}" = "" ]]; then
      # populate list of configuration folders
      fnc_configs_folder_list
      # check that each existing folder has a .yml config file inside
      fnc_deploy_list_cleanup
    else IFS=$'\n'; deploy_list=( "${bounce_list[@]}" )
    fi
    }
  fnc_start_containers(){ # perform script main function
    # fnc_check_sudo_usage;
    # IFS=$'\n'; deploy_list=( $(for stack in "${deploy_list[@]}" ; do echo "${stack}" ; done | sort -u) )
    fnc_list_sort "${deploy_list[@]}"
    for stack in "${deploy_list[@]}"; do
      # create '.env' file redirect if used
      # if [ ! -f "${docker_compose:?}/${deploy_list[stack]}/.env" ]; then ln -s "${var_script_vars:?}" "${docker_compose:?}/${deploy_list[stack]}/.env"; fi
      # [ ! -f "${docker_compose:?}/${deploy_list[stack]}/.env" ] && ln -sf "${var_script_vars:?}" "${docker_compose:?}/${deploy_list[stack]}/.env";
      # "${var_sudo}"
      if [ ! -f "${docker_compose:?}/${stack}/.env" ]; then ln -sf "${var_script_vars:?}" "${docker_compose:?}/${stack}/.env"; fi;
      docker compose -f "${docker_compose:?}/${stack}/${var_configs_file:?}" up -d --remove-orphans
      sleep 1
    done
    }

# option logic action determination
  case "${1}" in
    (-*) # validate entered option exists
      case "${1}" in
        ("-a"|"--all")
          unset "deploy_list[0]"
          fnc_bounce_list
          ;;
        (*)
          fnc_invalid_syntax
          ;;
      esac
      ;;
    (*)
      IFS=' ' deploy_list=("$@")
      ;;
  esac

# perform script main function
  fnc_start_containers
