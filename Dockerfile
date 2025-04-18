FROM debian:bookworm-slim

ARG TARGET_TRIPLET

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
 && apt-get upgrade -y \
 && apt-get install -y --no-install-recommends dpkg-dev \
 && apt-get install -y --no-install-recommends \
      sudo crossbuild-essential-$(dpkg-architecture -t $TARGET_TRIPLET -qDEB_HOST_ARCH)

# add idein user
RUN useradd -m idein \
 && echo idein:idein | chpasswd

# sudo setting
RUN adduser idein sudo \
 && echo 'idein ALL=NOPASSWD: ALL' >> /etc/sudoers.d/idein

USER idein
WORKDIR /home/idein
ENV HOME=/home/idein

ENV TARGET_TRIPLET=$TARGET_TRIPLET

CMD ["/bin/bash"]


# Image metadata labels
# ------------------------------------
ARG IMAGE_VERSION
ARG IMAGE_VCS_REV
ARG IMAGE_BUILT_AT

LABEL org.opencontainers.image.authors="Idein Inc."
LABEL org.opencontainers.image.documentation="crossbuild-essential for ${TARGET_TRIPLET}"
LABEL org.opencontainers.image.url="https://github.com/Idein/docker-cross-rpi/tree/crossbuild-essential"
LABEL org.opencontainers.image.source="https://raw.githubusercontent.com/Idein/docker-cross-rpi/${IMAGE_VCS_REV}/Dockerfile"
LABEL org.opencontainers.image.version="${IMAGE_VERSION}"
LABEL org.opencontainers.image.revision="${IMAGE_VCS_REV}"
LABEL org.opencontainers.image.created="${IMAGE_BUILT_AT}"
