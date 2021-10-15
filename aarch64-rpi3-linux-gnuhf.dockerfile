FROM idein/cross-rpi:builder AS builder
RUN mkdir aarch64-rpi3-linux-gnuhf \
 && cd aarch64-rpi3-linux-gnuhf \
 && ct-ng aarch64-rpi3-linux-gnu \
 && echo 'CT_ARCH_ARM_TUPLE_USE_EABIHF=y' >> .config \
 && sed 's/^# CT_CC_GCC_LIBGOMP is not set/CT_CC_GCC_LIBGOMP=y/' -i .config \
 && sed 's/CT_LOG_PROGRESS_BAR/# CT_LOG_PROGRESS_BAR/' -i .config \
 && ct-ng build \
 && cd .. \
 && mv aarch64-rpi3-linux-gnuhf waste \
 && rm -rf waste

FROM idein/cross-rpi:base
COPY --from=builder /home/idein/x-tools /home/idein/x-tools
ENV PATH $HOME/x-tools/aarch64-rpi3-linux-gnuhf/bin:$PATH
