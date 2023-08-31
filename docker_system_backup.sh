#!/bin/bash

# Unset variable container_list
unset container_list

# Unset variable backupDate and set IFS to newline
backupDate=$(date +'%F')

# Store the output of `docker container list` into `container_list`
IFS=$'\n' container_list=( $(docker container list --format "{{.Names}}") )
# IFS=$'\n' read -r -a container_list <<< "$(docker container list --format "{{.Names}}")"
# mapfile -t container_list < <(docker container list --format "{{.Names}}")
# container_list=(); while IFS= read -r line; do container_list+=("$line"); done < <(docker container list --format "{{.Names}}")
# container_list=(); docker container list --format "{{.Names}}" | while IFS= read -r line; do container_list+=("$line"); done

# Verify the listed containers should be stopped, exit script if not
# echo -e "The below list of containers are currently running:"
echo -e "\n ${container_list[*]}\n"
while read -r -p "Would you like to stop the above list of currently running containers? [Y/n] " response; do
    case "$response" in
        [nN][oO]|[nN])
            exit 1
        ;;
        [yY][eE][sS]|[yY])
        ;;
    esac
done

# # Query for the destination IP
# read -r -p "Enter backup destination IP address [192.168.186.150]: " server_ip
# server_ip=${server_ip:-192.168.186.150}

# # Query for the destination username
# read -r -p "Enter backup destination username [admin]: " username
# username=${username:-admin}

# Stop all containers
for container in "${container_list[@]}"; do
    docker stop "${container}"
done

# Create a tar archive from all docker config file directories
tar -czvf "$HOME/docker/backups/docker-backup-$backupDate.tar.gz" "$HOME/docker/appdata" "$HOME/docker/compose" "$HOME/docker/swarm"

# Start all containers
for container in "${container_list[@]}"; do
    docker start "${container}"
done

# Copy the archive to a remote server
# if scp "$HOME/docker/backups/docker-backup-$backupDate.tar.gz" "${username}"@"${server_ip}":"$HOME/docker/backups"; then
#   # Remove the local copy of the archive if the scp task completed successfully
#   rm "$HOME/docker/backups/docker-backup-$backupDate.tar.gz"
# fi


# Thanks for the video!
# Since you aren't removing the containers, just stopping them, you don't technically need to use `docker compose stop`.
# A suggestion I would add. Instead of manually having the script "cd" into each app subdirectory, why not list all containers into a variable, stop them using this script:
# IMHO, this shortens and cleans up the script.

