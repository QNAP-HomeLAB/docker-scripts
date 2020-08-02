#!/bin/bash
# This script displays 50 log entries for the indicated docker-compose container.

# Load config variables from file
  source /share/docker/scripts/.docker_vars.env

# Perform scripted action(s)
  docker-compose docker logs -tf --tail="50" "$1"