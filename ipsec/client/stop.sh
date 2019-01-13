#!/bin/bash


route del default dev ppp0

echo "d myvpn" > /var/run/xl2tpd/l2tp-control
strongswan down myvpn
