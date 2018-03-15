#!/bin/bash

[ ! -f my.key ] && openvpn --genkey --secret my.key

pki_enable=${1:-0}
daemon=${2:-0}
opts=

pki_dir=$(readlink -f easyrsa/pki)
dh=$(readlink -f ${pki_dir}/dh.pem)
ca=$(readlink -f ${pki_dir}/ca.crt)
key=$(readlink -f ${pki_dir}/private/server.key)
cert=$(readlink -f ${pki_dir}/issued/server.crt)
secret=$(readlink -f my.key)

if [ ${pki_enable} -eq 0 ]; then
    /bin/cp -f config/server-statickey.conf server.conf
    sed -i "s|^secret.*|secret $secret|" server.conf
else
    /bin/cp -f config/server-pki.conf server.conf
    sed -i "s|^dh.*|dh $dh|" server.conf
    sed -i "s|^ca.*|ca $ca|" server.conf
    sed -i "s|^key.*|key $key|" server.conf
    sed -i "s|^cert.*|cert $cert|" server.conf
    sed -i "s|^tls-auth.*|tls-auth $secret 0|" server.conf
    opts="--askpass /tmp/pass.txt"
fi
if [ $daemon -ne 0 ]; then
    opts="--daemon $opts"
else
    sed -i '/^log/d' server.conf
fi

echo 1 > /proc/sys/net/ipv4/ip_forward
echo -n "Restart openvpn server"
killall openvpn >/dev/null 2>&1

while [ true ]; do
    echo -n "." && sleep 1
    killall -0 openvpn >/dev/null 2>&1 || break
done
echo

set -ex
openvpn $opts --config server.conf
