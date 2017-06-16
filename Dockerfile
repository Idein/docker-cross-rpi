FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends \
      sudo git wget curl gcc g++ autoconf automake libtool build-essential \
      gperf bison flex texinfo bzip2 xz-utils help2man gawk \
      make libncurses5-dev python python-dev python3 \
      python3-dev htop apt-utils locales ca-certificates \
 && apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

WORKDIR /tmp
RUN curl -sLO http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.23.0.tar.xz \
 && tar xvJf crosstool-ng-1.23.0.tar.xz \
 && cd crosstool-ng-1.23.0 \
 && ./configure \
 && make \
 && make install \
 && cd .. \
 && rm -rf crosstool-ng-1.23.0 crosstool-ng-1.23.0.tar.xz

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

RUN mkdir armv6-rpi-linux-gnueabi \
 && cd armv6-rpi-linux-gnueabi \
 && ct-ng armv6-rpi-linux-gnueabi \
 && ct-ng build \
 && cd .. \
 && rm -rf armv6-rpi-linux-gnueabi
ENV PATH $HOME/x-tools/armv6-rpi-linux-gnueabi/bin:$PATH

RUN mkdir armv7-rpi2-linux-gnueabihf \
 && cd armv7-rpi2-linux-gnueabihf \
 && ct-ng armv7-rpi2-linux-gnueabihf \
 && ct-ng build \
 && cd .. \
 && rm -rf armv7-rpi2-linux-gnueabihf
ENV PATH $HOME/x-tools/armv7-rpi2-linux-gnueabihf/bin:$PATH

RUN mkdir armv8-rpi3-linux-gnueabihf \
 && cd armv8-rpi3-linux-gnueabihf \
 && ct-ng armv8-rpi3-linux-gnueabihf \
 && ct-ng build \
 && cd .. \
 && rm -rf armv8-rpi3-linux-gnueabihf
ENV PATH $HOME/x-tools/armv8-rpi3-linux-gnueabihf/bin:$PATH
