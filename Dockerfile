ARG BUILD_FROM
FROM $BUILD_FROM

ARG MAKE_THREADS=8

COPY etc/qemu-arm-static /usr/bin/
COPY etc/qemu-aarch64-static /usr/bin/

RUN apt-get update
RUN apt-get install -y --no-install-recommends \
        build-essential

ARG FRIENDLY_ARCH

COPY dist/openfst-1.6.9-${FRIENDLY_ARCH}.tar.gz /
COPY download/phonetisaurus-2019.tar.gz /

RUN mkdir -p /build && \
    tar -C /build -xvf /openfst-1.6.9-${FRIENDLY_ARCH}.tar.gz

ENV CXXFLAGS="-I/build/include"
ENV LDFLAGS="-L/build/lib"

RUN cd / && tar -xzf /phonetisaurus-2019.tar.gz && \
    cd phonetisaurus && \
    ./configure --prefix=/build \
        --disable-static \
        --with-openfst-includes=/build/include \
        --with-openfst-libs=/build/lib && \
    make -j $MAKE_THREADS && \
    make install

# Delete static libs
RUN find /build -type f -name '*.a' -delete