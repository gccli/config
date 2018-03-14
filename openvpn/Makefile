TARGET=/usr/local/sbin/openvpn

all:$(TARGET)

$(TARGET):
	@mkdir -p openvpn
	@tar -C openvpn -xzf openvpn-2.4.5.tar.gz --strip-components=1
	cd openvpn && ./configure && make && make install

clean:
	$(RM) -r $(TARGET) openvpn
