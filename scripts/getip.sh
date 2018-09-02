#! /bin/bash

which dig || yum install -y bind-utils
dig @resolver1.opendns.com -t A -4 myip.opendns.com +short
