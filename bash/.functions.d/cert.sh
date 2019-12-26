#!/bin/bash

function showcert() {
    if [ -z "$1" ]; then
        echo "$0 /path/to/cert"
        return
    fi

    openssl x509 -noout -certopt no_pubkey,no_sigdump -text -in $1
}
