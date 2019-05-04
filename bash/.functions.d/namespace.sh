ns-create () {
    NAME=$1
    IP=$2

    sudo ip netns add ${NAME}
    sudo ip link add dev veth-${NAME} type veth peer name veth0 netns $NAME
    sudo ip link set dev veth-${NAME} up
    sudo ip netns exec ${NAME} ip link set dev veth0 up
    if [ -n "$IP" ]; then
        if ! echo $IP | egrep '/[0-9]+'; then
           IP=$IP/24
        fi
        sudo ip netns exec ${NAME} ip addr add dev veth0 $IP
    fi
    sudo ip netns exec ${NAME} ip link set dev lo up
}

ns-ex () {
    NS=$(ip netns | egrep "\(id: $1\)")
    if [ $? -eq 0 ]; then
        NAME=$(echo $NS | awk '{ print $1 }')
    else
        NAME=$1
    fi
    shift
    sudo ip netns exec $NAME $@
}

ns-cleanup () {
    for NETNS in $(sudo ip netns list | awk '{print $1}'); do
        [ -n "$NETNS" ] || continue
        NAME=${NETNS}
        if [ -f "/run/dhclient-${NAME}.pid" ]; then
            # Stop dhclient
            sudo pkill -F "/run/dhclient-${NAME}.pid"
        fi
        if [ -f "/run/iperf3-${NAME}.pid" ]; then
            # Stop iperf3
            sudo pkill -F "/run/iperf3-${NAME}.pid"
        fi
        if [ -f "/run/bird-${NAME}.pid" ]; then
            # Stop bird
            sudo pkill -F "/run/bird-${NAME}.pid"
        fi
        # Remove netns and veth pair
        sudo ip link delete veth-${NAME}
        sudo ip netns delete $NETNS
    done
    for DNSMASQ in /run/dnsmasq-vlan*.pid; do
        [ -e "$DNSMASQ" ] || continue
        # Stop dnsmasq
        sudo pkill -F "${DNSMASQ}"
    done
    # Remove faucet dataplane connection
    sudo ip link delete veth 2>/dev/null || true
    # Remove openvswitch bridge
    sudo ovs-vsctl del-br br0
}

ns-add-vlanif () {
     NAME=$1
     NETNS=$1
     IP=$2
     VLAN=$3
     sudo ip netns exec ${NETNS} ip link add link veth0 name veth0.${VLAN} type vlan id $VLAN
     sudo ip netns exec ${NETNS} ip link set dev veth0.${VLAN} up
     sudo ip netns exec ${NETNS} ip addr flush dev veth0
     sudo ip netns exec ${NETNS} ip addr add dev veth0.${VLAN} $IP
}
