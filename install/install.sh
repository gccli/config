#! /bin/bash

if [ -f /etc/redhat-release ]; then
    . install.centos
else
    . install.ubuntu
fi


PKGS=

echo
echo "Check for base packages ..."
for i in $BASE_PACKAGES
do
    printf " check for %-64s" "$i..."
    result=$(check_package $i)
    if [ "$result" == "failure" ]; then
        PKGS="$i $PKGS"
    fi
    echo $result
done

if [ "$PKGS"x != "x" ]; then
    install_packages $PKGS
fi
