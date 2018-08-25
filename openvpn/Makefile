TARGET=/usr/local/sbin/openvpn

all:$(TARGET)

/usr/bin/gcc:
	yum groupinstall "Development Tools"

/usr/include/openssl/ssl.h:
	yum install -y epel-release openssl-devel lz4-devel lzo-devel  pam-devel

/sbin/route:
	yum install -y net-tools

$(TARGET):/usr/bin/gcc /usr/include/openssl/ssl.h /sbin/route
	@mkdir -p openvpn
	@tar -C openvpn -xzf openvpn-2.4.5.tar.gz --strip-components=1
	cd openvpn && ./configure && make && make install

clean:
	$(RM) -r $(TARGET) openvpn
