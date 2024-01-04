#!/bin/bash
# home\drauku\docker_backup.sh
# USAGE: docker_backup.sh
# DESCRIPTION: This script will create an archive of the local docker folders and copy it to a remote server.
# AUTHOR: Drauku

# SET THESE VARIABLES IN ADVANCE IF YOU DO NOT WANT TO ANSWER THE PROMPTS
archive_target="" #"local"
backup_path="" #"$docker_path/backup"
server_ip="" #"192.168.1.150"
username="" #"admin"

query_docker_paths(){ # Query for the docker config file paths
    echo -e "\nThis script creates a docker folder archive and optionally copies the archive to a remote server."
    echo -e "NOTE: This host must be set up to use SSH keys with the remote host.\n"
    read -r -p "Enter the path to the docker config directory [~/.docker]: " docker_path
    docker_path=${docker_path:-~/.docker}
    }

set_list_of_containers(){ # Set the list of containers to be stopped and backed up
    # Unset variable container_list
    unset container_list

    # Store the output of `docker container list` into `container_list`
    # TODO: determine which of these methods works best to populate `container_list`
    # IFS=$'\n' container_list=( $(docker container list --format "{{.Names}}") )
    IFS=$'\n' read -r -a container_list <<< "$(docker container list --format "{{.Names}}")"
    # mapfile -t container_list < <(docker container list --format "{{.Names}}")
    # container_list=(); while IFS= read -r line; do container_list+=("$line"); done < <(docker container list --format "{{.Names}}")
    # container_list=(); docker container list --format "{{.Names}}" | while IFS= read -r line; do container_list+=("$line"); done

    # Verify the listed containers should be stopped, exit script if not
    # echo -e "The below list of containers are currently running:"
    echo -e "\n ${container_list[*]}\n"
    while read -r -p "Would you like to stop the above list of currently running containers? [y]es / (n)o " stop_answer; do
        case "$stop_answer" in
            [nN][oO]|[nN])
                echo ">>> No changes made to the docker environment. Exiting script. <<</n"
                break
            ;;
            [yY][eE][sS]|[yY])
            ;;
        esac
    done
    }

# query for the destination IP
query_backup_destination(){ # USAGE: query_backup_destination
    read -r -p "Is your backup destination on the same host? [y]es / (n)o " target_answer
    case "$target_answer" in
        [nN][oO]|[nN])
            archive_target=remote
            read -r -p "Enter backup destination IP address [192.168.1.150]: " server_ip
            server_ip=${server_ip:-192.168.1.150}
            # Query for the destination username
            read -r -p "Enter backup destination username [admin]: " username
            username=${username:-admin}
            ;;
        [yY][eE][sS]|[yY])
            archive_target=local
            read -r -p "Enter backup destination path [$docker_path/backup]: " backup_path
            backup_path=${backup_path:-"$docker_path/backup"}
            ;;
    esac
    }

# stop or start all containers
manage_containers(){ # USAGE: manage_containers [stop|start]
    local state=$1
    for container in "${container_list[@]}"; do
        docker "$state" "$container"
    done
    }

# create a tar archive from all docker config file directories
archive_create(){ # USAGE: archive_create
    # stop all containers and create archive if successful
    if manage_containers stop; then
        # set current backup date
        backup_date=$(date +'%F')

        # compress the files
        # if ! tar -czvf "$backup_path/docker-backup-$backup_date.tar.gz" "$HOME/docker/common" "$HOME/docker/local" "$HOME/docker/swarm"; then
        if ! tar -czvf "$backup_path/docker-backup-$backup_date.tar.gz" "$docker_path"; then
            echo ">>> Failed to create archive. Please verify adequate disk space. Starting containers back up. <<<"
        fi

        # start all containers
        if manage_containers start; then
            echo ">>> Successfully restarted containers. <<<"
        else
            echo -e "\n>>> Failed to restart containers. Please restart containers manually. <<<\n"
            return 1
        fi
    else
        echo -e "\n>>> Failed to stop containers. Please stop containers manually. <<<\n"
        return 1
    fi
    }


# copy the archive to a remote server
archive_copy_to_server(){ # USAGE: archive_copy_to_server
    if scp "$backup_path/docker-backup-$backup_date.tar.gz" "$username"@"$server_ip":"$backup_path"; then
        # remove the local copy of the archive if the scp task completed successfully
        rm "$backup_path/docker-backup-$backup_date.tar.gz"
        echo ">>> Successfully copied archive to remote server. <<<"
    else
        echo -e ">>> Failed to copy archive to remote server. <<<\n"
    fi
    }

# script output logic

    # query for the docker config file paths
    [ -z "$docker_path" ] && query_docker_paths

    # Set the list of containers to be stopped and backed up
    set_list_of_containers

    # query for the destination IP
    [ -z "$archive_target" ] && query_backup_destination

    # create a tar archive from all docker config file directories
    archive_create

    # copy the archive to a remote server if desired
    [ -z "$archive_target" ] && archive_copy_to_server
