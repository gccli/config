ns-create () {
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <name> [cidr] "
        return
    fi

    local name=$1
    local cidr=$2
    ip netns add ${name}

    ip link add dev veth0-${name} type veth peer name veth0 netns $name
    ip link set dev veth0-${name} up
    ip netns exec ${name} ip link set dev veth0 up
    if [ -n "$cidr" ]; then
        if ! echo $cidr | egrep '/[0-9]+' >/dev/null; then
           cidr=$cidr/24
        fi
        ip netns exec ${name} ip addr add dev veth0 $cidr
    fi
    ip netns exec ${name} ip link set dev lo up
}

ns-create-multi () {
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <name> [max_interface_index] [cidr]..."
        echo "  Option max_interface_index default is 1, will create 2 interface: veth0 and veth1"
        return
    fi

    local name=$1
    local max_index=${2:-1}
    shift 2

    ip netns add ${name}
    for i in $(seq 0 ${max_index}); do
        ip link add dev veth$i-${name} type veth peer name veth$i netns $name
        ip link set dev veth$i-${name} up
        ip netns exec ${name} ip link set dev veth$i up
        cidr=$1
        if [ -n "$cidr" ]; then
            if ! echo $cidr | egrep '/[0-9]+' >/dev/null; then
                cidr=$cidr/24
            fi
            echo "Set ip address ${cidr} for veth$i"
            ip netns exec ${name} ip addr add dev veth$i $cidr
        fi
        shift
    done
    ip netns exec ${name} ip link set dev lo up
}

ns-ex () {
    NS=$(ip netns | egrep "\(id: $1\)")
    if [ $? -eq 0 ]; then
        name=$(echo $NS | awk '{ print $1 }')
    else
        name=$1
    fi
    shift
    ip netns exec $name $@
}

ns-cleanup () {
    pkill dnsmasq
    pkill dhclient
    pkill ospfd
    pkill zebra
    pkill vtysh
    sleep 1
    ps -ef|egrep 'zebra|ospfd|dhclient|dnsmasq'|grep -v grep
    rm -f /tmp/*.leases


    for ns in $(ip netns list | awk '{print $1}'); do
        [ -n "$ns" ] || continue
        ip netns delete $ns
    done

    # Remove veth pair
    for ifname in $(ls /sys/class/net); do
        if echo $ifname | egrep '^veth'; then
            if ip link show $ifname >/dev/null 2>&1; then
                ip link delete $ifname
            fi
        fi
    done

    # Remove openvswitch bridge
    for br in $(ovs-vsctl list-br); do
        ovs-vsctl del-br $br
    done
}

ns-addif () {
    local netns=$1
    local iface=$2
    local cidr=${3}
    local type=${4:-ether}

    ip link add dev ${iface}-${netns} type veth peer name ${iface} netns ${netns}
    ip link set dev ${iface}-${netns} up
    ip netns exec ${netns} ip link set dev ${iface} up

    if [ -n "$cidr" ]; then
        if ! echo $cidr | egrep '/[0-9]+'; then
            cidr=$cidr/24
        fi
        ip netns exec ${netns} ip addr add dev ${iface} $cidr
    fi
}


ns-add-vlanif () {
    local netns=$1
    local ip=$2
    local vlan=$3

    ip netns exec ${netns} ip link add link veth0 name veth0.${vlan} type vlan id $vlan
    ip netns exec ${netns} ip link set dev veth0.${vlan} up
    ip netns exec ${netns} ip addr flush dev veth0
    ip netns exec ${netns} ip addr add dev veth0.${vlan} $ip
}
