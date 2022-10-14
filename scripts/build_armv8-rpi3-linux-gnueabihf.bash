#!/bin/bash -ue

: ${WORKSPACE:=/tmp}

mkdir armv8-rpi3-linux-gnueabihf
cd armv8-rpi3-linux-gnueabihf
ct-ng armv8-rpi3-linux-gnueabihf
sed 's/^# CT_CC_GCC_LIBGOMP is not set/CT_CC_GCC_LIBGOMP=y/' -i .config
sed 's/CT_LOG_PROGRESS_BAR/# CT_LOG_PROGRESS_BAR/' -i .config

CT_PREFIX="${WORKSPACE}/x-tools" ct-ng build -j

cd ${WORKSPACE}/x-tools
XZ_OPT="-T0" tar Jcf ../armv8-rpi3-linux-gnueabihf.tar.xz .