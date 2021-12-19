ARG DEBIAN_IMAGE_TAG=bullseye

FROM debian:${DEBIAN_IMAGE_TAG} as base

ARG RPI_FIRMWARE_BASE_URL='http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware'
ARG RPI_FIRMWARE_VERSION='20200114-1'

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
      sudo git wget curl bc asciidoc xmlto \
      gcc g++ cmake autoconf automake libtool libtool-bin build-essential \
      pkg-config gperf bison flex texinfo bzip2 unzip xz-utils help2man gawk \
      make libncurses5-dev libssl-dev \
      python3 python3-dev python3-pip \
      htop apt-utils locales ca-certificates \
 && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

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
CMD ["/bin/bash"]


FROM base AS builder

ARG DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

RUN curl -sLO http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.24.0.tar.xz \
 && tar xJf crosstool-ng-1.24.0.tar.xz \
 && cd crosstool-ng-1.24.0 \
 && sed 's|http://isl.gforge.inria.fr|https://libisl.sourceforge.io|' -i config/versions/isl.in \
 && sed 's|http://downloads.sourceforge.net/project/expat/expat/${CT_EXPAT_VERSION}|https://github.com/libexpat/libexpat/releases/download/R_${CT_EXPAT_VERSION//./_}|' -i config/versions/expat.in \
 && ./configure \
 && make \
 && sudo make install \
 && cd .. \
 && rm -rf crosstool-ng-1.24.0 crosstool-ng-1.24.0.tar.xz

# use GCC 8 or 9 for crosstool-NG 1.24.0
RUN . /etc/os-release \
 && if [ "$VERSION_ID" -eq 11 ]; then \
         sudo apt-get update \
      && sudo apt-get install -y --no-install-recommends \
           gcc-9 g++-9 \
      && sudo apt-get clean \
      && sudo rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/* \
      && sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 9 \
      && sudo update-alternatives --config gcc \
      && sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 9 \
      && sudo update-alternatives --config g++ \
 ;  fi


FROM builder AS armv6-builder

RUN mkdir armv6-rpi-linux-gnueabihf \
 && cd armv6-rpi-linux-gnueabihf \
 && ct-ng armv6-rpi-linux-gnueabi \
 && sed 's/^CT_ARCH_FLOAT_AUTO/# CT_ARCH_FLOAT_AUTO/' -i .config \
 && sed 's/^# CT_ARCH_FLOAT_HW is not set/CT_ARCH_FLOAT_HW=y/' -i .config \
 && sed 's/^CT_ARCH_FLOAT="auto"/CT_ARCH_FLOAT="hard"/' -i .config \
 && echo 'CT_ARCH_ARM_TUPLE_USE_EABIHF=y' >> .config \
 && sed 's/^# CT_CC_GCC_LIBGOMP is not set/CT_CC_GCC_LIBGOMP=y/' -i .config \
 && sed 's/CT_LOG_PROGRESS_BAR/# CT_LOG_PROGRESS_BAR/' -i .config \
 && ct-ng build \
 && cd .. \
 && rm -rf armv6-rpi-linux-gnueabihf

FROM base AS armv6

COPY --from=armv6-builder --chown=idein:idein $HOME/x-tools x-tools
ENV PATH=$HOME/x-tools/armv6-rpi-linux-gnueabihf/bin:$PATH


FROM builder AS armv7-builder

RUN mkdir armv7-rpi2-linux-gnueabihf \
 && cd armv7-rpi2-linux-gnueabihf \
 && ct-ng armv7-rpi2-linux-gnueabihf \
 && sed 's/^# CT_CC_GCC_LIBGOMP is not set/CT_CC_GCC_LIBGOMP=y/' -i .config \
 && sed 's/CT_LOG_PROGRESS_BAR/# CT_LOG_PROGRESS_BAR/' -i .config \
 && ct-ng build \
 && cd .. \
 && rm -rf armv7-rpi2-linux-gnueabihf

FROM base AS armv7

COPY --from=armv7-builder --chown=idein:idein $HOME/x-tools x-tools
ENV PATH=$HOME/x-tools/armv7-rpi2-linux-gnueabihf/bin:$PATH


FROM builder AS armv8-builder

RUN mkdir armv8-rpi3-linux-gnueabihf \
 && cd armv8-rpi3-linux-gnueabihf \
 && ct-ng armv8-rpi3-linux-gnueabihf \
 && sed 's/^# CT_CC_GCC_LIBGOMP is not set/CT_CC_GCC_LIBGOMP=y/' -i .config \
 && sed 's/CT_LOG_PROGRESS_BAR/# CT_LOG_PROGRESS_BAR/' -i .config \
 && ct-ng build \
 && cd .. \
 && rm -rf armv8-rpi3-linux-gnueabihf

FROM base AS armv8

COPY --from=armv8-builder --chown=idein:idein $HOME/x-tools x-tools
ENV PATH=$HOME/x-tools/armv8-rpi3-linux-gnueabihf/bin:$PATH


FROM builder AS aarch64-builder

RUN mkdir aarch64-rpi3-linux-gnuhf \
 && cd aarch64-rpi3-linux-gnuhf \
 && ct-ng aarch64-rpi3-linux-gnu \
 && echo 'CT_ARCH_ARM_TUPLE_USE_EABIHF=y' >> .config \
 && sed 's/^# CT_CC_GCC_LIBGOMP is not set/CT_CC_GCC_LIBGOMP=y/' -i .config \
 && sed 's/CT_LOG_PROGRESS_BAR/# CT_LOG_PROGRESS_BAR/' -i .config \
 && ct-ng build \
 && cd .. \
 && rm -rf aarch64-rpi3-linux-gnuhf

FROM base AS aarch64

COPY --from=aarch64-builder --chown=idein:idein $HOME/x-tools x-tools
ENV PATH=$HOME/x-tools/aarch64-rpi3-linux-gnuhf/bin:$PATH


FROM base

COPY --from=armv6-builder --chown=idein:idein $HOME/x-tools x-tools
COPY --from=armv7-builder --chown=idein:idein $HOME/x-tools x-tools
COPY --from=armv8-builder --chown=idein:idein $HOME/x-tools x-tools
COPY --from=aarch64-builder --chown=idein:idein $HOME/x-tools x-tools
ENV PATH=$HOME/x-tools/armv6-rpi-linux-gnueabihf/bin:$HOME/x-tools/armv7-rpi2-linux-gnueabihf/bin:$HOME/x-tools/armv8-rpi3-linux-gnueabihf/bin:$HOME/x-tools/aarch64-rpi3-linux-gnuhf/bin:$PATH
