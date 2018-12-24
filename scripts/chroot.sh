#!/bin/bash

# Set CHROOT directory name
basedir="/var/jail"

# Add command to current directory
function add_cmd() {
    [ -z "$1" ] && return
    cmd_path=$1
    cmd_name=$(basename ${cmd_path})
    /bin/cp ${cmd_path} ${cmd_name}

    local files="$(ldd ${cmd_name} | awk '{ print $3 }' |egrep -v ^'\(')"
    echo "Copying shared libs to ${basedir}..."
    for i in $files; do
        dirn="$(dirname $i)"
        mkdir -p ${basedir}${dirn}
        /bin/cp $i ${basedir}${dirn}
    done

    sldl="$(ldd $1 | grep 'ld-linux' | awk '{ print $1}')"
    sldlsubdir="$(dirname $sldl)"
    if [ ! -f ${basedir}$sldl ]; then
        echo "Copying $sldl ${basedir}$sldlsubdir..."
        /bin/cp $sldl ${basedir}$sldlsubdir
    fi
}

getent group admin || groupadd admin
rm -rf $basedir
mkdir -p ${basedir}/{dev,etc,lib,lib64,usr/bin,usr/sbin,home}
chown root.root ${basedir}

cd ${basedir}
ln -s usr/bin bin
ln -s usr/sbin sbin

mknod -m 666 /var/jail/dev/null c 1 3

cd ${basedir}/etc
cp /etc/ld.so.cache .
cp /etc/ld.so.conf .
cp /etc/nsswitch.conf .
cp /etc/hosts .

cd ${basedir}/usr/bin
add_cmd /usr/bin/ls
add_cmd /usr/bin/bash
add_cmd /usr/bin/sed
add_cmd /usr/bin/grep
add_cmd /usr/bin/ping

userdel -r admin
adduser -g admin -d /var/jail/home/admin -p '$6$eUqgT0dLunwHSBXr$1NynmBu41rLSBqgLZaOT0YSkUN6LYs.BZ/Zt3.YV.pcSUsL2yX3VQa5IHdYmwh0xGin/lwh7Hel5ZJf7jb9VT1' admin
