#!/bin/bash

secret=$(readlink -f my.key)
pki_enable=${1:-0}
daemon=${2:-0}
opts=

if [ ${pki_enable} -eq 0 ]; then
    /bin/cp -f config/client-statickey.conf client.conf
else
    /bin/cp -f config/client-pki.conf client.conf
    opts="--askpass /tmp/pass.txt"
fi
if [ $daemon -ne 0 ]; then
    opts="--daemon $opts"
else
    sed -i '/^log/d' client.conf
fi

snbnet="10.0.2.0/24"

iptables -t nat -F
#iptables -t nat -A POSTROUTING -s $subnet ! -o eth0 -j MASQUERADE
#iptables -t nat -A POSTROUTING -p tcp -o eth0 -j SNAT --to 10.8.0.2

# SNAT and DNAT
iptables -t nat -A POSTROUTING -p tcp -o tun0 -j SNAT --to 10.8.0.2
iptables -t nat -A PREROUTING  -p tcp -m tcp -d 10.0.2.15 --dport 10080 -j DNAT --to-destination 10.8.0.1:10080

# Debug NAT
iptables -t nat -I PREROUTING  -p tcp -j LOG --log-level debug --log-prefix "[DNAT] "
iptables -t nat -I POSTROUTING -p tcp -j LOG --log-level debug --log-prefix "[SNAT] "

echo 1 > /proc/sys/net/ipv4/ip_forward

echo -n "Restart openvpn client"
killall openvpn >/dev/null 2>&1
i=0; while [ $i -lt 1 ]; do  echo -n "." && sleep 1 && i=$(($i+1)); done;  echo

set -ex
openvpn ${opts} --config client.conf
