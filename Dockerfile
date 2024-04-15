FROM --platform=arm64 ubuntu:22.04

ARG TOOLS_PATH=/opt/gcc-arm-none-eabi
ARG ARM_VERSION=13.2.rel1
ENV ARM_ARCH=aarch64

USER root
WORKDIR /home/app
COPY . .
RUN apt-get update
RUN apt-get -y install curl gnupg g++ gcc make cmake build-essential ninja-build python3 python-is-python3 gcc-arm-linux-gnueabihf  libc6-dev-armhf-cross qemu-user-static qemu-system-i386  qemu-system-arm qemu-system-mips qemu-efi-aarch64 qemu-kvm gnupg2 stlink-tools xz-utils curl

# Get ARM Toolchain
RUN echo "Downloading ARM GNU GCC for Platform" \
	&& mkdir ${TOOLS_PATH} \
	&& curl -Lo gcc-arm-none-eabi.tar.xz "https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_VERSION}/binrel/arm-gnu-toolchain-${ARM_VERSION}-${ARM_ARCH}-arm-none-eabi.tar.xz" \
	&& tar xf gcc-arm-none-eabi.tar.xz --strip-components=1 -C ${TOOLS_PATH} \
	&& rm gcc-arm-none-eabi.tar.xz \
	&& rm ${TOOLS_PATH}/*.txt \
	&& rm -rf ${TOOLS_PATH}/share/doc \
	&& echo "https://developer.arm.com/-/media/Files/downloads/gnu/${ARM_VERSION}/binrel/arm-gnu-toolchain-${ARM_VERSION}-${ARM_ARCH}-arm-none-eabi.tar.xz"


RUN apt-get install -y \
apparmor \
automake \
bash-completion \
build-essential \
cmake \
curl \
g++ \
gcc \
git \
iptables \
jq \
libapparmor-dev \
libc6-dev \
libcap-dev \
libsystemd-dev \
libyaml-dev \
mercurial \
net-tools \
parallel \
pkg-config \
golang-go \
iproute2 \
iputils-ping \
vim-common \
vim \
wget \
curl \
--no-install-recommends \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*


# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install Mantatory tools (curl git python3) and optional tools (vim sudo)
RUN apt-get update && \
    apt-get install -y curl git lsb-release python3 git file vim sudo && \
    rm -rf /var/lib/apt/lists/*

# Configure git for safe.directory
RUN git config --global --add safe.directory /depot_tools

RUN curl -sL https://deb.nodesource.com/setup_20.x  | bash -
RUN apt-get -y install nodejs

RUN node -p "process.arch"

RUN mkdir /app

ENV SKIP_DOWNLOAD=true

RUN npm install

RUN TARGET_ARCH=arm64 npm run build

CMD ["sleep","3600"]
