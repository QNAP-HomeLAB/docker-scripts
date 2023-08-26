#!/bin/bash
# external variable sources
# shellcheck source=./.scripts_vars.conf
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.conf

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-> This script creates Docker configuration folders using the schema developed by ${CYN:?}Drauku${blu:?} <-]${def:?}"
    echo -e " - ${blu:?}(modified from ${CYN:?}gkoerk's (RIP)${blu:?} famously awesome folder structure for stacks)${def:?}"
    echo -e " -"
    echo -e " -NOTE: stack_names must NOT contain spaces, but MUST be separated by a 'space' character: "
    echo -e " -"
  }
  fnc_help_compose(){
    fnc_help
    echo -e " - SYNTAX: dcf ${cyn:?}stack_name1${def:?} ${cyn:?}stack_name2${def:?} etc etc"
    echo -e " - SYNTAX: dcf ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}-h │ --help ${def:?}| Displays this help message."
    echo -e " -"
    echo -e " - The below folder structure is created for each 'stack_name' entered with this command:"
    echo -e " -     ${YLW:?}/share/docker/${ylw:?}appdata/${cyn:?}stack_name${def:?}"
    echo -e " -     ${YLW:?}/share/docker/${ylw:?}compose/${cyn:?}stack_name${def:?}"
    echo
    exit 1 # Exit script after printing help
  }
  fnc_help_swarm(){
    fnc_help
    echo -e " - SYNTAX: dsf || dwf ${cyn:?}stack_name1${def:?} ${cyn:?}stack_name2${def:?} etc etc"
    echo -e " - SYNTAX: dsf || dwf ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTIONS:"
    echo -e " -     ${cyn:?}-h │ --help ${def:?}| Displays this help message."
    echo -e " -"
    echo -e " - The below folder structure is created for each 'stack_name' entered with this command:"
    echo -e " -     ${YLW:?}/share/docker/${ylw:?}appdata/${cyn:?}stack_name${def:?}"
    echo -e " -     ${YLW:?}/share/docker/${ylw:?}swarm/${cyn:?}stack_name${def:?}"
    echo
    exit 1 # Exit script after printing help
  }
  fnc_script_intro(){ echo -e "${blu:?}[-> CREATE DOCKER FOLDER STRUCTURE FOR LISTED STACKS <-]${def:?}"; }
  fnc_script_outro(){ echo -e "${GRN:?} -> COMPOSE FOLDER STRUCTURE CREATED${def:?}"; echo; }
  fnc_nothing_to_do(){ echo -e "${YLW:?} -> This command requires a valid option followed by container name(s). Use ${cyn:?}-help${YLW:?} do display options. ${def:?}"; }
  fnc_invalid_syntax(){ echo -e "${YLW:?} >> INVALID OPTION SYNTAX, USE THE -${cyn:?}help${YLW:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  # fnc_create_folders(){
  #   folder_list=("$@")
  #   # unset folder_list[0] # removes compose/swarm indicator from command input
  #   for stack in "${!folder_list[@]}"; do
  #     if [ ! -d "${appdata_folder}/${folder_list[stack]}" ]; then mkdir -p "${appdata_folder}/${folder_list[stack]}"; fi
  #     if [ ! -d "${configs_folder}/${folder_list[stack]}" ]; then mkdir -p "${configs_folder}/${folder_list[stack]}"; fi
  #   done
  #   }
  fnc_create_folders(){
    echo; exist=0;
    folder_list=("$@")
    for stack in "${folder_list[@]}"; do
      if [ ! -d "${appdata_folder}/${stack}" ];
        then install -o "${var_uid}" -g "${var_gid}" -m 664 -d "${appdata_folder}/${stack}";
        else echo -e "  > ${CYN:?}${appdata_folder}${cyn:?}/${stack}   ${ylw:?}ALREADY EXISTS ${def:?}"; exist=1;
      fi;
      if [ ! -d "${configs_folder}/${stack}" ];
        then install -o "${var_uid}" -g "${var_gid}" -m 664 -d "${configs_folder}/${stack}";
        else echo -e "  > ${CYN:?}${configs_folder}${cyn:?}/${stack}   ${ylw:?}ALREADY EXISTS ${def:?}"; exist=1;
      fi;
      [ "${exist}" == "0" ] && echo -e "  > ${cyn:?}${stack} ${YLW:?}COMPOSE FOLDER SET ${grn:?}CREATED ${def:?}";
    done
    }
  fnc_create_files(){
    echo; exist=0;
    folder_list=("$@")
    for stack in "${folder_list[@]}"; do
      if [ ! -f "${appdata_folder}/${stack}/${stack}-logs.yml" ];
        then install -o "${var_uid}" -g "${var_gid}" -m 660 /dev/null "${appdata_folder}/${stack}/${stack}-logs.yml";
        else echo -e "  > ${CYN:?}${appdata_folder}${cyn:?}/${stack}   ${ylw:?}ALREADY EXISTS ${def:?}"; exist=1;
      fi;
      if [ ! -f "${configs_folder}/${stack}/${stack}${configs_file}.yml" ];
        then install -o "${var_uid}" -g "${var_gid}" -m 664 "${var_template_yaml}" "${configs_folder}/${stack}/${stack}${configs_file}.yml";
        else echo -e "${ylw:?}  > ${CYN:?}${appdata_folder}/${cyn:?}${stack}/${stack}${configs_file}.yml ${ylw:?}ALREADY EXISTS ${def:?}"; exist=1;
      fi;
      if [ ! -f "${configs_folder}/${stack}/.env" ];
        then ln -sf "${var_script_vars}" "${configs_folder}/${stack}/.env"
      fi;
      [ "${exist}" == "0" ] && echo -e "  > ${cyn:?}${stack} ${YLW:?}COMPOSE FOLDER SET ${grn:?}CREATED ${def:?}";
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
            ("-h"|"-help"|"--help")
            fnc_help_compose
            ;;
          esac
          appdata_folder="${docker_appdata}";
          configs_folder="${docker_compose}";
          configs_file="${-compose}";
          fnc_create_folders "${*}";
          fnc_create_files "${*}";
          ;;
        ("-w"|"-swarm"|"--swarm")
          echo "1='${1}', 2='${2}', all='${*}'"
          case "${2}" in
            ("-h"|"-help"|"--help")
              fnc_help_swarm
              ;;
          esac
          appdata_folder="${docker_appdata}";
          configs_folder="${docker_swarm}";
          configs_file="${-stack}";
          fnc_create_folders "${*}";
          fnc_create_files "${*}";
          ;;
        (*)
          fnc_invalid_syntax
          ;;
      esac
      ;;
  esac