#!/bin/bash

# external variable sources
    source /opt/docker/scripts/.color_codes.conf
    source /opt/docker/scripts/.vars_docker.env

# function definitions
fnc_script_intro(){ echo -e "${blu:?}[-> LISTING CURRENT DOCKER NETWORKS <-]${def:?}";}
fnc_script_outro(){ echo; exit 1; }
fnc_help_system_clean(){
    echo -e "${blu:?}[-> This script allows the user to manage docker ${cyn:?}networks${def:?} <-]${def:?} "
    echo -e " -"
    echo -e " - SYNTAX: # dyn"
    echo -e " - SYNTAX: # dyn ${cyn:?}-option${def:?}"
    echo -e " -   VALID OPTION(S):"
    echo -e " -     ${cyn:?}-h │ --help ${def:?}│ Displays this help message"
    fnc_script_outro
    }
fnc_invalid_syntax(){ echo -e "${ylw:?} >> INVALID OPTION SYNTAX, USE THE '${cyn:?}--help${ylw:?}' OPTION TO DISPLAY PROPER SYNTAX${def:?} <<" && fnc_script_outro; }
fnc_network_list(){ docker network ls; }
fnc_network_check(){ docker network ls -q --filter name="$1"; }
fnc_network_swarm_verify(){
    unset increment IFS;
    while [[ ! "$(fnc_network_check "${var_net_socket}")" ]] || [[ ! "$(fnc_network_check "${var_net_rproxy}")" ]] || [[ ! "$(fnc_network_check "docker_gwbridge")" ]];
        do sleep 1;
        increment=$((increment+1));
        if [[ $increment -gt 10 ]];
        then fnc_swarm_error;
        fi;
    done;
    }
fnc_network_create(){
    # if [ "${scope}" = "swarm" ] && [[ ! "$(fnc_network_check "ingress")" = "" ]]; then docker network rm ingress; fi;
    # if [ "${scope}" = "swarm" ]; then docker network create --ingress --driver "${driver}" --opt encrypted --subnet "10.0.0.0/16" --gateway "10.0.0.254" ingress; fi;
    # if [ "${scope}" = "local" ] && [[ ! "$(fnc_network_check "docker_gwbridge")" = "" ]]; then docker network rm "docker_gwbridge"; fi;
    case "${scope}" in
        "local")
            if [[ ! "$(fnc_network_check "docker_gwbridge")" = "" ]]; then docker network rm "docker_gwbridge"; fi;
            ;;
        "swarm")
            if [[ ! "$(fnc_network_check "ingress")" = "" ]]; then docker network rm ingress; fi;
            # docker network create --ingress --driver overlay --opt encrypted --subnet "10.27.0.0/16" --gateway "10.27.0.254" "ingress";
            docker network create --ingress --driver overlay --opt encrypted --subnet "${var_subnet_ingress}" --gateway "${var_gateway_ingress}" "${var_net_ingress}";
            ;;
        *)
            echo -e "${ylw:?} >> ERROR: ${red:?}INVALID NETWORK SCOPE${ylw:?} Please notify the script author <<${def:?}" && fnc_script_outro;
            ;;
    esac
    docker network create --scope "${scope}" --driver "${driver}" --opt encrypted --subnet "${var_subnet_exedge}" --gateway "${var_gateway_exedge}" --attachable "${var_net_exedge}";
    docker network create --scope "${scope}" --driver "${driver}" --opt encrypted --subnet "${var_subnet_rproxy}" --gateway "${var_gateway_rproxy}" --attachable "${var_net_rproxy}";
    docker network create --scope "${scope}" --driver "${driver}" --opt encrypted --subnet "${var_subnet_socket}" --gateway "${var_gateway_socket}" --attachable "${var_net_socket}";
    unset "${scope}";
    unset "${driver}";
    echo -e "\n>> DOCKER NETWORK(s) ${grn:?}CREATED${def:?} <<" && fnc_script_outro;
    }
fnc_network_remove(){
    docker network rm "${*}";
    }

# output determination logic
    case "${1}" in
        (""|"-l"|"--list")
            fnc_script_intro;
            fnc_network_list;
            fnc_script_outro;
            ;;
        (-*)
            case "${1}" in
                ("-h"|"-help"|"--help")
                    fnc_help_system_clean;
                    ;;
                ("-c"|"--compose")
                    driver="bridge"
                    scope="local"
                    fnc_network_create;
                    ;;
                ("-d"|"-r"|"--delete"|"--remove")
                    fnc_network_remove "${1}";
                    ;;
                ("-w"|"-s"|"--swarm")
                    driver="overlay"
                    scope="swarm"
                    fnc_network_create;
                    ;;
                (*)
                    fnc_invalid_syntax;
                    ;;
            esac
            ;;
        (*)
            fnc_invalid_syntax;
            ;;
    esac