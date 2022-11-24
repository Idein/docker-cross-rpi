UNAME_M := $(shell uname -m)
# Convert to the architecture name used by docker
ifeq (${UNAME_M}, aarch64)
ARCH := arm64
else ifeq (${UNAME_M}, arm64)
ARCH := arm64
else ifeq (${UNAME_M}, x86_64)
ARCH := amd64
else
$(error unsupported cpu architecture)
endif

all: build-image-local

show-host-arch:
	@echo ${ARCH}

build-worker: docker-worker/Dockerfile
	docker build -t worker docker-worker/

cache/armv6-rpi-linux-gnueabihf_${ARCH}.tar.xz: scripts/build_armv6-rpi-linux-gnueabihf.bash
	mkdir -p cache
	chmod o+w cache/
	docker run -it --rm \
		-v ${PWD}:/work \
		worker \
		/bin/bash -c " \
			cd /tmp/ \
			&& /work/scripts/build_armv6-rpi-linux-gnueabihf.bash \
			&& mv /tmp/armv6-rpi-linux-gnueabihf.tar.xz /work/cache/ \
		"
	mv cache/armv6-rpi-linux-gnueabihf.tar.xz cache/armv6-rpi-linux-gnueabihf_${ARCH}.tar.xz

cache/armv7-rpi2-linux-gnueabihf_${ARCH}.tar.xz: scripts/build_armv7-rpi2-linux-gnueabihf.bash
	mkdir -p cache
	chmod o+w cache/
	docker run -it --rm \
		-v ${PWD}:/work \
		worker \
		/bin/bash -c " \
			cd /tmp/ \
			&& /work/scripts/build_armv7-rpi2-linux-gnueabihf.bash \
			&& mv /tmp/armv7-rpi2-linux-gnueabihf.tar.xz /work/cache/ \
		"
	mv cache/armv7-rpi2-linux-gnueabihf.tar.xz cache/armv7-rpi2-linux-gnueabihf_${ARCH}.tar.xz

cache/armv8-rpi3-linux-gnueabihf_${ARCH}.tar.xz: scripts/build_armv8-rpi3-linux-gnueabihf.bash
	mkdir -p cache
	chmod o+w cache/
	docker run -it --rm \
		-v ${PWD}:/work \
		worker \
		/bin/bash -c " \
			cd /tmp/ \
			&& /work/scripts/build_armv8-rpi3-linux-gnueabihf.bash \
			&& mv /tmp/armv8-rpi3-linux-gnueabihf.tar.xz /work/cache/ \
		"
	mv cache/armv8-rpi3-linux-gnueabihf.tar.xz cache/armv8-rpi3-linux-gnueabihf_${ARCH}.tar.xz

cache/aarch64-rpi3-linux-gnuhf_${ARCH}.tar.xz: scripts/build_aarch64-rpi3-linux-gnuhf.bash
	mkdir -p cache
	chmod o+w cache/
	docker run -it --rm \
		-v ${PWD}:/work \
		worker \
		/bin/bash -c " \
			cd /tmp/ \
			&& /work/scripts/build_aarch64-rpi3-linux-gnuhf.bash \
			&& mv /tmp/aarch64-rpi3-linux-gnuhf.tar.xz /work/cache/ \
		"
	mv cache/aarch64-rpi3-linux-gnuhf.tar.xz cache/aarch64-rpi3-linux-gnuhf_${ARCH}.tar.xz

build-image-local: cache/armv6-rpi-linux-gnueabihf_${ARCH}.tar.xz cache/armv7-rpi2-linux-gnueabihf_${ARCH}.tar.xz cache/armv8-rpi3-linux-gnueabihf_${ARCH}.tar.xz cache/aarch64-rpi3-linux-gnuhf_${ARCH}.tar.xz
	docker buildx build --load --platform linux/${ARCH} --tag idein/cross-rpi:latest .