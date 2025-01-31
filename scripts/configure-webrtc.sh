#!/bin/bash

set -e

set -v

export PATH=$DEPOT_TOOLS:$PATH

cd ${SOURCE_DIR}

case "$(uname -s)" in
  Linux*)
    if [ "$TARGET_ARCH" == "arm" ]; then
      python build/linux/sysroot_scripts/install-sysroot.py --arch=arm
    # regarding this it shouldn't be needed https://github.com/WonderInventions/node-webrtc/issues/3#issuecomment-1964599401
    elif [ "$TARGET_ARCH" == "arm64" ]; then
      python build/linux/sysroot_scripts/install-sysroot.py --arch=arm64
    else
      python build/linux/sysroot_scripts/install-sysroot.py --arch=amd64
    fi
esac

# NOTE(mroberts): Running hooks generates this file, but running hooks also
# takes too long in CI; so do this manually.
(cd build/util && python lastchange.py -o LASTCHANGE)

gn gen ${BINARY_DIR} "--args=${GN_GEN_ARGS}"
