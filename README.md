# linux_patches

Zainium's kernel, built from the vanilla 7.3 tree.

`linux-zainium/` is the recipe:

- source: `linux-7.3.1.tar.xz` from kernel.org
- `0001-zainium-system-paths.patch`: firmware, shebang interpreters, init, modprobe, poweroff/reboot and depmod under `/overlayer/syshub`, initramfs init `/quantra-ramfs`
- `0002-zainium-kernel-release.patch`: release name `linux-zainium-7.3`, modules installed to `/overlayer/syshub/drivers/modules`
- `zainium.config`: Zainium's own kernel config (Rust, BTF); the recipe adds x86-64-v3 (needs an AVX2 CPU), `-O3`, transparent hugepages and zstd for zram, and turns off scheduler stats. Built with GCC: with Rust and BTF on, the kernel does not allow LTO.

The package installs the kernel to `/overlayer/syshub/kernel/` and the modules to `/overlayer/syshub/drivers/modules/linux-zainium-7.3/`.

CI builds the recipe on every pull request and boots the kernel in QEMU (`-cpu max`) with a test init at `/quantra-ramfs`; a push to `master` attaches the built package to a GitHub Release.

Patches are GPL-2.0, as is the kernel they apply to.
