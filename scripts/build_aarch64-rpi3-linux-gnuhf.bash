#!/bin/bash -ue

: ${WORKSPACE:=/tmp}

mkdir aarch64-rpi3-linux-gnuhf
cd aarch64-rpi3-linux-gnuhf
ct-ng aarch64-rpi3-linux-gnu
echo 'CT_ARCH_ARM_TUPLE_USE_EABIHF=y' >> .config
sed 's/^# CT_CC_GCC_LIBGOMP is not set/CT_CC_GCC_LIBGOMP=y/' -i .config
sed 's/CT_LOG_PROGRESS_BAR/# CT_LOG_PROGRESS_BAR/' -i .config

CT_PREFIX="${WORKSPACE}/x-tools" ct-ng build -j

cd ${WORKSPACE}/x-tools
XZ_OPT="-T0" tar Jcf ../aarch64-rpi3-linux-gnuhf.tar.xz .