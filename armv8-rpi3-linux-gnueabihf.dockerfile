FROM idein/cross-rpi:builder AS builder
RUN mkdir armv8-rpi3-linux-gnueabihf \
 && cd armv8-rpi3-linux-gnueabihf \
 && ct-ng armv8-rpi3-linux-gnueabihf \
 && sed 's/^# CT_CC_GCC_LIBGOMP is not set/CT_CC_GCC_LIBGOMP=y/' -i .config \
 && sed 's/CT_LOG_PROGRESS_BAR/# CT_LOG_PROGRESS_BAR/' -i .config \
 && ct-ng build \
 && cd .. \
 && mv armv8-rpi3-linux-gnueabihf waste \
 && rm -rf waste

FROM idein/cross-rpi:base
COPY --from=builder /home/idein/x-tools /home/idein/x-tools
ENV PATH $HOME/x-tools/armv8-rpi3-linux-gnueabihf/bin:$PATH
