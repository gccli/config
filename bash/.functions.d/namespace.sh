ns-create () {
    local name=$1
    local cidr=$2

    ip netns add ${name}
    ip link add dev veth0-${name} type veth peer name veth0 netns $name
    ip link set dev veth0-${name} up
    ip netns exec ${name} ip link set dev veth0 up
    if [ -n "$cidr" ]; then
        if ! echo $cidr | egrep '/[0-9]+'; then
           cidr=$cidr/24
        fi
        ip netns exec ${name} ip addr add dev veth0 $cidr
    fi
    ip netns exec ${name} ip link set dev lo up
}

ns-create2 () {
    local name=$1
    local max_index=${2:-1}

    ip netns add ${name}
    for i in $(seq 0 ${max_index}); do
        ip link add dev veth$i-${name} type veth peer name veth$i netns $name
        ip link set dev veth$i-${name} up
        ip netns exec ${name} ip link set dev veth$i up
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
    for NETNS in $(ip netns list | awk '{print $1}'); do
        [ -n "$NETNS" ] || continue
        name=${NETNS}
        if [ -f "/run/dhclient-${name}.pid" ]; then
            # Stop dhclient
            pkill -F "/run/dhclient-${name}.pid"
        fi
        if [ -f "/run/iperf3-${name}.pid" ]; then
            # Stop iperf3
            pkill -F "/run/iperf3-${name}.pid"
        fi
        if [ -f "/run/bird-${name}.pid" ]; then
            # Stop bird
            pkill -F "/run/bird-${name}.pid"
        fi

        ip netns delete $NETNS
    done
    for DNSMASQ in /run/dnsmasq-vlan*.pid; do
        [ -e "$DNSMASQ" ] || continue
        # Stop dnsmasq
        pkill -F "${DNSMASQ}"
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
