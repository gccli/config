#!/bin/bash

ip=$1
domain=$2
if [ $# != 2 ]; then
    echo "Usage $0 <ip> <domain>"
    exit 0
fi

scp -p ~/git/certs/pki/issued/${domain}.crt   $ip:/etc/pki/tls/certs/${domain}.crt
scp -p ~/git/certs/pki//private/${domain}.key $ip:/etc/pki/tls/private/${domain}.key

rsync -av ../sproxy $ip:~/
ssh $ip yum install -y epel-release
ssh $ip yum install -y ansible
