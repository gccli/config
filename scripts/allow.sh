#!/bin/bash

host=$1
if [ -z "$host" ]; then
    echo "Usage: $0 host" && exit 1
fi
port=$(egrep '^Port' /etc/ssh/sshd_config |awk '{print $2}')
[ -z "$port" ] && port=22

iptables -I INPUT -p tcp -s $host --dport 20212 -j ACCEPT
iptables -I INPUT 2 -p tcp -s 0.0.0.0/0 --dport 20212 -j DROP
iptables -L INPUT -n -v --line-numbers
