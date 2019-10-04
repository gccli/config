#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <host> ..."
    echo "  e.g. $0 223.72.51.39 93.184.216.34"
    exit 1
fi
port=$(egrep '^Port' /etc/ssh/sshd_config |awk '{print $2}')
[ -z "$port" ] && port=22

iptables -F INPUT
linenum=1
for host in $@; do
    iptables -I INPUT -p tcp -s $host --dport $port -j ACCEPT
    linenum=$(($linenum+1))
done

iptables -I INPUT $linenum -p tcp -s 0.0.0.0/0 --dport $port -j DROP
iptables -L INPUT -n -v --line-numbers
