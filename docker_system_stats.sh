#!/bin/bash
# external variable sources
  source /share/docker/scripts/.bash_colors.env

# function definitions
  fnc_help(){
    echo -e "${blu}[-> This script displays system resources used by current docker stacks/containers. <-]${def} "
    echo
    echo -e "  SYNTAX: # dls"
    echo -e "  SYNTAX: # dls -${cyn}option${def}"
    echo -e "    VALID OPTION(S):"
    echo -e "      ${CYN}-h${def} | ${CYN}-help${def} │ Displays this help message."
    echo -e "      ${CYN}-p${def} | ${CYN}-part${def} │ Displays a resource usage table for current docker services."
    echo
    exit 1 # Exit script after printing help
    }
  fnc_invalid_syntax(){ echo -e "${YLW} >> INVALID OPTION SYNTAX, USE THE -${cyn}help${YLW} OPTION TO DISPLAY PROPER SYNTAX <<${DEF}"; exit 1; }
  fnc_stats_full(){ docker stats --format "table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}  {{.MemPerc}}  {{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"; }
  fnc_stats_part(){ docker stats --format "table {{.Name}}\t{{.CPUPerc}}  {{.MemPerc}}\t{{.MemUsage}}\t{{.NetIO}}"; }

# determine script output according to option entered
  case "${1}" in 
    ("") fnc_stats_part ;; 
    (-*)
      case "${1}" in
        (""|"-h"|"-help"|"--help") fnc_help ;;
        ("-s"|"-short") fnc_stats_part ;; 
        (*) fnc_invalid_syntax ;;
      esac
      ;;
    (*) fnc_stats_full ;;
  esac
