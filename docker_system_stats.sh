#!/bin/bash
# external variable sources
  source /opt/docker/scripts/.color_codes.conf
  source /opt/docker/scripts/.vars_docker.env

# function definitions
  fnc_help(){
    echo -e "${blu:?}[-> This script displays system resources used by current docker stacks/containers. <-]${def:?} "
    echo -e " -"
    echo -e " - SYNTAX: # dls"
    echo -e " - SYNTAX: # dls ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn:?}-l | --live ${def:?}│ Displays a live-updating resource usage table for current docker services."
    echo -e " -     ${cyn:?}-p | --part ${def:?}│ Displays a resource usage table for current docker services."
    echo -e " -     ${cyn:?}-h | --help ${def:?}│ Displays this help message."
    echo
    exit 1 # Exit script after printing help
    }
  fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE -${cyn:?}help${ylw:?} OPTION TO DISPLAY PROPER SYNTAX <<${def:?}"; exit 1; }
  fnc_stats_full(){ docker stats --format "table {{.Container}}\t{{.Name}}\t{{.CPUPerc}}  {{.MemPerc}}  {{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"; }
  fnc_stats_part(){ docker stats --format "table {{.Name}}\t{{.CPUPerc}}  {{.MemPerc}}\t{{.MemUsage}}\t{{.NetIO}}"; }

# determine script output according to option entered
  case "${1}" in
    ("") fnc_stats_part ;;
    (-*)
      case "${1}" in
        ("-h"|"-help"|"--help") fnc_help ;;
        ("-l"|"--live") fnc_stats_full ;;
        ("-p"|"--part") fnc_stats_part ;;
        (*) fnc_invalid_syntax ;;
      esac
      ;;
    (*) fnc_stats_full ;;
  esac
