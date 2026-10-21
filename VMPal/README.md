# Linux in VMPal's Linux for containers 2

This is the Linux kernel of Linux for containers 2, the small Linux VM that [VMPal](https://vmpal.com) runs containers
in. VMPal 0.90 is the first version that downloads it, from `https://files.vmpal.com/containers/2/vm.aar` (SHA-256
`53095b4af9b60a76d9d7a10e7a98fa29a6756b5b0d3d66a0f35d729a169bf964`). That file is an Apple Archive of this kernel,
`Image` (SHA-256 `3904222444b7e2444261b03177be45f984ba21d5afe34d50bea6c7a65f3fb5ad`), and the VM's root disk,
`root.ext4`.

The source is kernel.org's Linux 7.3 (tag `v7.3`, `linux-7.3.tar.xz`), unmodified. Only the configuration is VMPal's:
`VMPal/config-arm64`, the `.config` that built VMPal's `Image`. The `Image` carries the same file, as
`/proc/config.gz` in the VM. VMPal made it from Apple's Containerization configuration
([apple/containerization](https://github.com/apple/containerization) `kernel/config-arm64`, from its main branch at
the time, whose newest commit then was 2f947e7), brought up to 7.3 with `make olddefconfig`. Then VMPal turned these
options on, and ran `make olddefconfig` again:

- iptables for Docker, which on 7.x needs the legacy xtables: `NETFILTER_XTABLES_LEGACY`, `IP_NF_IPTABLES_LEGACY`,
  `IP6_NF_IPTABLES_LEGACY`, `IP_NF_IPTABLES`, `IP_NF_FILTER`, `IP_NF_MANGLE`, `IP_NF_NAT`, `IP_NF_TARGET_MASQUERADE`,
  `IP_NF_RAW`, `IP_NF_TARGET_REDIRECT`, `IP6_NF_IPTABLES`, `IP6_NF_FILTER`, `IP6_NF_MANGLE`, `IP6_NF_NAT`,
  `IP6_NF_TARGET_MASQUERADE`, `IP6_NF_RAW`
- nftables and xtables: `NF_TABLES_INET`, `NF_TABLES_IPV4`, `NF_TABLES_IPV6`, `NFT_COMPAT`, `NFT_NAT`, `NFT_MASQ`,
  `NFT_CT`, `NFT_REDIR`, `NETFILTER_XT_MATCH_ADDRTYPE`, `NETFILTER_XT_MATCH_CONNTRACK`,
  `NETFILTER_XT_TARGET_MASQUERADE`, `NETFILTER_XT_NAT`, `NETFILTER_XT_MARK`
- Bridges: `BRIDGE_NETFILTER`, `BRIDGE_VLAN_FILTERING`
- Memory: `LRU_GEN`, `LRU_GEN_ENABLED`, `VIRTIO_BALLOON`, `PAGE_REPORTING`
- Hardening: `BPF_UNPRIV_DEFAULT_OFF`, `HARDENED_USERCOPY`

Everything is built in. The kernel has no modules.

## Building

In an Arm64 Linux builder with GCC, make, flex, bison, bc, and the OpenSSL and libelf headers (on Ubuntu:
`apt-get install build-essential flex bison bc libssl-dev libelf-dev`), without pahole: VMPal's builder didn't
have it, and `make olddefconfig` records its version in `.config`.

```sh
VMPal/build.sh
```

It copies `VMPal/config-arm64` to `.config`, runs `make olddefconfig`, builds `arch/arm64/boot/Image` and prints its
path. VMPal ships that file as `Image`. VMPal built it on 2026-10-20 in an `ubuntu:26.04` container, with Ubuntu's
gcc 15.2.0-16ubuntu1 and GNU ld 2.46. With another compiler, or with pahole, `make olddefconfig` changes `.config`,
and the script says so. VMPal's `Image` has this version line:

```
Linux version 7.3.0 (root@f94f0356354b) (gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0, GNU ld (GNU Binutils for Ubuntu) 2.46) #1 SMP PREEMPT Tue Oct 20 19:37:17 UTC 2026
```

To build the same `Image`, byte for byte, in a fresh clone with no `pahole` installed: set `KBUILD_BUILD_USER=root
KBUILD_BUILD_HOST=f94f0356354b`, and leave `KBUILD_BUILD_VERSION` and `KBUILD_BUILD_TIMESTAMP` unset, as VMPal's
build did. Kbuild also writes those two into `init/version.o`, and setting them moves the kernel's read-only data.
Two times come from the clock: the version line's, from `LC_ALL=C date`, and the built-in initramfs's file times,
from `usr/gen_init_cpio` (2026-10-20 19:34:55 UTC). With `apt-get install faketime`:

```sh
mkdir -p /tmp/vmpal-date
printf '%s\n' '#!/bin/sh' 'if [ $# -eq 0 ]; then echo "Tue Oct 20 19:37:17 UTC 2026"; else exec /usr/bin/date "$@"; fi' >/tmp/vmpal-date/date
chmod +x /tmp/vmpal-date/date
KBUILD_BUILD_USER=root KBUILD_BUILD_HOST=f94f0356354b PATH=/tmp/vmpal-date:$PATH TZ=UTC \
    LD_PRELOAD=/usr/lib/aarch64-linux-gnu/faketime/libfaketime.so.1 FAKETIME='2026-10-20 19:34:55' \
    FAKETIME_ONLY_CMDS=gen_init_cpio VMPal/build.sh
sha256sum arch/arm64/boot/Image
```

The SHA-256 is then `3904222444b7e2444261b03177be45f984ba21d5afe34d50bea6c7a65f3fb5ad`, VMPal's.

## License

Linux is under the GNU General Public License version 2 (`COPYING`). `LICENSES/` has the licenses that single files
name.

## The rest of Linux for containers

- [huyphams/busybox](https://github.com/huyphams/busybox): BusyBox as Alpine Linux builds it, which the root disk
  has.
- [huyphams/vmpal-linux-for-containers](https://github.com/huyphams/vmpal-linux-for-containers): what each version
  of Linux for containers holds, and the source code of the root disk's other packages under the GPL and other
  copyleft licenses.
