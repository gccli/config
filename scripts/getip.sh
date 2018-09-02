#! /bin/bash

which dig >/dev/null 2>&1 || yum install -y bind-utils >/dev/null 2>&1
dig @resolver1.opendns.com -t A -4 myip.opendns.com +short
