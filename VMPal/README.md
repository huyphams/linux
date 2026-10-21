# Linux in VMPal's Linux for containers 1

This is the Linux kernel of Linux for containers 1, the small Linux VM that [VMPal](https://vmpal.com) runs containers
in. VMPal 0.87 to 0.89 download it, from `https://files.vmpal.com/containers/1/vm.aar` (SHA-256
`531a11a136cf94682c898c3614a7dd9f7f854b778359dff12a3b8795e0312016`). That file is an Apple Archive of this kernel,
`Image` (SHA-256 `bf9efb1ba2b095c663d2e9200876c8c85251bc3c8b7d791995b374731e17a16c`), and the VM's root disk,
`root.ext4`.

The source is kernel.org's Linux 7.2.11 (tag `v7.2.11`, `linux-7.2.11.tar.xz`), unmodified. Only the configuration is
VMPal's: `VMPal/config-arm64`, the `.config` that built VMPal's `Image`. The `Image` carries the same file, as
`/proc/config.gz` in the VM. VMPal made it from Apple's Containerization configuration
([apple/containerization](https://github.com/apple/containerization) `kernel/config-arm64`, from its main branch at
the time, whose newest commit then was 2f947e7), brought up to 7.2.11 with `make olddefconfig`. Then VMPal turned these
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

Everything is built in. The kernel has no modules.

## Building

In an Arm64 Linux builder with GCC, make, flex, bison, bc, the OpenSSL and libelf headers, and pahole 1.31 (on
Ubuntu 26.04: `apt-get install build-essential flex bison bc libssl-dev libelf-dev pahole`). VMPal's builder had
pahole 1.31, and `make olddefconfig` records its version in `.config`.

```sh
VMPal/build.sh
```

It copies `VMPal/config-arm64` to `.config`, runs `make olddefconfig`, builds `arch/arm64/boot/Image` and prints its
path. VMPal ships that file as `Image`. VMPal built it on 2026-10-17 in an Ubuntu 26.04 VM, with Ubuntu's gcc
15.2.0-16ubuntu1, GNU ld 2.46 and pahole 1.31. With another compiler, or without pahole 1.31, `make olddefconfig`
changes `.config`, and the script says so. VMPal's `Image` has this version line:

```
Linux version 7.2.11 (root@ubuntu-vm-20) (gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0, GNU ld (GNU Binutils for Ubuntu) 2.46) #4 SMP PREEMPT Sat Oct 17 10:34:14 +07 2026
```

To build the same `Image`, byte for byte, in a fresh clone with pahole 1.31: set `KBUILD_BUILD_USER=root
KBUILD_BUILD_HOST=ubuntu-vm-20`, and leave `KBUILD_BUILD_VERSION` and `KBUILD_BUILD_TIMESTAMP` unset, as VMPal's
build did. Kbuild also writes those two into `init/version.o`, and setting them moves the kernel's read-only data.
The `#4` is Kbuild's own count of builds, which it keeps in `.version`: VMPal's tree was built four times. Two
times come from the clock: the version line's, from `LC_ALL=C date`, and the built-in initramfs's file times, from
`usr/gen_init_cpio` (2026-10-17 03:13:20 UTC, the tree's first build). With `apt-get install faketime`:

```sh
echo 3 >.version
mkdir -p /tmp/vmpal-date
printf '%s\n' '#!/bin/sh' 'if [ $# -eq 0 ]; then echo "Sat Oct 17 10:34:14 +07 2026"; else exec /usr/bin/date "$@"; fi' >/tmp/vmpal-date/date
chmod +x /tmp/vmpal-date/date
KBUILD_BUILD_USER=root KBUILD_BUILD_HOST=ubuntu-vm-20 PATH=/tmp/vmpal-date:$PATH TZ=UTC \
    LD_PRELOAD=/usr/lib/aarch64-linux-gnu/faketime/libfaketime.so.1 FAKETIME='2026-10-17 03:13:20' \
    FAKETIME_ONLY_CMDS=gen_init_cpio VMPal/build.sh
sha256sum arch/arm64/boot/Image
```

The SHA-256 is then `bf9efb1ba2b095c663d2e9200876c8c85251bc3c8b7d791995b374731e17a16c`, VMPal's.

## License

Linux is under the GNU General Public License version 2 (`COPYING`). `LICENSES/` has the licenses that single files
name.

## The rest of Linux for containers

- [huyphams/busybox](https://github.com/huyphams/busybox): BusyBox as Alpine Linux builds it, which the root disk
  has.
- [huyphams/vmpal-linux-for-containers](https://github.com/huyphams/vmpal-linux-for-containers): what each version
  of Linux for containers holds, and the source code of the root disk's other packages under the GPL and other
  copyleft licenses.
