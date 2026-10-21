# Linux in VMPal's Linux for containers 1

This is the Linux kernel of Linux for containers 1, the small Linux VM that [VMPal](https://vmpal.com) runs containers
in. VMPal 0.87 to 0.89 download it, from `https://files.vmpal.com/containers/1/vm.aar` (SHA-256
`531a11a136cf94682c898c3614a7dd9f7f854b778359dff12a3b8795e0312016`). That file is an Apple Archive of this kernel,
`Image` (SHA-256 `bf9efb1ba2b095c663d2e9200876c8c85251bc3c8b7d791995b374731e17a16c`), and the VM's root disk,
`root.ext4`.

The source is kernel.org's Linux 7.2.11 (tag `v7.2.11`, `linux-7.2.11.tar.xz`), unmodified. Only the configuration is
VMPal's: `VMPal/config-arm64`, the `.config` that built VMPal's `Image`. The `Image` carries the same file, as
`/proc/config.gz` in the VM. VMPal made it from Apple's Containerization configuration
([apple/containerization](https://github.com/apple/containerization) `kernel/config-arm64`, at 2f947e7), brought up
to 7.2.11 with `make olddefconfig`. Then VMPal turned these options on, and ran `make olddefconfig` again:

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

In an Arm64 Linux builder with GCC, make, flex, bison, bc, and the OpenSSL and libelf headers (on Ubuntu:
`apt-get install build-essential flex bison bc libssl-dev libelf-dev`):

```sh
VMPal/build.sh
```

It copies `VMPal/config-arm64` to `.config`, runs `make olddefconfig`, builds `arch/arm64/boot/Image` and prints its
path. VMPal ships that file as `Image`. VMPal built it on 2026-10-17 in an Ubuntu 26.04 VM, with Ubuntu's gcc
15.2.0-16ubuntu1 and GNU ld 2.46. Another compiler works too, but then `make olddefconfig` changes the compiler lines
of `.config`, and the script says so. VMPal's `Image` has this version line:

```
Linux version 7.2.11 (root@ubuntu-vm-20) (gcc (Ubuntu 15.2.0-16ubuntu1) 15.2.0, GNU ld (GNU Binutils for Ubuntu) 2.46) #4 SMP PREEMPT Sat Oct 17 10:34:14 +07 2026
```

To get the same line, run `KBUILD_BUILD_USER=root KBUILD_BUILD_HOST=ubuntu-vm-20 KBUILD_BUILD_VERSION=4
KBUILD_BUILD_TIMESTAMP='Sat Oct 17 10:34:14 +07 2026' VMPal/build.sh`.

## License

Linux is under the GNU General Public License version 2 (`COPYING`). `LICENSES/` has the licenses that single files
name.

## The rest of Linux for containers

- [huyphams/busybox](https://github.com/huyphams/busybox): BusyBox as Alpine Linux builds it, which the root disk
  has.
- [huyphams/vmpal-linux-for-containers](https://github.com/huyphams/vmpal-linux-for-containers): what each version
  of Linux for containers holds, and the source code of the root disk's other packages under the GPL and other
  copyleft licenses.
