FROM alpine:latest
MAINTAINER stéphane BROSSE <stevebrush@gmail.com>

#COPY CMakeLists.txt /CMakeLists.txt

RUN apk add --no-cache git tzdata && \
    git clone -b master --depth 2 https://github.com/domoticz/domoticz.git /src/domoticz && \
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
        boost-dev \
        sqlite-dev \
        lua5.2 lua5.2-dev pip \
        mosquitto-dev \
        libusb-compat libusb-compat-dev \
        python3 python3-dev \
        udev eudev-dev \
        boost-thread \
        boost-system \
        boost-date_time \
        coreutils jq bash-completion && \
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
