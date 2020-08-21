FROM zabbix/zabbix-agent:ubuntu-3.2.1

MAINTAINER IP.Netcom Galician Team: Anxo Beltrán (anxo.beltran.alvarez@ipnetcom.at), Pedro García (pedro.garcia.franco@ipnetcom.at)

# Install dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl \
    && apt-get install -y --no-install-recommends vim \
    && apt-get clean \
    && rm -r /var/lib/apt/lists/*

COPY zabbix_module_docker.so /var/lib/zabbix/modules/zabbix_module_docker.so

# For json support
COPY jq /jq

# Override original init script
COPY run_zabbix_component.sh /run_zabbix_component.sh

# Zabbix agent userparameters
COPY docker-net.sh /usr/local/bin/docker-net.sh
COPY partitions-discover.sh /usr/local/bin/partitions-discover.sh
COPY lld-disks.py /usr/local/bin/lld-disks.py

COPY docker_userparameters.conf /etc/zabbix/zabbix_agentd.d/docker_userparameters.conf
COPY userparameter_diskstats.conf /etc/zabbix/zabbix_agentd.d/userparameter_diskstats.conf

# Startup script
COPY boot.sh /

CMD ["/boot.sh"]

