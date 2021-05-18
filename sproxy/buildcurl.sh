#!/bin/bash

cat >.curlrc.j2 <<EOF
proxy=https://{{proxy_username}}:{{proxy_password}}@{{my_hostname}}:{{proxy_port}}
noproxy=127.0.0.1,localhost
proxy-cacert=/ca.crt
connect-timeout=5
EOF

ansible --ask-vault-pass localhost -m template -a 'src=.curlrc.j2 dest=.curlrc'

/bin/cp ~/git/certs/pki/ca.crt ca.crt

cat >Dockerfile <<EOF
FROM curlimages/curl

RUN mkdir /download && chown -R curl_user /download
USER curl_user

COPY --chown=curl_user .curlrc /home/curl_user/
COPY --chown=curl_user ca.crt /

WORKDIR /download
VOLUME /download

EOF

docker build -t xcurl .
rm -f Dockerfile ca.crt
docker run --name xcurl --rm xcurl -i -X HEAD https://www.google.com
docker run -v $(pwd):/download -w /download --name xcurl --rm xcurl -L -JO https://raw.githubusercontent.com/curl/curl-docker/master/alpine/latest/Dockerfile
