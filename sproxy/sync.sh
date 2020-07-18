#!/bin/bash

ip=$1
if [ "${ip}x" == "x" ]; then
    echo "Usage $0 <ip>"
    exit 0
fi

ansible $ip -m synchronize -a "src=/etc/pki/tls/certs/inetlinux.com.crt dest=/etc/pki/tls/certs/inetlinux.com.crt"
ansible $ip -m synchronize -a "src=/etc/pki/tls/private/inetlinux.com.key dest=/etc/pki/tls/private/inetlinux.com.key"
