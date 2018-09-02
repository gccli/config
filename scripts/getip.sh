#! /bin/bash

test -f /usr/bin/dig || yum install -y bind-utils >/dev/null 2>&1
dig @resolver1.opendns.com -t A -4 myip.opendns.com +short
