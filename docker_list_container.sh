#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/.bash_colors.env

# Help message for script
helpFunction(){
  echo -e "${blu}[-> This script lists current '${CYN}stacknames${blu}' and the number of '${cyn}services${blu}' in that stack <-]${def} "
  echo -e "${blu} ->   It will also list services inside a '${CYN}stacknames${blu}' when passing one of the below options <-]${def} "
  echo
  echo -e "SYNTAX: # dls -${cyn}option${def}"
  echo -e "  VALID OPTION(S):"
  echo -e "    -h │ -help   Displays this help message."
  echo
  echo -e "SYNTAX: # dls ${cyn}stackname${def}"
  echo -e "SYNTAX: # dls ${cyn}stackname${def} -${cyn}option${def}"
  echo -e "  VALID OPTION(S):"
  echo -e "    -ps   Displays '${CYN}docker stack ps --no-trunc ${cyn}stackname${def}' output with non-truncated entries and select columns."
  echo -e "    -sv   Displays '${CYN}docker stack services ${cyn}stackname${def}' output with custom selected columns."
  echo
  exit 1 # Exit script after printing help
  }

# determine script output according to option entered
  case "${1}" in 
    "")
      echo -e "${blu}[-> LISTING CURRENT DOCKER SWARM STACKS <-]${DEF} "
      if [ ! "$(docker stack ls)" = "NAME                SERVICES" ]; then docker stack ls
      else echo -e "${YLW} -> no current docker stacks exist${DEF} ";
      fi
      echo
      ;;
    -*)
      case "${1}" in
        ""|"-h"|"-help"|"--help") helpFunction ;;
        *) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX${DEF} <<"; exit 1 ;;
      esac
      ;;
    *)
      case "${2}" in
        "-ps")
          docker stack ps --no-trunc --format "table {{.Node}}\t{{.ID}}\t{{.Name}}\t{{.CurrentState}}\t{{.Error}}\t{{.Ports}}" "${1}"
          ;;
        "-sv")
          docker stack services "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Replicas}}\t{{.Image}}\t{{.Ports}}"
          ;;
        "")
          if [[ ! "$(docker service ps "${1}" --format "{{.Error}}")" ]];
          then docker service ps "${1}" --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Ports}}"
          else docker service ps "${1}" --no-trunc --format "table {{.ID}}\t{{.Name}}\t{{.Node}}\t{{.CurrentState}}\t{{.Error}}"
          fi
        ;;
      esac
      ;;
  esac
