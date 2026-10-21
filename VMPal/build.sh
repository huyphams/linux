#!/bin/bash
# Builds the kernel of VMPal's Linux for containers 2: this tree with VMPal/config-arm64, into arch/arm64/boot/Image.
# Run it in an Arm64 Linux builder. VMPal's was an ubuntu:26.04 container, with gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0
# and GNU ld (GNU Binutils for Ubuntu) 2.46. For the version line VMPal's Image has, set KBUILD_BUILD_USER=root
# KBUILD_BUILD_HOST=f94f0356354b KBUILD_BUILD_VERSION=1 KBUILD_BUILD_TIMESTAMP='Tue Oct 20 19:37:17 UTC 2026'.
# Usage: VMPal/build.sh
set -e
cd "$(dirname "$0")/.."
[ "$(uname -m)" = aarch64 ] || { echo "Run this in an Arm64 Linux builder"; exit 1; }
cp VMPal/config-arm64 .config
make olddefconfig
cmp -s .config VMPal/config-arm64 || echo "make olddefconfig changed .config (another compiler?): diff VMPal/config-arm64 .config"
# An empty LOCALVERSION: built from git, the kernel calls itself 7.3.0, as it does from kernel.org's tarball, not 7.3.0+.
make -j"$(nproc)" LOCALVERSION= Image
echo "$PWD/arch/arm64/boot/Image"
