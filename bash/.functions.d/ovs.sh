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
