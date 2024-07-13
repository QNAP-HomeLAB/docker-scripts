#!/usr/bin/env bash

# $HOME\docker\common\docker_backup.sh

# USAGE: ./docker_backup.sh [-a <appname>] [-d <docker_path>] [-t <archive_target>] [-b <backup_path>] [-i <server_ip>] [-u <username>]
#    or: ./docker_backup.sh <appname>
# DESCRIPTION: This script will create an archive of the local docker folders and optionally copy it to a remote server.
# AUTHOR: Drauku

# NOTE: SET THESE VARIABLES IN ADVANCE IF YOU DO NOT WANT TO ANSWER THE PROMPTS
docker_path="$HOME/docker"
archive_target="" #"local"
backup_path="" #"$docker_path/backup"
server_ip="" #"192.168.1.150"
username="" #"admin"

# exit on any command failure
set -e

# Check for color support
if [ -t 1 ]; then colors_supported=true; else colors_supported=false; fi

colorize() { if [ "$colors_supported" = true ]; then printf "%b" "$1"; else printf "%b" "$2"; fi; }

msg_log() {
    local message="$1"
    local stream="${2:-1}"  # Default to stdout (1) if not specified
    printf "[%s] %s\n" "$(date +'%Y-%m-%d %H:%M:%S')" "$message" >&$stream
    }
msg_debug()   { if [ "$debug" = true ]; then msg_log "$(colorize '\033[0;35mDEBUG:\033[0m' 'DEBUG:') $1" 2; fi; } # color magenta
msg_verbose() { if [ "$verbose" = true ]; then msg_log "$(colorize '\033[0;36mINFO:\033[0m ' 'INFO: ') $1" 1; fi; } # color cyan
msg_failure() { msg_log "$(colorize '\033[0;31mFAILURE:\033[0m ' 'FAILURE: ') $1" 2; } # color red
msg_success() { msg_log "$(colorize '\033[0;32mSUCCESS:\033[0m ' 'SUCCESS: ') $1" 1; } # color green
msg_warning() { msg_log "$(colorize '\033[0;33mWARNING:\033[0m ' 'WARNING: ') $1" 2; } # color yellow
msg_alert()   { msg_log "$(colorize '\033[38;2;255;075;075mALERT:\033[0m' 'ALERT: ') $1" 2; } # color orange
msg_error()   { msg_log "$(colorize '\033[0;31mERROR:\033[0m ' 'ERROR: ') $1" 2; } # color red
msg_plain()   { msg_log "$1" 1; } # no color

# parse command line arguments using getopts
while getopts ":a:d:t:b:i:u:vD" opt; do
    case $opt in
        a) app_name="$OPTARG" ;;
        d) docker_path="$OPTARG" ;;
        t) archive_target="$OPTARG" ;;
        b) backup_path="$OPTARG" ;;
        i) server_ip="$OPTARG" ;;
        u) username="$OPTARG" ;;
        v) verbose=true ;;
        D) debug=true ;;
        \?) msg_failure ">>> Invalid option: -$OPTARG. Exiting script. <<<"; exit 1 ;;
        :) msg_failure ">>> Option -$OPTARG requires an argument. Exiting script. <<<"; exit 1 ;;
    esac
done

# shift the parsed options out of the positional parameters
shift $((OPTIND - 1))

# if no options were parsed, but a positional parameter was provided, use that as the app_name
if [ $OPTIND -eq 1 ] && [ -n "$1" ]; then app_name="$1"; fi

# export variables
export app_name docker_path archive_target backup_path server_ip username

# cleanup function to remove any partial archive files
cleanup() {
    msg_debug "Entering cleanup function..."
    # Remove any partial archive files
    msg_debug "Checking for partial backup files..."
    partial_files=("$backup_path"/*.partial)
    if [ ${#partial_files[@]} -gt 0 ] && [ -e "${partial_files[0]}" ]; then
        msg_debug "Found partial backup files. Removing..."
        msg_verbose "Removing partial backup files..."
        for file in "${partial_files[@]}"; do
            msg_debug "Removing file: $file"
            rm "$file"
        done
    fi
    msg_debug "Cleaning up complete. Exiting..."
    msg_log "Cleanup complete. Script finished. Exiting."
    exit 1
    }
# Set up the trap immediately after defining the cleanup function
trap cleanup SIGINT SIGTERM

# verify that app_name is provided
if [ -z "$app_name" ]; then
    msg_error "Application name is required."
    msg_alert "Usage:" "$0 [-a <appname>] [-d <docker_path>] [-t <archive_target>] [-b <backup_path>] [-i <server_ip>] [-u <username>] [-v] [-D]"
    msg_alert "   or:" "$0 <appname>"
    exit 1
fi

# validate docker_path
validate_path() {
    local path="$1"
    msg_debug "Validating docker_path: $path"
    if [ ! -d "$path" ]; then
        msg_error "Directory '$path' does not exist or is not accessible."
        return 1
    fi
    msg_debug "Docker path is valid."
    }

validate_ip() {
    local ip="$1"
    msg_debug "Validating IP address: $ip"
    if ! [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        msg_debug "IP address format is invalid."
        msg_error "Invalid IP address format."
        return 1
    fi
    IFS='.' read -r -a ip_parts <<< "$ip"
    for part in "${ip_parts[@]}"; do
        if [ "$part" -gt 255 ] || [ "$part" -lt 0 ]; then
            msg_debug "Part $part is not within the valid range of 0-255"
            msg_error "IP address parts must be between 0 and 255."
            return 1
        fi
    done
    msg_debug "IP address is valid."
}

query_docker_paths() { # Query for the docker config file paths
    if [ -z "$docker_path" ]; then
        msg_debug "Querying docker config file paths..."
        msg_plain "This script creates a docker folder archive and optionally copies the archive to a remote server."
        msg_plain "NOTE: This host must be set up to use SSH keys with the remote host."
        read -r -p "Enter the path to the docker config directory [~/.docker]: " docker_path
        docker_path=${docker_path:-~/docker}
        msg_debug "Using docker config directory: $docker_path"
    fi
    validate_path "$docker_path"
    export docker_path
    msg_debug "Docker config path valid."
    }

# query for the destination IP
query_backup_destination(){ # USAGE: query_backup_destination
    msg_debug "Entering query_backup_destination function..."
    if [ -z "$archive_target" ]; then
        msg_debug "Querying backup destination type..."
        read -r -p "Is your backup destination on the same host? [y]es / (n)o " target_answer
        case "$target_answer" in
            [nN][oO]|[nN])
                msg_debug "Remote backup destination selected."
                archive_target=remote
                msg_plain "Archive file transfer will use \`scp\`. Please provide the destination information:"
                read -r -p "Enter backup destination IP address [192.168.1.150]: " server_ip
                server_ip="${server_ip:-192.168.1.150}"
                msg_debug "Using backup destination IP: $server_ip"
                # Query for the destination username
                read -r -p "Enter backup destination username [admin]: " username
                username="${username:-admin}"
                msg_debug "Using backup destination username: $username"
                ;;
            [yY][eE][sS]|[yY])
                msg_debug "Local backup destination selected."
                archive_target=local
                read -r -p "Enter local backup destination path [$docker_path/backup]: " backup_path
                backup_path=${backup_path:-"$docker_path/backup"}
                msg_debug "Using local backup destination path: $backup_path"
                ;;
        esac
    elif [ "$archive_target" = "remote" ] && { [ -z "$server_ip" ] || [ -z "$username" ]; }; then
        msg_error "Remote target specified without server IP or username. Exiting script."
        msg_debug "Archive target: $archive_target"
        msg_debug "Server IP: $server_ip"
        msg_debug "Username: $username"
        exit 1
    elif [ "$archive_target" = "local" ] && [ -z "$backup_path" ]; then
        msg_error "Local target specified without backup path. Exiting script."
        msg_debug "Archive target: $archive_target"
        msg_debug "Backup path: $backup_path"
        exit 1
    fi
    msg_debug "Exiting query_backup_destination function."
    export archive_target server_ip username backup_path
    }

set_list_of_containers(){ # Set the list of containers to be stopped and backed up
    # Unset variable container_list
    container_list=()
    # Store the output of `docker container list` into `container_list`
    msg_debug "Querying for list of running containers..."
    IFS=$'\n' read -r -a container_list <<< "$(docker container list --format "{{.Names}}")"
    msg_debug "Found these running containers: \n  ${#container_list[@]}"
    # IFS=$'\n' read -r -d '' -a container_list < <(docker container list --format "{{.Names}}")
    # IFS=$'\n' container_list=( $(docker container list --format "{{.Names}}") )
    # mapfile -t container_list < <(docker container list --format "{{.Names}}")
    # container_list=(); while IFS= read -r line; do container_list+=("$line"); done < <(docker container list --format "{{.Names}}")
    # container_list=(); docker container list --format "{{.Names}}" | while IFS= read -r line; do container_list+=("$line"); done

    # Verify the listed containers should be stopped, exit script if not
    msg_plain "The below list of containers are currently running:\n ${container_list[*]}\n"
    while read -r -p "Would you like to stop the containers and create an archive for each? [y]es / (n)o " stop_answer; do
        case "$stop_answer" in
            [nN][oO] | [nN] )
                msg_plain ">>> No changes made to the docker environment. Exiting script. <<<"
                msg_debug "Exiting set_list_of_containers function."
                # break
                exit 0
            ;;
            [yY][eE][sS] | [yY] )
                msg_verbose ">>> Proceeding with backup operations. <<<"
                msg_debug "Exiting set_list_of_containers function."
            ;;
            * )
                msg_warning ">>> Invalid input. Please enter 'y' or 'n'. <<<"
                msg_debug "Invalid input. Retrying..."
                continue
            ;;
        esac
    done
    export container_list
    msg_debug "Exiting set_list_of_containers function."
    }

# stop or start container
manage_containers(){ # USAGE: manage_containers <stop|start> <container>
    local state="$1"
    local container="$2"

    msg_debug "Attempting to $state container $container"
    if ! docker "$state" "$container"; then
        msg_failure ">>> Failed to $state $container. Please $state $container manually. <<<"
        msg_debug "Error: $state $container failed with exit code $?"
        return 1
    fi
    msg_debug "Successfully $state container $container"
    }

    ## Stop the running containers
    # containers_stopped=()
    # for container in "${container_list[@]}"; do
    #     if docker inspect -f '{{.State.Running}}' "$container" &>/dev/null; then
    #         msg_log "Stopping container $container..."
    #         containers_stopped+=("$container")
    #         docker stop "$container" &>/dev/null
    #     fi
    # done
    # export containers_stopped

# create a tar archive from all docker config file directories
create_archive(){ # USAGE: create_archive
    containers_restarted=()
    containers_notstarted=()
    msg_debug "Entering create_archive function..."
    # stop all containers and create archive if successful
    for container in "${container_list[@]}"; do
        msg_debug "Attempting to stop container $container"
        if manage_containers stop $container; then
            msg_debug "Successfully stopped container $container"

            # set current backup date
            backup_date=$(date +'%F')

            # compress the files
            msg_debug "Attempting to create archive for container $container"
            if ! tar -czvf "$backup_path/docker-backup-$container-$backup_date.tar.gz" "$docker_path"; then
                msg_failure "Failed to create archive. Please verify adequate disk space. Restarting container."
            else
                msg_success "Successfully created archive."
            fi

            # attempt to restart stopped containers
            msg_debug "Attempting to start container $container"
            if manage_containers start $container; then
                msg_debug "Successfully started container $container"
                containers_restarted+=("$container")
            else
                msg_failure "Failed to start container $container. Please restart container manually."
                containers_notstarted+=("$container")
            fi
        else
            msg_failure "Failed to stop container $container. Please stop container manually."
            return 1
        fi
    done
    if [ ${#containers_notstarted[@]} -gt 0 ]; then
        msg_alert ">>> The following containers did not start:\n ${containers_notstarted[*]}"
    else
        msg_success "Successfully restarted all containers."
    fi
    msg_debug "Exiting create_archive function..."
    }

# copy the archive to a remote server
copy_archive_to_remote(){ # USAGE: copy_archive_to_remote
    msg_debug "Entering copy_archive_to_remote function..."
    local archive_path="$backup_path/docker-backup-$container-$backup_date.tar.gz"
    msg_debug "Checking for backup archive at $archive_path"
    if [ ! -f "$archive_path" ]; then
        msg_alert ">>> Backup archive not found. Skipping copy to remote server. <<<"
        return 1
    fi
    msg_debug "Copying archive $archive_path to $username@$server_ip:$backup_path"
    if scp "$archive_path" "$username"@"$server_ip":"$backup_path"; then
        # remove the local copy of the archive if the scp task completed successfully
        msg_success "Successfully copied archive to remote server."
        # rm "$archive_path"
        # msg_debug "Removed local copy of archive."
    else
        msg_failure "Failed to copy archive to remote server."
        msg_debug "Error: $?"
    fi
    msg_debug "Exiting copy_archive_to_remote function..."
    }

# script output logic

    # query for the docker config file paths
    query_docker_paths

    # Set the list of containers to be stopped and backed up
    set_list_of_containers

    # query for the destination IP
    query_backup_destination

    # create a tar archive from all docker config file directories
    create_archive

    # copy the archive to a remote server if desired
    [ "$archive_target" = "remote" ] && copy_archive_to_remote
