#!/bin/bash

name=$1
if [ "${name}x" == "x" ]; then
    echo "Usage: $0 name"
    exit 0
fi

tempdir=$(mktemp -d)

rm -f $name.tar.gz
cp -f my.key easyrsa/pki/ca.crt easyrsa/pki/issued/${name}.crt easyrsa/pki/private/${name}.key $tempdir
tar -C $tempdir -czf $name.tar.gz .
tar -tzf $name.tar.gz
