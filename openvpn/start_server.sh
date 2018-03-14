#!/bin/bash

[ ! -f my.key ] && openvpn --genkey --secret my.key

secret=$(readlink -f my.key)

cat > server.conf <<EOF
dev tun
ifconfig 10.8.0.1 10.8.0.2
secret $secret
EOF

echo 1 > /proc/sys/net/ipv4/ip_forward

echo -n "Restart openvpn server"
killall openvpn >/dev/null 2>&1
i=0; while [ $i -lt 3 ]; do  echo -n "." && sleep 1 && i=$(($i+1)); done;  echo
openvpn --daemon --config server.conf
