#!/bin/bash

dump-flows () {
  ovs-ofctl -OOpenFlow13 --names --no-stat dump-flows "$@" \
    | sed 's/cookie=0x5adc15c0, //'
}

save-flows () {
  ovs-ofctl -OOpenFlow13 --no-names --sort dump-flows "$@"
}

diff-flows () {
  ovs-ofctl -OOpenFlow13 diff-flows "$@" | sed 's/cookie=0x5adc15c0 //'
}

vlan-id () {
  python -c "print( int(hex($1 & (~(1<<12))), 16) )"
}

ovs-add-ports() {
    local br=${1:-br1}
    ovs-vsctl list-ports ${br} || ovs-vsctl add-br ${br}
    for index in {1..12}; do
        for ns in {"r${index}","c${index}","s${index}","h${index}"}; do
            ip netns pids ${ns} >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                for ifidx in {0..9}; do
                    port_name="veth${ifidx}-${ns}"
                    if ip link show ${port_name} >/dev/null 2>&1; then
                        echo "Add port ${port_name}"
                        ovs-vsctl add-port ${br} ${port_name} 2>/dev/null
                    fi
                done
            fi
        done
    done
}

ovs-create-router() {
    local br=${1}
    local ro=${2}

    if [ $# -ne 2 ]; then
        echo "Usage: $0 switch router"
        return
    fi


}
