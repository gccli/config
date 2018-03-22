#!/bin/bash

internal_if=eth1
external_if=eth0
snat=0

function usage() {
    echo "Usage: $0 -i internal_interface -o external_interface --snat"
    exit 0
}

if ! my__options=$(getopt -u -o hi:o: -l internal,external,help,snat -- "$@")
then
    exit 1
fi
set -- $my__options
while [ $# -gt 0 ]
do
    case $1 in
        -h|--help)
            usage
            ;;
        -i|--internal)
            internal_if=$2
            shift 2
            ;;
        --snat)
            snat=1
            shift
            ;;
        -i|--external)
            external_if=$2
            shift 2
            ;;
        (--) shift; break;;
        (*) usage;;
    esac
done

internal_ip=$(ip addr show dev ${internal_if} | egrep '\binet\b'|egrep -o '([0-9]+\.){3}[0-9]+/[0-9]+')
external_ip=$(ip addr show dev ${external_if} | egrep '\binet\b'|egrep -o '([0-9]+\.){3}[0-9]+/[0-9]+')

echo 1 > /proc/sys/net/ipv4/ip_forward

set -ex
iptables -t nat -F
if [ $snat -eq 0 ]; then
    iptables -t nat -A POSTROUTING -s ${internal_ip} -o ${external_if} -j MASQUERADE
else
    iptables -t nat -A POSTROUTING -o ${external_if} -j SNAT --to ${external_ip}
fi
