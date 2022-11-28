FROM debian:buster-slim AS UNPACKER
ARG TARGETARCH

WORKDIR /tmp
RUN apt-get update \
    && apt-get -y install xz-utils

# unpack toolchains
COPY cache/armv6-rpi-linux-gnueabihf_${TARGETARCH}.tar.xz /tmp/
COPY cache/armv7-rpi2-linux-gnueabihf_${TARGETARCH}.tar.xz /tmp/
COPY cache/armv8-rpi3-linux-gnueabihf_${TARGETARCH}.tar.xz /tmp/
COPY cache/aarch64-rpi3-linux-gnuhf_${TARGETARCH}.tar.xz /tmp/
RUN XZ_OPT="-T0" tar xf /tmp/armv6-rpi-linux-gnueabihf_${TARGETARCH}.tar.xz
RUN XZ_OPT="-T0" tar xf /tmp/armv7-rpi2-linux-gnueabihf_${TARGETARCH}.tar.xz
RUN XZ_OPT="-T0" tar xf /tmp/armv8-rpi3-linux-gnueabihf_${TARGETARCH}.tar.xz
RUN XZ_OPT="-T0" tar xf /tmp/aarch64-rpi3-linux-gnuhf_${TARGETARCH}.tar.xz


FROM debian:buster
ARG TARGETARCH

ARG RPI_FIRMWARE_BASE_URL='http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware'
ARG RPI_FIRMWARE_VERSION='20200114-1'

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
      sudo git wget curl bc asciidoc xmlto \
      gcc g++ cmake autoconf automake libtool libtool-bin build-essential \
      pkg-config gperf bison flex texinfo bzip2 unzip xz-utils help2man gawk \
      make libncurses5-dev libssl-dev \
      python python-dev python-pip \
      python3 python3-dev python3-pip \
      htop apt-utils locales ca-certificates \
 && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

WORKDIR /tmp

RUN wget -O /tmp/libraspberrypi0_1.${RPI_FIRMWARE_VERSION}_armhf.deb \
         ${RPI_FIRMWARE_BASE_URL}/libraspberrypi0_1.${RPI_FIRMWARE_VERSION}_armhf.deb \
 && wget -O /tmp/libraspberrypi-dev_1.${RPI_FIRMWARE_VERSION}_armhf.deb \
         ${RPI_FIRMWARE_BASE_URL}/libraspberrypi-dev_1.${RPI_FIRMWARE_VERSION}_armhf.deb \
 && dpkg-deb -x /tmp/libraspberrypi0_1.${RPI_FIRMWARE_VERSION}_armhf.deb / \
 && dpkg-deb -x /tmp/libraspberrypi-dev_1.${RPI_FIRMWARE_VERSION}_armhf.deb / \
 && rm /tmp/libraspberrypi0_1.${RPI_FIRMWARE_VERSION}_armhf.deb /tmp/libraspberrypi-dev_1.${RPI_FIRMWARE_VERSION}_armhf.deb

# add idein user
RUN useradd -m idein \
 && echo idein:idein | chpasswd \
 && adduser idein sudo \
 && echo 'idein ALL=NOPASSWD: ALL' >> /etc/sudoers.d/idein

USER idein
WORKDIR /home/idein
ENV HOME /home/idein

# set locale
RUN sudo sed 's/.*en_US.UTF-8/en_US.UTF-8/' -i /etc/locale.gen
RUN sudo locale-gen
RUN sudo update-locale LANG=en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8
ENV PATH /home/idein/.local/bin:$PATH
RUN echo "export PATH=$PATH" >> /home/idein/.bashrc
CMD ["/bin/bash"]

# Shorten the name of a temporary directory before removing it for Docker under
# some configurations so that it can remove deeply-nested directory.
# See https://github.com/moby/moby/issues/13451

# Copy toolchain from UNPACKER
RUN mkdir -p /home/idein/x-tools
COPY --from=UNPACKER /tmp/armv6-rpi-linux-gnueabihf /home/idein/x-tools/
COPY --from=UNPACKER /tmp/armv7-rpi2-linux-gnueabihf /home/idein/x-tools/
COPY --from=UNPACKER /tmp/armv8-rpi3-linux-gnueabihf /home/idein/x-tools/
COPY --from=UNPACKER /tmp/aarch64-rpi3-linux-gnuhf /home/idein/x-tools/

RUN sudo rm -r \
    /home/idein/x-tools/armv6-rpi-linux-gnueabihf \
    /home/idein/x-tools/armv7-rpi2-linux-gnueabihf \
    /home/idein/x-tools/armv8-rpi3-linux-gnueabihf \
    /home/idein/x-tools/aarch64-rpi3-linux-gnuhf

ENV PATH $HOME/x-tools/bin:$PATH

RUN echo "export PATH=$PATH" >> /home/idein/.bashrc
