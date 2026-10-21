#!/bin/bash
# Builds the kernel of VMPal's Linux for containers 1: this tree with VMPal/config-arm64, into arch/arm64/boot/Image.
# Run it in an Arm64 Linux builder with pahole 1.31. VMPal's was an Ubuntu 26.04 VM, with gcc (Ubuntu
# 15.2.0-16ubuntu1) 15.2.0, GNU ld (GNU Binutils for Ubuntu) 2.46 and pahole 1.31. For VMPal's Image byte for byte,
# see VMPal/README.md: KBUILD_BUILD_USER=root KBUILD_BUILD_HOST=ubuntu-vm-20, without KBUILD_BUILD_VERSION or
# KBUILD_BUILD_TIMESTAMP.
# Usage: VMPal/build.sh
set -e
cd "$(dirname "$0")/.."
[ "$(uname -m)" = aarch64 ] || { echo "Run this in an Arm64 Linux builder"; exit 1; }
cp VMPal/config-arm64 .config
make olddefconfig
cmp -s .config VMPal/config-arm64 || echo "make olddefconfig changed .config (another compiler, or pahole?): diff VMPal/config-arm64 .config"
# An empty LOCALVERSION: built from git, the kernel calls itself 7.2.11, as it does from kernel.org's tarball, not 7.2.11+.
make -j"$(nproc)" LOCALVERSION= Image
echo "$PWD/arch/arm64/boot/Image"
