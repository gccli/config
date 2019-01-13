#!/bin/bash

source vars

mkdir -p /var/run/xl2tpd
touch /var/run/xl2tpd/l2tp-control

service strongswan restart
service xl2tpd restart

sleep 1
echo;echo;echo;
ip addr
echo '--------------------------------'
echo
strongswan up myvpn
sleep 3
echo "c myvpn" > /var/run/xl2tpd/l2tp-control

sleep 6
ip addr
echo '--------------------------------'
echo
ip route

route add $VPN_SERVER_IP gw $GATEWAY
route add $LOCAL_PUB_IP gw $GATEWAY
echo
#curl http://ipv4.icanhazip.com
echo "******** MY IPADDR ********"
dig @resolver1.opendns.com -t A -4 myip.opendns.com +short

route add default dev ppp0
echo
echo "******** MY IPADDR ********"
dig @resolver1.opendns.com -t A -4 myip.opendns.com +short
