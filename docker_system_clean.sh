#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/.bash_colors.env
  source /share/docker/scripts/.docker_vars.env

# determine script output according to option entered
  case "${1}" in 
    (-*)
      case "${1}" in
        # "-h"|"-help"|"--help") helpFunction ;;
        ("-a"|"-all")
          if [[ "$(docker container ls -a -q)" ]];
          then docker stop $(docker container ls -a -q) && docker system prune -a -f --volumes
          else echo -e " - ${YLW}no docker elements to stop and clean${DEF}"
          fi
          ;;
        (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1 ;;
      esac
      ;;
    (*) 
      if [[ ! "$(docker system prune --all --force --volumes)" == "Total reclaimed space: 0B" ]];
      then docker system prune --all --force --volumes;
      else echo -e " - ${YLW}nothing to clean from the docker environment${DEF}";
      fi
  esac
  echo