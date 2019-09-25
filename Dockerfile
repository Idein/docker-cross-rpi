FROM debian:buster-slim as builder

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

RUN curl -sLO http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.24.0.tar.xz \
 && tar xJf crosstool-ng-1.24.0.tar.xz \
 && cd crosstool-ng-1.24.0 \
 && ./configure \
 && make \
 && make install \
 && cd .. \
 && rm -rf crosstool-ng-1.24.0 crosstool-ng-1.24.0.tar.xz

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

# Shorten the name of a temporary directory before removing it for Docker under
# some configurations so that it can remove deeply-nested directory.
# See https://github.com/moby/moby/issues/13451

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
 && mv armv6-rpi-linux-gnueabihf waste \
 && rm -rf waste
RUN sudo rm x-tools/armv6-rpi-linux-gnueabihf/armv6-rpi-linux-gnueabihf/sysroot/usr/lib/locale/locale-archive

# RUN mkdir armv7-rpi2-linux-gnueabihf \
#  && cd armv7-rpi2-linux-gnueabihf \
#  && ct-ng armv7-rpi2-linux-gnueabihf \
#  && sed 's/^# CT_CC_GCC_LIBGOMP is not set/CT_CC_GCC_LIBGOMP=y/' -i .config \
#  && sed 's/CT_LOG_PROGRESS_BAR/# CT_LOG_PROGRESS_BAR/' -i .config \
#  && ct-ng build \
#  && cd .. \
#  && mv armv7-rpi2-linux-gnueabihf waste \
#  && rm -rf waste

# RUN mkdir armv8-rpi3-linux-gnueabihf \
#  && cd armv8-rpi3-linux-gnueabihf \
#  && ct-ng armv8-rpi3-linux-gnueabihf \
#  && sed 's/^# CT_CC_GCC_LIBGOMP is not set/CT_CC_GCC_LIBGOMP=y/' -i .config \
#  && sed 's/CT_LOG_PROGRESS_BAR/# CT_LOG_PROGRESS_BAR/' -i .config \
#  && ct-ng build \
#  && cd .. \
#  && mv armv8-rpi3-linux-gnueabihf waste \
#  && rm -rf waste

# RUN mkdir aarch64-rpi3-linux-gnuhf \
#  && cd aarch64-rpi3-linux-gnuhf \
#  && ct-ng aarch64-rpi3-linux-gnu \
#  && echo 'CT_ARCH_ARM_TUPLE_USE_EABIHF=y' >> .config \
#  && sed 's/^# CT_CC_GCC_LIBGOMP is not set/CT_CC_GCC_LIBGOMP=y/' -i .config \
#  && sed 's/CT_LOG_PROGRESS_BAR/# CT_LOG_PROGRESS_BAR/' -i .config \
#  && ct-ng build \
#  && cd .. \
#  && mv aarch64-rpi3-linux-gnuhf waste \
#  && rm -rf waste


FROM debian:buster-slim
LABEL maintainer "notogawa <n.ohkawa@idein.jp>"

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends sudo wget locales \
 && apt-get clean \
 && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

WORKDIR /tmp

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

COPY --from=builder /home/idein/x-tools /home/idein/x-tools
ENV PATH $HOME/x-tools/armv6-rpi-linux-gnueabihf/bin:$PATH
# ENV PATH $HOME/x-tools/armv7-rpi2-linux-gnueabihf/bin:$PATH
# ENV PATH $HOME/x-tools/armv8-rpi3-linux-gnueabihf/bin:$PATH
# ENV PATH $HOME/x-tools/aarch64-rpi3-linux-gnuhf/bin:$PATH

ADD script script
RUN script/install_rpi_firmware
RUN sudo rm -rf script

CMD ["/bin/bash"]
