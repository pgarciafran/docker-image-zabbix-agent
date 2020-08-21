#!/bin/bash

json=$(curl -sS --connect-timeout 5 --max-time 10 -G -XGET "http://localhost:2375/containers/$1/json")
PID=$(/jq '.State.Pid' <(echo $json))
NETWORK_MODE=$(/jq '.HostConfig.NetworkMode' <(echo $json) | tr -d '"')

if [ "$NETWORK_MODE" == "host" ]
then
  echo 0;
else
  column=$(case "$2" in
    rx-bytes)   echo '$2';;
    rx-packets) echo '$3';;
    rx-errors)  echo '$4';;
    rx-drops)   echo '$5';;
    tx-bytes)   echo '$10';;
    tx-packets) echo '$11';;
    tx-errors)  echo '$12';;
    tx-drops)   echo '$13';;
  esac)

  cat /rootfs/proc/$PID/net/dev | tail -n +3 | grep -v 'lo' | awk '{s+='$column'} END {printf "%.0f\n", s}'
fi

