#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-> This script creates ${cyn:?}Drauku's${blu:?} folder structure for the listed stack(s). <-]${def:?}"
    echo -e " -    ${blu:?}(modified from ${cyn:?}gkoerk's${blu:?} famously awesome folder structure for stacks.)${def:?}"
    echo -e " -"
    echo -e " - Enter up to nine(9) swarm_stacks in a single command, separated by a 'space' character: "
    echo -e " -   SYNTAX: dsf ${cyn:?}swarm_stack1${def:?} ${cyn:?}swarm_stack2${def:?} ... ${cyn:?}swarm_stack9${def:?}"
    echo -e " -   SYNTAX: dsf ${cyn:?}-option${def:?}"
    echo -e " -     VALID OPTIONS:"
    # echo -e " -       ${cyn:?}-d │ --delete ${def:?}│ ${red:?}Deletes${def:?} all sub-folders and files in ${ylw:?}${docker_appdata}/${cyn:?}swarm_stack${def:?} & ${ylw:?}${docker_swarm}/${cyn:?}swarm_stack${def:?}"
    # echo -e " -       ${cyn:?}-r │ --reset  ${def:?}│ ${red:?}Deletes${def:?} all files contained in ${ylw:?}${docker_appdata}/${cyn:?}swarm_stack${def:?}"
    echo -e " -       ${cyn:?}-h │ --help   ${def:?}│ Displays this help message."
    echo -e " -"
    echo -e " -   NOTE: The below folder structure is created for each 'swarm_stack' entered with this command:"
    echo -e " -       ${ylw:?}${docker_appdata}/${cyn:?}swarm_stack${def:?}"
    echo -e " -       ${ylw:?}${docker_swarm}/${cyn:?}swarm_stack${def:?}"
    # echo -e " -       ${ylw:?}${swarm_runtime}/${cyn:?}swarm_stack${def:?}"
    # echo -e " -       ${ylw:?}/share/swarm/secrets/${cyn:?}swarm_stack${def:?}"
    echo
    exit 1 # Exit script after printing help
    }
  fnc_script_intro(){ echo -e "${blu:?}[-> CREATE DOCKER SWARM FOLDER STRUCTURE FOR LISTED STACKS <-]${def:?}"; }
  fnc_script_outro(){ echo -e "${grn:?} -> FOLDER STRUCTURE CREATED${def:?} FOR LISTED CONTAINERS: "; echo -e " -> ${cyn:?}$1, $2, $3, $4, $5, $6, $7, $8, $9 ${def:?}"; echo; }
  fnc_nothing_to_do(){ echo -e "${ylw:?} -> between 1 and 9 names must be entered for this command to work${def:?}"; exit 1; }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE -${cyn:?}help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  fnc_folder_ownership_msg(){ echo -e " -> ${grn:?}FOLDER OWNERSHIP UPDATED ${def:?}"; echo; }
  fnc_folder_ownership_update(){ chown -R ${var_uid}:${var_gid} ${swarm_folder}; chmod 600 -c {$docker_appdata,$docker_swarm}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}; }
  fnc_docker_appdata_folders(){ mkdir -p ${docker_appdata}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}; }
  fnc_docker_swarm_folders(){ mkdir -p ${docker_swarm}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}; }
  fnc_swarm_runtime_folders(){ mkdir -p ${swarm_runtime}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}; }
  fnc_swarm_secrets_folders(){ mkdir -p ${swarm_secrets}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}; }
  fnc_swarm_folders_create(){ mkdir -p {$docker_appdata,$docker_swarm}/{$1,$2,$3,$4,$5,$6,$7,$8,$9}; }
  fnc_swarm_delete_folders(){ rmdir {$docker_appdataa,$docker_swarm}/{$2,$3,$4,$5,$6,$7,$8,$9}; }
  fnc_swarm_delete_appdata(){
    rm -i ${docker_appdata}/{$2,$3,$4,$5,$6,$7,$8,$9};
    while read -r -p " - Also delete the ${ylw:?}${docker_appdata}/${cyn:?}swarm_stack${def:?} folder? [(Y)es/(N)o] " input; do
      case "${input}" in
        ([yY]|[yY][eE][sS]) fnc_swarm_delete_folders $2 $3 $4 $5 $6 $7 $8 $9 ;;
        ([nN]|[nN][oO]) break ;;
        (*) fnc_invalid_input ;;
      esac
    done;
    }
  fnc_swarm_delete_configs(){
    rm -i {$docker_appdata,$docker_swarm}/{$2,$3,$4,$5,$6,$7,$8,$9};
    while read -r -p " - Also delete the ${ylw:?}${docker_swarm}/${cyn:?}swarm_stack${def:?} folder? [(Y)es/(N)o] " input; do
      case "${input}" in
        ([yY]|[yY][eE][sS]) fnc_swarm_delete_folders $2 $3 $4 $5 $6 $7 $8 $9 ;;
        ([nN]|[nN][oO]) break ;;
        (*) fnc_invalid_input ;;
      esac
    done;
    }

# output determination logic
  case "${1}" in
    ("") fnc_nothing_to_do ;;
    (-*) # validate and perform option
      case "${1}" in
        ("-h"|"-help"|"--help")
          fnc_help ;;
        ("-d"|"-del"|"--delete")
          fnc_swarm_delete_configs $2 $3 $4 $5 $6 $7 $8 $9 ;;
        ("-r"|"-res"|"--reset")
          fnc_swarm_delete_appdata $2 $3 $4 $5 $6 $7 $8 $9 ;;
        (*)
          fnc_invalid_syntax ;;
      esac
      ;;
    (*)
      case "${2}" in
        (-*)
          # tmpvar="${2}"; 2="${1}"; 1="${tmpvar}"; unset tmpvar IFS;
          tmp2="${2}"; set -- "${1}"; set -- "${tmp2}"; unset tmp2 IFS;
          case "${1}" in
            ("-h"|"-help"|"--help")
              fnc_help ;;
            ("-d"|"-del"|"--delete")
              fnc_swarm_delete_configs $2 $3 $4 $5 $6 $7 $8 $9 ;;
            ("-r"|"-res"|"--reset")
              fnc_swarm_delete_appdata $2 $3 $4 $5 $6 $7 $8 $9 ;;
            (*)
              fnc_invalid_syntax ;;
          esac
      fnc_swarm_folders_create $1 $2 $3 $4 $5 $6 $7 $8 $9
      # Create folder structure
      # fnc_swarm_appdata_folders $1 $2 $3 $4 $5 $6 $7 $8 $9
      # fnc_swarm_configs_folders $1 $2 $3 $4 $5 $6 $7 $8 $9
      # fnc_swarm_runtime_folders $1 $2 $3 $4 $5 $6 $7 $8 $9 # disabled due to not being used
      # fnc_swarm_secrets_folders $1 $2 $3 $4 $5 $6 $7 $8 $9 # disabled due to not being used
      # fnc_folder_ownership_update $1 $2 $3 $4 $5 $6 $7 $8 $9
      # fnc_folder_ownership_msg
      # fnc_script_outro
      esac
      ;;
  esac
