#!/bin/bash -ex

yum install -y strongswan xl2tpd bind-utils

source vars


cat > /etc/ipsec.conf <<EOF
# basic configuration
config setup
  # strictcrlpolicy=yes
  # uniqueids = no

# Add connections here.

# Sample VPN connections
conn %default
  ikelifetime=60m
  keylife=20m
  rekeymargin=3m
  keyingtries=1
  keyexchange=ikev1
  authby=secret
  ike=aes128-sha1-modp2048!
  esp=aes128-sha1-modp2048!

conn myvpn
  keyexchange=ikev1
  left=%defaultroute
  auto=add
  authby=secret
  type=transport
  leftprotoport=17/1701
  rightprotoport=17/1701
  right=$VPN_SERVER_IP
EOF

cat > /etc/ipsec.secrets <<EOF
: PSK "$VPN_IPSEC_PSK"
EOF

chmod 600 /etc/ipsec.secrets

if [ ! -f /etc/strongswan/ipsec.conf.orig ]; then
    mv /etc/strongswan/ipsec.conf /etc/strongswan/ipsec.conf.orig
fi
if [ ! -f /etc/strongswan/ipsec.secrets.orig ]; then
    mv /etc/strongswan/ipsec.secrets /etc/strongswan/ipsec.secrets.orig
fi
ln -sf /etc/ipsec.conf /etc/strongswan/ipsec.conf
ln -sf /etc/ipsec.secrets /etc/strongswan/ipsec.secrets

cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[lac myvpn]
lns = $VPN_SERVER_IP
ppp debug = yes
pppoptfile = /etc/ppp/options.l2tpd.client
length bit = yes
EOF

cat > /etc/ppp/options.l2tpd.client <<EOF
ipcp-accept-local
ipcp-accept-remote
refuse-eap
require-chap
noccp
noauth
mtu 1280
mru 1280
noipdefault
defaultroute
usepeerdns
connect-delay 5000
name $VPN_USER
password $VPN_PASSWORD
EOF

chmod 600 /etc/ppp/options.l2tpd.client
