#!/bin/bash

GOVERSION=1.14.3
GOURL=https://gomirrors.org/dl/go/go${GOVERSION}.linux-amd64.tar.gz
GOROOT=/usr/local/go
GOBASE=$(dirname $GOROOT)

rm -rf $GOROOT

echo "curl -sL ${PROXY_OPTS} $GOURL | tar -C $GOBASE -xzv"
curl -sL ${PROXY_OPTS} $GOURL | tar -C $GOBASE -xzv

cat >/etc/profile.d/golang.sh <<EOF
export PATH=$PATH:$GOROOT/bin
export GOPATH=/opt/go
export GOPROXY=https://goproxy.io
EOF

# REFERENCE: https://goproxy.io/zh/
echo
echo "Run [source /etc/profile.d/golang.sh] load golang environemnt"

source /etc/profile.d/golang.sh
go version
go env | egrep '^GO'
