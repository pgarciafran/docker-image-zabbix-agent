#!/bin/bash

df --output=source,target | grep -E '^/dev/(sd|mapper)' | sed -e "s/rootfs//" | sed -e "s/\/\//\//" | awk 'BEGIN { ORS = ""; print "{\"data\": [ "} { printf "%s{\"{#FSPATH}\": \"/rootfs%s\", \"{#FSNAME}\": \"%s\"}", separator, $2, $2; separator = ", " } END { print " ]} " }'

