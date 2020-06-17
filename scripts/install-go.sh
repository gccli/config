#!/bin/bash -e

GOVERSION=1.14.3

#GOURL=https://dl.google.com/go/go${GOVERSION}.linux-amd64.tar.gz
#GOURL=https://gomirrors.org/dl/go/go${GOVERSION}.linux-amd64.tar.gz
GOURL=file:///opt/www/pub/go${GOVERSION}.linux-amd64.tar.gz
GOROOT=/usr/local/go
GOBASE=$(dirname $GOROOT)
#GOPROXY=https://mirrors.aliyun.com/goproxy/
rm -rf $GOROOT
echo "curl -sL ${PROXY_OPTS} $GOURL | tar -C $GOBASE -xzv"
curl -sL ${PROXY_OPTS} $GOURL | tar -C $GOBASE -xzv

# REFERENCE: https://goproxy.io/zh/
cat >/etc/profile.d/golang.sh <<EOF
export PATH=$PATH:$GOROOT/bin
export GOPATH=/opt/go
export GOPROXY=https://goproxy.io
export GOSUMDB=gosum.io+ce6e7565+AY5qEHUk/qmHc5btzW45JVoENfazw8LielDsaI+lEbq6
EOF

echo
source /etc/profile.d/golang.sh

go version
go env

echo
echo "Run [source /etc/profile.d/golang.sh] load golang environemnt"
