Zainium OS kernel
=================

This repository builds the Linux kernel of Zainium OS from the vanilla
sources on kernel.org, with Zainium's paths and configuration. The recipe
in linux-kernel/ makes three packages from one tree:

    linux-kernel           the kernel (linux-zainium) and its fallback copy
                           (linux-panic), installed on the EFI partition
    linux-kernel-modules   the modules, in /overlayer/syshub/drivers/modules
    linux-headers          the userspace API headers, for the userland

The kernel's name is set once, as _kernel in the recipe. Its release is
that name and the series, for example linux-zainium-7.3, so the module
directory stays the same across point releases.

What the recipe changes
-----------------------

    0001-zainium-system-paths.patch   firmware, script interpreters, init,
                                      modprobe, reboot and depmod under
                                      /overlayer/syshub
    0002-zainium-module-dir.patch     modules in /overlayer/syshub/drivers/modules
    zainium.config                    Zainium's kernel configuration (Rust, BTF)

The build adds x86-64-v3 (an AVX2 CPU is needed), -O3, transparent
hugepages and zstd for zram.

Building and testing
--------------------

CI builds every pull request and boots the kernel in QEMU with a test
init. A push to master is built, tested and published; installed systems
get it with "elevate zex kernel --u".

Staying current
---------------

Every Thursday at 10:00 Pakistan time, kernel-bump.yml checks kernel.org.
A newer release of the same series is taken at once, a new series from
its first point release. If every patch still applies, the recipe is
bumped on master ("linux-kernel: bump to <version>") and CI builds it. If
a patch no longer applies, the job fails and the patch is updated by hand.
It can also be started from the Actions tab.

License
-------

The patches are GPL-2.0, like the kernel.
