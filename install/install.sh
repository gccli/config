#! /bin/bash

if [ -f /etc/redhat-release ]; then
    . install.centos
else
    . install.ubuntu
fi


echo
echo "Check for base packages ..."
for i in $BASE_PACKAGES
do
    result=$(check_package $i)
    printf " check for %-64s" "$i..."
    echo $result
done
