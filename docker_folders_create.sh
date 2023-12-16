#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# script help text
  fnc_help_folders_create(){
    echo -e "${blu:?}[-> This script creates Docker configuration folders using the schema developed by ${cyn:?}Drauku${blu:?} <-]${def:?}"
    echo -e " - ${blu:?}(modified from ${cyn:?}gkoerk's (RIP)${blu:?} famously awesome folder structure for stacks)${def:?}"
    echo -e " -"
    echo -e " -NOTE: stack_names must NOT contain spaces, but MUST be separated by a 'space' character: "
    echo -e " -"
    echo -e " - SYNTAX: ${command_name} ${cyn:?}stack_name1${def:?} ${cyn:?}stack_name2${def:?} etc etc"
    echo -e " - SYNTAX: ${command_name} ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}-h │ --help ${def:?}| Displays this help message."
    echo -e " -"
    echo -e " - The below folder structure and files are created for each 'stack_name' entered with this command:"
    echo -e " -     ${ylw:?}${docker_appdata}/${cyn:?}stack_name${mgn:?}/stack_name-logs.yml${def:?}"
    echo -e " -     ${ylw:?}${docker_compose}/${cyn:?}stack_name${mgn}/${var_configs_file}${def:?}"
    echo
    exit 1 # Exit script after printing help
  }
  # case "$1" in ("-h"|*"help"*) fnc_help_folders_create ;; esac # disabled because this script handles both compose and swarm folder creation

## function definitions
  fnc_intro_folders_create(){ echo -e "${blu:?}[-> CREATE DOCKER FOLDER STRUCTURE FOR LISTED STACKS <-]${def:?}"; }
  fnc_outro_folders_create(){ echo -e "${grn:?} -> DOCKER CONFIGS FOLDER STRUCTURE AND FILES CREATED${def:?}"; echo; }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE -${cyn:?}help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  fnc_nothing_to_do(){ echo -e "${ylw:?} -> This command requires a valid option followed by container name(s). Use ${cyn:?}-help${ylw:?} do display options. ${def:?}"; }
  fnc_create_folders(){
    echo; exist=0;
    folder_list=("$@")
    for stack in "${folder_list[@]}"; do
      if [ ! -d "${appdata_folder}/${stack}" ];
        then install -o "${var_uid}" -g "${var_gid}" -m 664 -d "${appdata_folder}/${stack}";
        else echo -e "  > ${cyn:?}${appdata_folder}${cyn:?}/${stack}   ${ylw:?}ALREADY EXISTS ${def:?}"; exist=1;
      fi;
      if [ ! -d "${configs_folder}/${stack}" ];
        then install -o "${var_uid}" -g "${var_gid}" -m 664 -d "${configs_folder}/${stack}";
        else echo -e "  > ${cyn:?}${configs_folder}${cyn:?}/${stack}   ${ylw:?}ALREADY EXISTS ${def:?}"; exist=1;
      fi;
      [ "${exist}" == "0" ] && echo -e "  > ${cyn:?}${stack} ${ylw:?}COMPOSE FOLDER SET ${grn:?}CREATED ${def:?}";
    done
    }
  fnc_create_files(){
    echo; exist=0;
    folder_list=("$@")
    for stack in "${folder_list[@]}"; do
      if [ ! -f "${appdata_folder}/${stack}/${stack}-logs.yml" ];
        then install -o "${var_uid}" -g "${var_gid}" -m 660 /dev/null "${appdata_folder}/${stack}/${stack}-logs.yml";
        else echo -e "  > ${cyn:?}${appdata_folder}${cyn:?}/${stack}   ${ylw:?}ALREADY EXISTS ${def:?}"; exist=1;
      fi;
      if [ ! -f "${configs_folder}/${stack}/${var_configs_file}" ];
        then install -o "${var_uid}" -g "${var_gid}" -m 664 "${var_template_yaml}" "${configs_folder}/${stack}/${var_configs_file}";
        else echo -e "${ylw:?}  > ${cyn:?}${appdata_folder}/${cyn:?}${stack}/${var_configs_file} ${ylw:?}ALREADY EXISTS ${def:?}"; exist=1;
      fi;
      if [ ! -f "${configs_folder}/${stack}/.env" ];
        then ln -sf "${var_script_vars}" "${configs_folder}/${stack}/.env"
      fi;
      [ "${exist}" == "0" ] && echo -e "  > ${cyn:?}${stack} ${ylw:?}COMPOSE FOLDER SET ${grn:?}CREATED ${def:?}";
    done
    }

# output determination logic
  case "${1}" in
    ("")
      fnc_nothing_to_do
      ;;
    ("-"*) # validate and perform option
      case "${1}" in
        ("-c"|"-compose"|"--compose")
          echo "1='${1}', 2='${2}', all='${*}'"
          case "${2}" in
            ("-h"|*"-help"*)
              command_name="dcf"
              fnc_help_folders_create
              ;;
          esac
          appdata_folder="${docker_appdata}";
          configs_folder="${docker_compose}";
          fnc_create_folders "${*}";
          fnc_create_files "${*}";
          ;;
        ("-w"|"-swarm"|"--swarm")
          echo "1='${1}', 2='${2}', all='${*}'"
          case "${2}" in
            ("-h"|*"-help"*)
              command_name="dsf || dwf"
              fnc_help_folders_create
              ;;
          esac
          appdata_folder="${docker_appdata}";
          configs_folder="${docker_swarm}";
          fnc_create_folders "${*}";
          fnc_create_files "${*}";
          ;;
        (*)
          fnc_invalid_syntax
          ;;
      esac
      ;;
  esac

# fnc_outro_folders_create