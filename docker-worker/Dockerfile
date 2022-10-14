FROM debian:buster-slim

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update \
    && apt-get install -y \
    python \
    python-dev \
    locales \
    curl \
    sudo \
    build-essential \
    git \
    autoconf \
    flex \
    texinfo \
    help2man \
    gawk \
    libtool-bin \
    libncurses-dev \
    bison \
    wget \
    unzip \
    xz-utils \
    libmpfr-dev \
    libgmp-dev \
    libmpc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

RUN curl -sLO http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.24.0.tar.xz \
 && tar xJf crosstool-ng-1.24.0.tar.xz \
 && cd crosstool-ng-1.24.0 \
 && sed 's|http://isl.gforge.inria.fr|https://libisl.sourceforge.io|' -i config/versions/isl.in \
 && sed 's|http://downloads.sourceforge.net/project/expat/expat/${CT_EXPAT_VERSION}|https://github.com/libexpat/libexpat/releases/download/R_${CT_EXPAT_VERSION//./_}|' -i config/versions/expat.in \
 && ./configure \
 && make -j \
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
RUN echo "export PATH=$PATH" >> /home/idein/.bashrc
CMD ["/bin/bash"]