# Generate random password

REF:https://www.cnblogs.com/jinhengyu/p/10258102.html

copy cert and key file to /etc/tls
add `ip hostname` to /etc/hosts

ansible-playbook -i hosts --ask-vault-pass setup.yml

Squid configuration
===================

htpasswd -c /etc/squid/passwd <username>

http_port 127.0.0.1:43128


STUNNEL configuration
=====================

Reference: https://www.stunnel.org/static/stunnel.html

```
; **************************************************************************
; * Global options                                                         *
; **************************************************************************

setuid = nobody
setgid = nobody
pid = /var/run/stunnel/stunnel.pid
client = no
debug = 6
output = /var/log/stunnel.log
cert = /etc/pki/tls/certs/inetlinux.com.crt
key = /etc/pki/tls/private/inetlinux.com.key
options = NO_SSLv2
options = NO_SSLv3
options = NO_TLSv1
[https]
accept  = 44433
connect = 127.0.0.1:43128

```

touch /var/log/stunnel.log
chown nobody.nobody /var/log/stunnel.log

mkdir -p /var/run/stunnel
chown nobody.nobody /var/run/stunnel
