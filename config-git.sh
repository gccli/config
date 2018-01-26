#! /bin/bash

[ -z "$1" ] && echo "Usage $0 username" && exit 1

url=$(git remote -v |sed -n '1p'|awk '{ print $2 }')
echo $url | egrep '^https' >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "config git..."
    git config credential.helper 'cache --timeout=86400'
    git config credential.$url gccli
    git config --local -l
fi
