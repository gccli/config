#!/bin/bash

daemon=${1:-0}
opts="--config client.ovpn"
if [ $daemon -ne 0 ]; then
    opts="--daemon --log /tmp/openvpn.log $opts"
fi

iptables -t nat -F
# SNAT and DNAT
iptables -t nat -A PREROUTING  -p tcp -m tcp -d 10.0.2.15 --dport 10080 -j DNAT --to-destination 192.168.88.1:10080
iptables -t nat -A POSTROUTING -s 10.0.2.15/24 -o tun0 -j MASQUERADE
#iptables -t nat -A POSTROUTING -p tcp -o tun0 -j SNAT --to 192.168.88.2
# Debug NAT
#iptables -t nat -I PREROUTING  -p tcp -j LOG --log-level debug --log-prefix "[DNAT] "
#iptables -t nat -I POSTROUTING -p tcp -j LOG --log-level debug --log-prefix "[SNAT] "

echo 1 > /proc/sys/net/ipv4/ip_forward

echo -n "Restart openvpn client"
killall openvpn >/dev/null 2>&1
while [ true ]; do
    echo -n "." && sleep 1
    killall -0 openvpn >/dev/null 2>&1 || break
done
echo

set -ex
openvpn ${opts}
