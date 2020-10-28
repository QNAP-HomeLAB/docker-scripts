#!/bin/bash
# external variable sources
  source /share/docker/scripts/.script_vars.conf

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script lists current '${cyn}stacknames${blu}' and the number of '${CYN}services${blu}' in that stack <-]${def} "
    echo -e "${blu}[->   It will also list services inside a '${cyn}stacknames${blu}' when passing one of the below options <-]${def} "
    echo -e " -"
    echo -e " - SYNTAX: # dlc ${cyn}-option${DEF}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn}-h │ -help             ${DEF}| Displays this help message."
    echo -e " -"
    echo -e " - SYNTAX: # dlc                    │ Displays '${CYN}docker container ls' formatted for easy readability.${DEF}"
    echo -e " -"
    echo -e " - SYNTAX: # dlc ${cyn}stackname${def}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn}-l │ -lbl │ --labels  ${DEF}│ Displays '${CYN}docker container ls${DEF}' output with only 'Names' and 'Labels' columns."
    echo -e " -     ${cyn}-n │ -net │ --network ${DEF}│ Displays '${CYN}docker container ls${DEF}' output with only 'Networks' and 'Ports' columns."
    echo -e " -     ${cyn}-v │ -vol │ --volumes ${DEF}│ Displays '${CYN}docker container ls${DEF}' output with only 'Volumes' and 'Mounts' columns."
    echo -e " -"
    echo -e " - SYNTAX: # dlc ${cyn}stackname${def} ${cyn}-option${DEF}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn}-l | --list     ${DEF}| Displays '${CYN}docker container list --no-trunc ${cyn}stackname${def}' output with non-truncated entries and select columns."
    echo -e " -     ${cyn}-s | --services ${DEF}| Displays '${CYN}docker container services ${cyn}stackname${def}' output with custom selected columns."
    echo
    exit 1 # Exit after printing help
    }
  fnc_script_intro(){ echo -e "${blu}[-> LIST OF CURRENT DOCKER CONTAINERS <-]${DEF} "; }
  fnc_script_error(){ echo -e "${blu}[-> LIST OF DOCKER CONTAINER ${red}ERRORS${blu} <-]${DEF} "; }
  fnc_nothing_to_do(){ echo -e "${YLW} -> no current docker containers exist${DEF}"; }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE '--${cyn}help${YLW}' OPTION TO DISPLAY PROPER SYNTAX${DEF} <<"; exit 1; }
  fnc_container_list(){ docker container list -a -q; }
  fnc_error_check(){ docker container list --no-trunc --format "{{.Error}}" "${1}"; }
  fnc_list_container_all(){ docker container list --format "table {{.ID}}  {{.Names}}\t{{.Status}}\t{{.RunningFor}}\t{{.Image}}\t{{.Command}}"; }
  fnc_list_container_net(){ docker container list --no-trunc --format "table {{.Names}}\t{{.Status}}\t{{.Networks}}\t{{.Ports}}"; }
  fnc_list_container_vol(){ docker container list --no-trunc --format "table {{.Names}}\t{{.Status}}\t{{.LocalVolumes}}\t{{.Mounts}}"; }
  fnc_list_container_lbl(){ docker container list --no-trunc --format "table {{.Names}}\t{{.Status}}\t{{.Labels}}"; }

# output determination logic
  case "${1}" in 
    ("") fnc_script_intro; if [ ! "$(fnc_container_list)" ]; then fnc_nothing_to_do; else fnc_list_container_all; fi ;;
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-l"|"-lbl"|"--labels") fnc_script_intro; fnc_list_container_lbl ;;
        ("-n"|"-net"|"--network") fnc_script_intro; fnc_list_container_net ;;
        ("-v"|"-vol"|"--volumes") fnc_script_intro; fnc_list_container_vol ;;
        (*) fnc_invalid_syntax ;;
      esac
      ;;
    (*)
      case "${2}" in
        ("") # if [ "$(fnc_error_check)" ]; then fnc_list_service_err ${1} ${2}; else fnc_list_service_all ${1} ${2}; fi
          if [ ! "$(fnc_error_check ${1} ${2})" ]; 
          then fnc_script_intro; fnc_list_service_all ${1} ${2}; 
          else fnc_script_error; fnc_list_service_err ${1} ${2}; 
          fi 
          ;;
        (-*)
          case "${2}" in
            ("-ls"|"--list") fnc_script_intro; fnc_list_container_err ${1} ${2} ;;
            ("-sv"|"-svcs"|"--services") fnc_script_intro; fnc_list_container_all ${1} ${2} ;;
            (*) fnc_invalid_syntax ;;
          esac
      esac
      ;;
  esac
  echo

# fnc_script_outro

# to list possible --format tags, type 'docker command --format='{{json .}}''

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
