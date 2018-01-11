TARGET=sslproxy

all:$(TARGET)

$(TARGET):stunnel/src/stunnel
	@ln -sf $^ $@

stunnel/src/stunnel:
	@mkdir -p stunnel
	@tar -C stunnel -xzf stunnel-5.44.tar.gz --strip-components=1
	cd stunnel && ./configure && make

	ln -s $(TARGET) proxy

clean:
	$(RM) -r $(TARGET) stunnel
