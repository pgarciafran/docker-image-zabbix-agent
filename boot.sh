#!/bin/bash
set -e

# Add docker group when first run, if not recreate it to ensure the right gid
if [ $(getent group docker) ]; then
  groupdel docker
fi

groupadd -g $(stat -c "%g" /var/run/docker.sock) docker

# Update permissions for zabbix user
usermod -G docker zabbix

# Set environmental variable host hostname
export ZBX_HOSTNAME=$(cat /hostname)

# Wait for etcd_proxy
IFS=: read etcd_address etcd_port <<< $ETCD_HOST
while ! nc -z $etcd_address $etcd_port; do
  sleep 1
done

# Set environmental variable for zabbix server
server_ips=$(curl http://$ETCD_HOST/v2/keys/ipnetcom/zabbix/serverips | /jq '.node | .value ' | tr -d '\"')

OLD_IFS=$IFS

IFS=$IFS,
servers=()
active_servers=()
for ip in $server_ips; do
    echo -n "Pinging $ip..."
    ping -c1 -t1 "$ip" &>/dev/null && echo "success. Adding to ZBX_SERVER_HOST." && servers+=($ip) && active_servers+=($ip:10051) || echo fail
done

export ZBX_SERVER_HOST=$(IFS=, ; echo "${servers[*]}")
export ZBX_ACTIVESERVERS=$(IFS=, ; echo "${active_servers[*]}")

IFS=$OLD_IFS

# Re-execution of docker entrypoint 
exec /run_zabbix_component.sh agentd none
