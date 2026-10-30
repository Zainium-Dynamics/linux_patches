#!/bin/sh
# ci/kernel-bump.sh — move the kernel recipe to the newest Linux on kernel.org.
#
# The recipe is the directory whose manifest.toml has `_kernel = true`. A newer
# release of the same series is taken as soon as it is out; a new series (7.4
# after 7.3) only from its first point release (7.4.1), as rolling distributions
# do. Every patch of the recipe must still apply to the new tree, or nothing
# changes and the job fails. On success ZEXBUILD and the manifests carry the new
# version (pkgrel back to 0) and the version is written to $GITHUB_OUTPUT as
# `version`; with nothing newer, `version` is empty.

set -eu

out="${GITHUB_OUTPUT:-/dev/null}"

manifest=$(grep -l '^_kernel *= *true' ./*/manifest.toml | head -n 1)
[ -n "$manifest" ] || { echo "no kernel recipe (a manifest.toml with _kernel = true)" >&2; exit 1; }
recipe=$(dirname "$manifest")
cur=$(sed -n 's/^pkgver=//p' "$recipe/ZEXBUILD")
series() { echo "$1" | cut -d. -f1,2; }
newer() { [ "$1" != "$2" ] && [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -n 1)" = "$2" ]; }

# every linux-<version>.tar.xz in v<major>.x
releases() {
    curl -fsSL "https://cdn.kernel.org/pub/linux/kernel/v$1.x/" 2>/dev/null \
        | grep -o 'linux-[0-9][0-9.]*\.tar\.xz' | sed 's/^linux-//; s/\.tar\.xz$//' | sort -uV
}

major=${cur%%.*}
new=""
for v in $(releases "$major") $(releases $((major + 1))); do
    newer "$cur" "$v" || continue
    # a new series waits for its first point release
    if [ "$(series "$v")" != "$(series "$cur")" ] && [ "$(echo "$v" | tr -cd . | wc -c)" -lt 2 ]; then
        continue
    fi
    if [ -z "$new" ] || newer "$new" "$v"; then
        new=$v
    fi
done

if [ -z "$new" ]; then
    echo "$recipe: Linux $cur is the newest"
    echo "version=" >> "$out"
    exit 0
fi
echo "$recipe: Linux $new is out (the recipe has $cur)"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
tarball="linux-$new.tar.xz"
curl -fsSL -o "$tmp/$tarball" "https://cdn.kernel.org/pub/linux/kernel/v${new%%.*}.x/$tarball"
tar -xJf "$tmp/$tarball" -C "$tmp"

for p in "$recipe"/*.patch; do
    [ -e "$p" ] || continue
    if ! (cd "$tmp/linux-$new" && patch -p1 --dry-run -s) < "$p"; then
        echo "$p does not apply to Linux $new: update the patch by hand" >&2
        exit 1
    fi
    echo "$p applies to Linux $new"
done

sed -i "s/^pkgver=.*/pkgver=$new/; s/^pkgrel=.*/pkgrel=0/" "$recipe/ZEXBUILD"
# a recipe that pins the tarball's sha256 gets the new one
if grep -q '^sha256sums=' "$recipe/ZEXBUILD"; then
    sum=$(sha256sum "$tmp/$tarball" | cut -d' ' -f1)
    sed -i "s/^sha256sums=\"[0-9a-f]*  linux-\$pkgver.tar.xz\"/sha256sums=\"$sum  linux-\$pkgver.tar.xz\"/" "$recipe/ZEXBUILD"
fi
for m in "$recipe"/*manifest.toml; do
    sed -i -E "s/^(version *= *)\"[^\"]*\"/\1\"$new\"/" "$m"
done

echo "version=$new" >> "$out"
echo "package=$(sed -n 's/^pkgname=//p' "$recipe/ZEXBUILD")" >> "$out"
