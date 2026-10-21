# linux_patches

Zainium's kernel, built from CachyOS's 7.1 tree.

`linux-evl/` is the recipe:

- source: `CachyOS/linux` tag `cachyos-7.1.8-1` (CachyOS base patches included)
- `0001-bore-cachy.patch`: BORE scheduler, from `CachyOS/kernel-patches` (`7.1/sched`)
- `0002-zainium-system-paths.patch`: firmware, shebang interpreters, init, modprobe, poweroff/reboot and depmod under `/overlayer/syshub`, initramfs init `/quantra-ramfs`
- `0003-zainium-kernel-release.patch`: release name `linux-evl-7.1`, modules installed to `/overlayer/syshub/drivers/modules`
- `zainium.config`: clang ThinLTO, `-O3`, x86-64-v3 (needs an AVX2 CPU), BORE, transparent hugepages, zram with zstd

The package installs the kernel to `/overlayer/syshub/kernel/` and the modules to `/overlayer/syshub/drivers/modules/linux-evl-7.1/`.

CI builds the recipe on every pull request and boots the kernel in QEMU (`-cpu max`) with a test init at `/quantra-ramfs`; a push to `master` attaches the built package to a GitHub Release.

Patches are GPL-2.0, as is the kernel they apply to.
