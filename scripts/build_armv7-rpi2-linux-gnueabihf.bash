#!/bin/bash -ue

: ${WORKSPACE:=/tmp}

mkdir armv7-rpi2-linux-gnueabihf
cd armv7-rpi2-linux-gnueabihf
ct-ng armv7-rpi2-linux-gnueabihf
sed 's/^# CT_CC_GCC_LIBGOMP is not set/CT_CC_GCC_LIBGOMP=y/' -i .config
sed 's/CT_LOG_PROGRESS_BAR/# CT_LOG_PROGRESS_BAR/' -i .config

CT_PREFIX="${WORKSPACE}/x-tools" ct-ng build -j

cd ${WORKSPACE}/x-tools
XZ_OPT="-T0" tar Jcf ../armv7-rpi2-linux-gnueabihf.tar.xz .