#!/bin/bash

ip=$1
if [ "${ip}x" == "x" ]; then
    echo "Usage $0 <ip>"
    exit 0
fi

scp -p /etc/pki/tls/certs/inetlinux.com.crt   $ip:/etc/pki/tls/certs/inetlinux.com.crt
scp -p /etc/pki/tls/private/inetlinux.com.key $ip:/etc/pki/tls/private/inetlinux.com.key
