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
    echo -e "SYNTAX: # dls              │ Displays '${CYN}docker container ls' formatted for easy readability.${DEF}"
    echo
    echo -e "SYNTAX: # dls ${cyn}stackname${def}"
    echo -e "  VALID OPTION(S):"
    echo -e "    -n │ --net │ --network │ Displays '${CYN}docker container ls${DEF}' output with networking specific columns."
    echo -e "    -v │ --vol │ --volumes │ Displays '${CYN}docker container ls${DEF}' output with volume/mount specific columns."
    echo
    echo -e "SYNTAX: # dls ${cyn}stackname${def} -${cyn}option${def}"
    echo -e "  VALID OPTION(S):"
    echo -e "    -ls   Displays '${CYN}docker container list --no-trunc ${cyn}stackname${def}' output with non-truncated entries and select columns."
    echo -e "    -sv   Displays '${CYN}docker container services ${cyn}stackname${def}' output with custom selected columns."
    echo
    exit 1 # Exit after printing help
    }
  fnc_script_intro(){ echo -e "${blu}[-> LIST OF CURRENT DOCKER CONTAINERS <-]${DEF} "; }
  fnc_script_error(){ echo -e "${blu}[-> LIST OF DOCKER CONTAINER ${red}ERRORS${blu} <-]${DEF} "; }
  fnc_nothing_to_do(){ echo -e "${YLW} -> no current docker containers exist${DEF}"; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE '--${cyn}help${YLW}' OPTION TO DISPLAY PROPER SYNTAX${DEF} <<"; exit 1; }
  # to list possible --format tags, type: docker command --format='{{json .}}'
  fnc_container_list(){ docker container list -a -q; }
  fnc_list_container_all(){ docker container list --format "table {{.ID}} ~ {{.Names}}\t{{.Status}}\t{{.RunningFor}}\t{{.Image}}\t{{.Command}}"; }
  fnc_list_container_net(){ docker container list --format "table {{.ID}} ~ {{.Names}}\t{{.Status}}\t{{.Networks}}\t{{.Ports}}"; }
  fnc_list_container_vol(){ docker container list --format "table {{.ID}} ~ {{.Names}}\t{{.Status}}\t{{.LocalVolumes}}\t{{.Mounts}}"; }

# output determination logic
  case "${1}" in 
    ("") fnc_script_intro; if [ ! "$(fnc_container_list)" ]; then fnc_nothing_to_do; else fnc_list_container_all; fi ;;
    (-*)
      case "${1}" in
        (""|"-h"|"-help"|"--help") fnc_help ;;
        ("-n"|"--net"|"--network") fnc_script_intro; fnc_list_container_net ;;
        ("-v"|"--vol"|"--volumes") fnc_script_intro; fnc_list_container_vol ;;
        (*) fnc_invalid_syntax ;;
      esac
      ;;
    (*)
      case "${2}" in
        ("") # if [ "$(fnc_check_errors)" ]; then fnc_list_service_err ${1} ${2}; else fnc_list_service_all ${1} ${2}; fi
          if [ ! "$(fnc_check_errors ${1} ${2})" ]; 
          then fnc_script_intro; fnc_list_service_all ${1} ${2}; 
          else fnc_script_error; fnc_list_service_err ${1} ${2}; 
          fi 
          ;;
        (-*)
          case "${2}" in
            ("-ls"|"-list") fnc_script_intro; fnc_list_container_err ${1} ${2} ;;
            ("-sv"|"-svcs") fnc_script_intro; fnc_list_container_all ${1} ${2} ;;
            (*) fnc_invalid_syntax ;;
          esac
      esac
      ;;
  esac
  echo
