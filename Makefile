TARGET_IMAGES := \
armv6-rpi-linux-gnueabihf.buildlog \
armv7-rpi2-linux-gnueabihf.buildlog \
armv8-rpi3-linux-gnueabihf.buildlog \
aarch64-rpi3-linux-gnuhf.buildlog


all: $(TARGET_IMAGES)

.SUFFIXES: .dockerfile .buildlog
.dockerfile.buildlog:
	docker build --progress=plain --tag idein/cross-rpi:$* --file $< . 2>&1 | tee $@.tmp
	mv $@.tmp $@

armv6-rpi-linux-gnueabihf.buildlog: builder.buildlog base.buildlog 
armv7-rpi2-linux-gnueabihf.buildlog: builder.buildlog base.buildlog
armv8-rpi3-linux-gnueabihf.buildlog: builder.buildlog base.buildlog
aarch64-rpi3-linux-gnuhf.buildlog: builder.buildlog base.buildlog

clean:
	-rm builder.buildlog base.buildlog $(TARGET_IMAGES)
clean-images: clean
	-docker rmi idein/cross-rpi:builder idein/cross-rpi:base $(TARGET_IMAGES:%.buildlog=idein/cross-rpi:%)
