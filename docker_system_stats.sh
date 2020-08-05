#!/bin/bash
# Load config variables from file
  source /share/docker/scripts/.bash_colors.env

# Help message for script
helpFunction(){
  echo -e "${blu}[-> This script displays system resources used by current docker stacks/containers. <-]${def} "
  echo
  echo -e "  SYNTAX: # dls -${cyn}option${def}"
  echo -e "    VALID OPTION(S):"
  echo -e "      ${CYN}-h${def} | ${CYN}-help${def} │ Displays this help message."
  echo
  exit 1 # Exit script after printing help
  }

# determine script output according to option entered
  case "${1}" in 
    ("") docker stats --format "table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}  {{.MemPerc}}  {{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}" ;;
    (-*)
      case "${1}" in
        (""|"-h"|"-help"|"--help") helpFunction ;;
        (*) echo -e "${YLW} >> INVALID OPTION SYNTAX -- USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX${DEF} <<"; exit 1 ;;
      esac
      ;;
    (*) docker stats --format "table {{.Name}}\t{{.CPUPerc}}  {{.MemPerc}}\t{{.MemUsage}}\t{{.NetIO}}" ;;
  esac
