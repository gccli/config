#! /bin/bash

if [ -f /etc/redhat-release ]; then
    . install.centos
else
    . install.ubuntu
fi

function do_install() {
    local package_list=$@
    local pkgs=

    echo
    echo "Check (${package_list}) ..."
    for i in ${package_list}
    do
        printf " check for %-64s" "$i..."
        result=$(check_package $i)
        if [ "$result" == "failure" ]; then
            pkgs="$i $pkgs"
        fi
        echo $result
    done

    if [ "$pkgs"x != "x" ]; then
        install_packages $pkgs
    fi
}

PACKAGES=$BASE_TOOLS
for opt in $@
do

    case $opt in
        dev)
            PACKAGES="${PACKAGES} ${DEV_TOOLS}"
            ;;
        lib)
            PACKAGES="${PACKAGES} ${DEV_LIBS}"
            ;;
        ext)
            PACKAGES="${PACKAGES} ${EXT_TOOLS}"
            ;;
    esac
done

read -p "Packages [$PACKAGES] will be installed (yes/no)? " yesno
if [ "${yesno}!" == "yes!" ]; then
    do_install $PACKAGES
fi
echo
