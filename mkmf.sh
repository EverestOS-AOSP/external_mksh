# Copyright © 2010, 2012, 2013
#	Thorsten Glaser <tg@mirbsd.org>
# This file is provided under the same terms as mksh.
#-
# Helper script to let src/Build.sh generate Makefrag.inc
# which we in turn use in the manual creation of Android.mk
#
# This script is supposed to be run from/inside AOSP by the
# porter of mksh to Android (and only manually).

if test x"$1" = x"-t"; then
	# test compilation
	args=-r
	mkmfmode=1
else
	# prepare for AOSP
	args=-M
	mkmfmode=0
fi

cd "$(dirname "$0")"
srcdir=$(pwd)
rm -rf tmp
mkdir tmp
cd ../..
aospdir=$(pwd)
cd $srcdir/tmp

addvar() {
	_vn=$1; shift

	eval $_vn=\"\$$_vn '$*"'
}

CFLAGS=
CPPFLAGS=
LDFLAGS=
LIBS=

# The definitions below were generated by examining the
# output of the following command:
# make showcommands out/target/product/generic/system/bin/mksh 2>&1 | tee log
#
# They are only used to let Build.sh find the compiler, header
# files, linker and libraries to generate Makefrag.inc (similar
# to what GNU autotools’ configure scripts do), and never used
# during the real build process. We need this to port mksh to
# the Android platform and it is crucial these are as close as
# possible to the values used later. (You also must example the
# results gathered from Makefrag.inc to see they are the same
# across all Android platforms, or add appropriate ifdefs.)
# Since we no longer use the NDK, the AOSP has to have been
# built before using this script (targetting generic/emulator).

CC=$aospdir/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.7/bin/arm-linux-androideabi-gcc
addvar CPPFLAGS \
    -I$aospdir/libnativehelper/include/nativehelper \
    -isystem $aospdir/system/core/include \
    -isystem $aospdir/hardware/libhardware/include \
    -isystem $aospdir/hardware/libhardware_legacy/include \
    -isystem $aospdir/hardware/ril/include \
    -isystem $aospdir/libnativehelper/include \
    -isystem $aospdir/frameworks/native/include \
    -isystem $aospdir/frameworks/native/opengl/include \
    -isystem $aospdir/frameworks/av/include \
    -isystem $aospdir/frameworks/base/include \
    -isystem $aospdir/external/skia/include \
    -isystem $aospdir/out/target/product/generic/obj/include \
    -isystem $aospdir/bionic/libc/arch-arm/include \
    -isystem $aospdir/bionic/libc/include \
    -isystem $aospdir/bionic/libstdc++/include \
    -isystem $aospdir/bionic/libc/kernel/uapi \
    -isystem $aospdir/bionic/libc/kernel/uapi/asm-arm \
    -isystem $aospdir/bionic/libm/include \
    -isystem $aospdir/bionic/libm/include/arm \
    -isystem $aospdir/bionic/libthread_db/include \
    -D_FORTIFY_SOURCE=2 \
    -include $aospdir/build/core/combo/include/arch/linux-arm/AndroidConfig.h \
    -I$aospdir/build/core/combo/include/arch/linux-arm/ \
    -DANDROID -DNDEBUG -UDEBUG
addvar CFLAGS \
    -fno-exceptions \
    -Wno-multichar \
    -msoft-float \
    -fpic \
    -fPIE \
    -ffunction-sections \
    -fdata-sections \
    -funwind-tables \
    -fstack-protector \
    -Wa,--noexecstack \
    -Werror=format-security \
    -fno-short-enums \
    -march=armv7-a \
    -mfloat-abi=softfp \
    -mfpu=vfpv3-d16 \
    -Wno-unused-but-set-variable \
    -fno-builtin-sin \
    -fno-strict-volatile-bitfields \
    -Wno-psabi \
    -mthumb-interwork \
    -fmessage-length=0 \
    -W \
    -Wall \
    -Wno-unused \
    -Winit-self \
    -Wpointer-arith \
    -Werror=return-type \
    -Werror=non-virtual-dtor \
    -Werror=address \
    -Werror=sequence-point \
    -g \
    -Wstrict-aliasing=2 \
    -fgcse-after-reload \
    -frerun-cse-after-loop \
    -frename-registers \
    -mthumb \
    -Os \
    -fomit-frame-pointer \
    -fno-strict-aliasing
addvar LDFLAGS \
    -nostdlib \
    -Bdynamic \
    -fPIE \
    -pie \
    -Wl,-dynamic-linker,/system/bin/linker \
    -Wl,--gc-sections \
    -Wl,-z,nocopyreloc \
    -Wl,-z,noexecstack \
    -Wl,-z,relro \
    -Wl,-z,now \
    -Wl,--warn-shared-textrel \
    -Wl,--fatal-warnings \
    -Wl,--icf=safe \
    -Wl,--fix-cortex-a8 \
    -Wl,--no-undefined \
    $aospdir/out/target/product/generic/obj/lib/crtbegin_dynamic.o
addvar LIBS \
    -L$aospdir/out/target/product/generic/obj/lib \
    -Wl,-rpath-link=$aospdir/out/target/product/generic/obj/lib \
    -Wl,--no-whole-archive \
    $aospdir/out/target/product/generic/obj/STATIC_LIBRARIES/libcompiler_rt-extras_intermediates/libcompiler_rt-extras.a \
    -lc \
    $aospdir/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.7/bin/../lib/gcc/arm-linux-androideabi/4.7/armv7-a/libgcc.a \
    $aospdir/out/target/product/generic/obj/lib/crtend_android.o


### Flags used by test builds
if test $mkmfmode = 1; then
	addvar CPPFLAGS '-DMKSHRC_PATH=\"/system/etc/mkshrc\"'
	addvar CPPFLAGS '-DMKSH_DEFAULT_EXECSHELL=\"/system/bin/sh\"'
	addvar CPPFLAGS '-DMKSH_DEFAULT_TMPDIR=\"/data/local\"'
fi

### Override flags
# Let the shell free all memory upon exiting
addvar CPPFLAGS -DDEBUG_LEAKS
# UTF-8 works nowadays
addvar CPPFLAGS -DMKSH_ASSUME_UTF8
# Reduce filedescriptor usage
addvar CPPFLAGS -DMKSH_CONSERVATIVE_FDS
# Leave out RCS ID strings from the binary
addvar CPPFLAGS -DMKSH_DONT_EMIT_IDSTRING
# No getpwnam() calls (affects "cd ~username/" only)
addvar CPPFLAGS -DMKSH_NOPWNAM
# Leave out the ulimit builtin
#addvar CPPFLAGS -DMKSH_NO_LIMITS
# Compile an extra small mksh (optional)
#addvar CPPFLAGS -DMKSH_SMALL

# Set target platform
TARGET_OS=Android

# Android-x86 does not have helper functions for ProPolice SSP
# and AOSP adds the flags by itself (same for warning flags)
HAVE_CAN_FNOSTRICTALIASING=0
HAVE_CAN_FSTACKPROTECTORALL=0
HAVE_CAN_WALL=0
export HAVE_CAN_FNOSTRICTALIASING HAVE_CAN_FSTACKPROTECTORALL HAVE_CAN_WALL

# even the idea of persistent history on a phone is funny
HAVE_PERSISTENT_HISTORY=0; export HAVE_PERSISTENT_HISTORY

# ... and run it!
export CC CPPFLAGS CFLAGS LDFLAGS LIBS TARGET_OS
sh ../src/Build.sh $args
rv=$?
test x"$args" = x"-r" && exit $rv
test x0 = x"$rv" && mv -f Makefrag.inc ../
cd ..
rm -rf tmp
exit $rv
