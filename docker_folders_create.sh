#!/bin/bash
# external variable sources
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/secrets/.docker_vars.env

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script creates Docker configuration folders using the schema created by ${CYN}Drauku${blu} <-]${DEF}"
    echo -e "    ${blu}(modified from ${CYN}gkoerk's (RIP)${blu} famously awesome folder structure for stacks)${DEF}"
    echo
    echo -e "  NOTE: stack_names must NOT contain spaces, but MUST be separated by a 'space' character: "
  }
  fnc_help_compose(){
    fnc_help
    echo -e "    SYNTAX: dcf ${cyn}stack_name1${DEF} ${cyn}stack_name2${DEF} etc etc"
    echo -e "    SYNTAX: dcf -${cyn}option${DEF}"
    echo -e "      VALID OPTIONS:"
    echo -e "        -${cyn}h${DEF} │ --${cyn}help${DEF}   Displays this help message."
    echo
    echo -e "    The below folder structure is created for each 'stack_name' entered with this command:"
    echo -e "        ${YLW}/share/docker/${ylw}compose${YLW}/appdata/${cyn}stack_name${DEF}"
    echo -e "        ${YLW}/share/docker/${ylw}compose${YLW}/configs/${cyn}stack_name${DEF}"
    echo
    exit 1 # Exit script after printing help
  }
  fnc_help_swarm(){
    fnc_help
    echo -e "    SYNTAX: dsf || dwf ${cyn}stack_name1${DEF} ${cyn}stack_name2${DEF} etc etc"
    echo -e "    SYNTAX: dsf || dwf -${cyn}option${DEF}"
    echo -e "      VALID OPTIONS:"
    echo -e "        -${cyn}h${DEF} │ --${cyn}help${DEF}   Displays this help message."
    echo
    echo -e "    The below folder structure is created for each 'stack_name' entered with this command:"
    echo -e "        ${YLW}/share/docker/${ylw}swarm${YLW}/appdata/${cyn}stack_name${DEF}"
    echo -e "        ${YLW}/share/docker/${ylw}swarm${YLW}/configs/${cyn}stack_name${DEF}"
    echo
    exit 1 # Exit script after printing help
  }
  fnc_script_intro(){ echo -e "${blu}[-> CREATE DOCKER FOLDER STRUCTURE FOR LISTED STACKS <-]${def}"; }
  fnc_script_outro(){ echo -e "${GRN} -> COMPOSE FOLDER STRUCTURE CREATED${DEF}"; echo; }
  fnc_nothing_to_do(){ echo -e "${YLW} -> a valid option followed by container names must be entered for this command to work${DEF}"; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_create_folders(){ 
    folder_list=("$@")
    # unset folder_list[0] # removes compose/swarm indicator from command input
    for stack in "${folder_list[@]}"; do
      if [ ! -d ${appdata_folder}/${folder_list[stack]} ]; then mkdir -p ${appdata_folder}/${folder_list[stack]}; fi
      if [ ! -d ${configs_folder}/${folder_list[stack]} ]; then mkdir -p ${configs_folder}/${folder_list[stack]}; fi
    done
  }

# output determination logic
  case "${1}" in 
    ("") fnc_nothing_to_do ;;
    ("-"*) # validate and perform option
      case "${1}" in
        ("-c"|"-compose"|"--compose") 
          echo "1='${1}', 2='${2}', all='${@}'"
          case "${2}" in
            ("-h"|"-help"|"--help") fnc_help_compose ;;
          esac
          appdata_folder=${compose_appdata}
          configs_folder=${compose_configs}
          fnc_create_folders
        ;;
        ("-w"|"-swarm"|"--swarm") 
          echo "1='${1}', 2='${2}', all='${@}'"
          case "${2}" in
            ("-h"|"-help"|"--help") fnc_help_swarm ;;
          esac
          appdata_folder=${swarm_appdata}
          configs_folder=${swarm_configs}
          fnc_create_folders
        ;;
        (*) fnc_invalid_syntax ;;
      esac
    ;;
  esac