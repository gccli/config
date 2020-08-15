#!/bin/bash

echo "Before start stunnel..."

/usr/bin/install -o nobody -g nobody -d /var/run/stunnel
touch /var/log/stunnel.log
chown nobody.nobody /var/log/stunnel.log
