#!/bin/bash

secret=$(readlink -f client.key)

cat > client.conf <<EOF
remote server
dev tun
ifconfig 10.8.0.2 10.8.0.1
secret $secret

route 192.168.99.0 255.255.255.0
route 172.16.254.0 255.255.255.0
EOF

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

killall openvpn >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -n "Stop openvpn client"
    i=0; while [ $i -lt 3 ]; do  echo -n "." && sleep 1 && i=$(($i+1)); done;  echo
fi

openvpn --daemon --config client.conf
