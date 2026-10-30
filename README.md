# linux_patches

Zainium's kernel, built from the vanilla 7.3 tree.

`linux-kernel/` is the recipe. It builds three packages from one tree: `linux-kernel` (the kernel tier: the image `linux-zainium` and its fallback copy `linux-panic`), `linux-kernel-modules` (the base) and `linux-headers` (the userland's include). The kernel's name is set once, as `_kernel` in the recipe; the release is that name plus the major and minor version (`linux-zainium-7.3`), given to `make` as `KERNELRELEASE`.

- source: `linux-7.3.1.tar.xz` from kernel.org
- `0001-zainium-system-paths.patch`: firmware, shebang interpreters, init, modprobe, poweroff/reboot and depmod under `/overlayer/syshub`, initramfs init `/quantra-ramfs`
- `0002-zainium-module-dir.patch`: modules installed to `/overlayer/syshub/drivers/modules`
- `zainium.config`: Zainium's own kernel config (Rust, BTF); the recipe adds x86-64-v3 (needs an AVX2 CPU), `-O3`, transparent hugepages and zstd for zram, and turns off scheduler stats. Built with GCC: with Rust and BTF on, the kernel does not allow LTO.

The kernel goes to `/overlayer/zaisys/kernel/` and, through `zex kernel`, to the ESP; the modules go to `/overlayer/syshub/drivers/modules/<release>/`.

CI builds the recipe on every pull request and boots the kernel in QEMU (`-cpu max`) with a test init at `/quantra-ramfs`; a push to `master` attaches the built package to a GitHub Release.

## Kept current every week

Every Thursday at 10:00 Pakistan time, `kernel-bump.yml` looks at kernel.org (`ci/kernel-bump.sh`):

- a newer release of the same series is taken as soon as it is out; a new series (7.4 after 7.3) from its first point release (7.4.1);
- every patch of the recipe must still apply to the new tree, or nothing changes and the job fails so the patch can be updated by hand;
- the recipe and its manifests get the new version, the commit `linux-kernel: bump to <version>` goes to `master`, and CI builds, boot-tests and publishes it.

It can also be started by hand from the Actions tab.

Patches are GPL-2.0, as is the kernel they apply to.
