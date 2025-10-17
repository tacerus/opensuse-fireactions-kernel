#!/bin/sh -Cefux

GIT_LINUX=/mnt/extssd/git/linux
GIT_LINUX_PATCHES=~/Work/git/kernel-source
LINUX_BUILD=/mnt/extssd/build/linux
OUT=/mnt/extssd/tmp/

test -f config

install -dv "$LINUX_BUILD"

pushd "$GIT_LINUX"

git clean -df
git restore .

"$GIT_LINUX_PATCHES"/rpm/apply-patches "$GIT_LINUX_PATCHES"/series.conf "$GIT_LINUX_PATCHES"

popd

install -vm0644 config "$LINUX_BUILD"/.config
CCACHE_DIR=/mnt/extssd/ccache/cache CCACHE_TEMPDIR=/mnt/extssd/ccache/temp \
  KBUILD_BUILD_TIMESTAMP='' \
  make -C"$GIT_LINUX" -j"$(( $(nproc) + 4 ))" CC='ccache cc' O="$LINUX_BUILD"

"$GIT_LINUX"/scripts/extract-vmlinux arch/x86/boot/bzImage > "$OUT"/vmlinux

file "$OUT"/vmlinux
