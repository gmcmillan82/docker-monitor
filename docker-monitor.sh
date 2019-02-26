#!/bin/bash

TS() {
  date +"(%d-%m-%Y %H:%M:%S)"
}

dcdir="/data/system/docker/"
dcfile="$dcdir"docker-compose.yml
exec >> "$dcdir"dockermonitor.log 2>&1
services=$(cd $dcdir && docker-compose ps --services | sort)
running=$(docker ps --filter name="$1" --filter status="running" | awk '{ print $NF }' |  grep -vw "NAMES" | sort) > /dev/null 2>&1
exited=$(docker ps --filter name="$1" --filter status="exited" | awk '{ print $NF }' | grep -vw "NAMES" | sort) > /dev/null 2>&1
restarting=$(docker ps --filter name="$1" --filter status="restarting" | awk '{ print $NF }' | grep -vw "NAMES" | sort) > /dev/null 2>&1

checkStatus() {
  printf "%s - Checking status of containers...\n\n" "$(TS)"
  printf "%s - The following containers are running: \n$1\n\n" "$(TS)"

  if [ "$running" != "$services" ]; then
    printf "%s - The following containers are not running: %s\n" "$(TS)" "$exited"
    printf "___________________________________________________________________\n"
    printf "%s - The following containers are restarting: %s\n\n" "$(TS)" "$restarting"
    printf "___________________________________________________________________\n"
    printf "%s - Restarting docker-compose project...\n" "$(TS)"
    if $(docker-compose -f "$dcfile" down && docker-compose -f "$dcfile" up -d); then
      printf "%s - All containers should now be running\n" "$(TS)"
      exit 0
    else
      printf "%s - There was a problem restarting the docker-compose project. Needs investigation\n" "$(TS)"
      printf "%s - Exiting" "$(TS)"
      exit 1
    fi
  else
    printf "%s - All containers seem to be running\n" "$(TS)"
    exit 0
  fi
}

checkStatus "$services"
