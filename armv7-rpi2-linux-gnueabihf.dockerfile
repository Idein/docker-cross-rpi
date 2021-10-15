FROM idein/cross-rpi:builder AS builder
RUN mkdir armv7-rpi2-linux-gnueabihf \
 && cd armv7-rpi2-linux-gnueabihf \
 && ct-ng armv7-rpi2-linux-gnueabihf \
 && sed 's/^# CT_CC_GCC_LIBGOMP is not set/CT_CC_GCC_LIBGOMP=y/' -i .config \
 && sed 's/CT_LOG_PROGRESS_BAR/# CT_LOG_PROGRESS_BAR/' -i .config \
 && ct-ng build \
 && cd .. \
 && mv armv7-rpi2-linux-gnueabihf waste \
 && rm -rf waste

FROM idein/cross-rpi:base
COPY --from=builder /home/idein/x-tools /home/idein/x-tools
ENV PATH $HOME/x-tools/armv7-rpi2-linux-gnueabihf/bin:$PATH
