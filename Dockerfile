FROM lsiobase/alpine:3.9

MAINTAINER stéphane BROSSE <stevebrush@gmail.com>
MAINTAINER  Simon Zhou <simon.zhou@gmail.com>

#COPY CMakeLists.txt /CMakeLists.txt
COPY patches/ /
RUN apk add --no-cache git tzdata && \
    git clone -b development --depth 2 https://github.com/domoticz/domoticz.git /src/domoticz && \
    cd /src/domoticz && \
    git fetch --unshallow && \
    sed -i -e "s/sys\/errno.h/errno.h/g" /src/domoticz/hardware/csocket.cpp && \
    sed -i -e "s/sys\/signal.h/signal.h/g" /src/domoticz/hardware/serial/impl/unix.cpp && \
    apk add --no-cache git \
        wget tar xz sudo \
        build-base cmake \
        libressl-dev \
        zlib-dev \
        curl libcurl curl-dev \
        boost boost-dev protobuf \
		confuse-dev doxygen libusb-compat-dev libusb-dev \
		musl-dev \
        sqlite-dev \
        lua5.2 lua5.2-dev py-pip \
		nodejs alpine-sdk avahi-compat-libdns_sd \
        mosquitto-dev libftdi1-dev libftdi1 \
        libusb-compat libusb-compat-dev \
        python3 python3-dev python-dev  py-pip \
        udev eudev-dev \
        boost-thread \
        boost-system \
        boost-date_time \
        coreutils jq bash-completion && \
	pip install paho-mqtt && \

	echo "**** link libftdi libs ****" && \
	ln -s /usr/lib/libftdi1.so /usr/lib/libftdi.so && \
	ln -s /usr/lib/libftdi1.a /usr/lib/libftdi.a && \
	ln -s /usr/include/libftdi1/ftdi.h /usr/include/ftdi.h && \
 
	echo "**** build telldus-core ****" && \
	mkdir -p \
		/tmp/telldus-core && \
#	wget http://download.telldus.com/TellStick/Software/telldus-core/telldus-core-2.1.2.tar.gz && \
	tar xf telldus-core-2.1.2.tar.gz -C \
		/tmp/telldus-core --strip-components=1 && \
	curl -o /tmp/telldus-core/Doxyfile.in -L \
		https://raw.githubusercontent.com/telldus/telldus/master/telldus-core/Doxyfile.in && \
	cp /tmp/patches/Socket_unix.cpp /tmp/telldus-core/common/Socket_unix.cpp && \
	cp /tmp/patches/ConnectionListener_unix.cpp /tmp/telldus-core/service/ConnectionListener_unix.cpp && \
	cp /tmp/patches/CMakeLists.txt /tmp/telldus-core/CMakeLists.txt && \
	cd /tmp/telldus-core && \
	cmake -DBUILD_TDADMIN=false -DCMAKE_INSTALL_PREFIX=/tmp/telldus-core . && \
	make && \
	
	echo "**** configure telldus core ****" && \
	mv /tmp/telldus-core/client/libtelldus-core.so.2.1.2 /usr/lib/libtelldus-core.so.2.1.2 && \
	mv /tmp/telldus-core/client/telldus-core.h /usr/include/telldus-core.h && \
	ln -s /usr/lib/libtelldus-core.so.2.1.2 /usr/lib/libtelldus-core.so.2 && \
	ln -s /usr/lib/libtelldus-core.so.2 /usr/lib/libtelldus-core.so && \

#	cd /usr/src && \
#	wget http://download.telldus.com/TellStick/Software/telldus-core/telldus-core-2.1.2.tar.gz && \
#	gunzip telldus-core-2.1.2.tar.gz && \
#Change {version} to the downloaded version
#	tar xvf telldus-core-2.1.2.tar && \
#	cd telldus-core-2.1.2 && \
#	cmake -DCMAKE_INSTALL_PREFIX=/usr . && \
#	make && \

#    wget https://www.python.org/ftp/python/3.5.2/Python-3.5.2.tar.xz && \
#    tar -xvf Python-3.5.2.tar.xz && \
#    cd Python-3.5.2 && \
#    ./configure --enable-shared && \
#    make && \
#    sudo make install && \
#    cp -f /CMakeLists.txt CMakeLists.txt && \

    sed -i -e "s/sys\/poll.h/poll.h/g" /usr/include/boost/asio/detail/socket_types.hpp && \
    git clone --depth 2 https://github.com/OpenZWave/open-zwave.git /src/open-zwave && \
    cd /src/open-zwave && \
    make && \
    ln -s /src/open-zwave /src/open-zwave-read-only && \
    cd /src/domoticz && \
    cmake -DCMAKE_BUILD_TYPE=Release -Wno-dev . && \
#    cmake -USE_STATIC_OPENZWAVE -DCMAKE_BUILD_TYPE=Release CMakeLists.txt && \
    make && \
    rm -rf /src/domoticz/.git && \
    rm -rf /src/open-zwave/.git && \
    pip install beautifulsoup4 && \
    apk del git \
        build-base \
        cmake \
        libressl-dev \
        zlib-dev \
        curl-dev \
        boost-dev \
        sqlite-dev \
        lua5.2-dev \
        mosquitto-dev \
        libusb-compat-dev \
        eudev-dev \
        coreutils

VOLUME /config

COPY run.sh /run.sh

RUN chmod +x /run.sh 

EXPOSE 9080

CMD ["/run.sh"]

#ENTRYPOINT ["/src/domoticz/domoticz", "-dbase", "/config/domoticz.db", "-log", "/config/domoticz.log", "-sslwww", "0"]
#CMD ["-www", "9080"]
