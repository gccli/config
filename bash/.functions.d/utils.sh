#!/bin/bash

function unpack_targz(){
    local src_gz=${1}
    local tmpdir=$(mktemp -d)
    echo "Unpack \"${src_gz}\" to ${tmpdir}"
    tar -C $tmpdir --strip-components=1 -xzf ${src_gz}
}
