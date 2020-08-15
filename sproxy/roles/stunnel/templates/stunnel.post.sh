#!/bin/bash

echo "Post-start stunnel..."

iptables -D INPUT -p tcp --dport {{proxy_port}} -j ACCEPT || true
iptables -I INPUT -p tcp --dport {{proxy_port}} -j ACCEPT

systemd-notify --ready --status="Stunnel started, iptables rule installed"

timeout=${WATCHDOG_USEC}
if [ "${timeout}x" == "x" ]; then
    echo "No Watchdog"
    exit 0
fi

if [ ${timeout} -eq 0 ]; then
    echo "Watchdog is disabled"
    exit 0
fi
timeout=$(($timeout/2+1))

while : ; do
    pkill -0 stunnel
    if [ $? -ne 0 ]; then
        echo "Stunnel is die"
        break
    fi
    systemd-notify --status="Watchdog" WATCHDOG=1
    sleep $timeout
done
