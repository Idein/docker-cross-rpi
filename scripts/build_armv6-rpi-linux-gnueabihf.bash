#!/bin/bash -ue

: ${WORKSPACE:=/tmp}

mkdir armv6-rpi-linux-gnueabihf
cd armv6-rpi-linux-gnueabihf
ct-ng armv6-rpi-linux-gnueabi
sed 's/^CT_ARCH_FLOAT_AUTO/# CT_ARCH_FLOAT_AUTO/' -i .config
sed 's/^# CT_ARCH_FLOAT_HW is not set/CT_ARCH_FLOAT_HW=y/' -i .config
sed 's/^CT_ARCH_FLOAT="auto"/CT_ARCH_FLOAT="hard"/' -i .config
echo 'CT_ARCH_ARM_TUPLE_USE_EABIHF=y' >> .config
sed 's/^# CT_CC_GCC_LIBGOMP is not set/CT_CC_GCC_LIBGOMP=y/' -i .config
sed 's/CT_LOG_PROGRESS_BAR/# CT_LOG_PROGRESS_BAR/' -i .config

CT_PREFIX="${WORKSPACE}/x-tools" ct-ng build -j

cd ${WORKSPACE}/x-tools
XZ_OPT="-T0" tar Jcf ../armv6-rpi-linux-gnueabihf.tar.xz .