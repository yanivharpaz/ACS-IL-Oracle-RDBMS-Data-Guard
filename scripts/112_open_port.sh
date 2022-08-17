#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Usage: sudo $0 [ PORT ] "
    exit 1
fi

PORT_TO_OPEN=$1

echo "Opening port: $PORT_TO_OPEN"

echo sudo /usr/sbin/iptables -I INPUT -p tcp --dport $PORT_TO_OPEN -j ACCEPT -m comment --comment "Allow Oracle RDBMS"
sudo /usr/sbin/iptables -I INPUT -p tcp --dport $PORT_TO_OPEN -j ACCEPT -m comment --comment "Allow Oracle RDBMS"

echo "Type 'sudo iptables -L' to see the list of ports that are open"
