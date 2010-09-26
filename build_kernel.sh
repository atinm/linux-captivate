#!/bin/sh
set -e
[ -z "$BUILD_CONFIG" ] && BUILD_CONFIG="./.build_config"
source "$BUILD_CONFIG" 
[ -z "$AOSP" ] && AOSP="/data/android/aosp"
[ -z "$CROSS_COMPILE" ] && CROSS_COMPILE="${HOME}/arm-none-eabi-4.3.4/bin/arm-none-eabi-"
[ -z "$MKZIP" ] && MKZIP='7z -mx9 -mmt=1 a "$OUTFILE" .'
[ -z "$TARGET" ] && TARGET="i897"
[ -z "$CLEAN" ] && CLEAN=y
[ -z "$CCACHE" ] && CCACHE="ccache"
[ -z "$DEFCONFIG" ] && DEFCONFIG=y
[ -z "$PRODUCE_TAR" ] && PRODUCE_TAR=y
[ -z "$PRODUCE_ZIP" ] && PRODUCE_ZIP=y
[ -z "$CCACHE_COMPRESS" ] && CCACHE_COMPRESS=1
[ -z "$VERSION" ] && VERSION="testing"
[ -z "$KBUILD_BUILD_VERSION" ] && KBUILD_BUILD_VERSION="Voodoo3.0-$TARGET-$VERSION"
export CCACHE_DIR
export CCACHE_COMPRESS
export KBUILD_BUILD_VERSION

echo "============================================"
echo "Building Captivate kernel with:"
echo "AOSP = $AOSP"
echo "CROSS_COMPILE = $CROSS_COMPILE"
echo "MKZIP = $MKZIP"
echo "TARGET = $TARGET"
echo "CLEAN = $CLEAN"
echo "CCACHE = $CCACHE"
echo "DEFCONFIG = $DEFCONFIG"
echo "PRODUCE_TAR = $PRODUCE_TAR"
echo "PRODUCE_ZIP = $PRODUCE_ZIP"
echo "CCACHE_COMPRESS = $CCACHE_COMPRESS"
echo "KBUILD_BUILD_VERSION = $KBUILD_BUILD_VERSION"
echo "============================================="

if [ "$CLEAN" = "y" ] ; then
	echo "Cleaning source directory."
	make ARCH=arm clean >/dev/null 2>&1
fi
if [ "$DEFCONFIG" = "y" -o ! -f ".config" ] ; then
	echo "Using default configuration for $TARGET"
	make ARCH=arm ${TARGET}_defconfig >/dev/null 2>&1
fi
if [ "$CCACHE" ] && ccache -h &>/dev/null ; then
	echo "Using ccache to speed up compilation."
	CROSS_COMPILE="$CCACHE $CROSS_COMPILE"
fi

echo "Beginning compilation"
T1=$(date +%s)
make $MAKEOPTS ARCH=arm CROSS_COMPILE="$CROSS_COMPILE" zImage
T2=$(date +%s)
echo "Compilation took $(($T2 - $T1)) seconds."
if [ "$PRODUCE_TAR" = y ] ; then
	echo "Generating $TARGET-$VERSION.tar for flashing with Odin"
	tar c -C arch/arm/boot zImage >"$TARGET-$VERSION.tar"
fi

if [ "$PRODUCE_ZIP" = y ] ; then
	if [ "$TARGET" = "i897" ]; then
	    echo "Generating $TARGET-$VERSION.zip for flashing as update.zip"
	    rm -fr "$TARGET-$VERSION.zip"
	    cp arch/arm/boot/zImage build/update
	    OUTFILE="$PWD/$TARGET-$VERSION.zip"
	    pushd build/update
	    eval "$MKZIP" >/dev/null 2>&1
	    popd
	    echo "Signing the update.zip file for flashing"
	    java -jar "$AOSP"/out/host/linux-x86/framework/signapk.jar \
		"$AOSP"/build/target/product/security/testkey.x509.pem \
		"$AOSP"/build/target/product/security/testkey.pk8 \
		"$OUTFILE" "$OUTFILE"-signed
	    mv "$OUTFILE"-signed update.zip

	    echo "Building $TARGET-revert.zip"
	    cp arch/arm/boot/zImage build/captivate-revert/updates
	    OUTFILE="$PWD/$TARGET-revert.zip"
	    pushd build/captivate-revert
	    eval "$MKZIP" >/dev/null 2>&1
	    popd
	    java -jar "$AOSP"/out/host/linux-x86/framework/signapk.jar \
		"$AOSP"/build/target/product/security/testkey.x509.pem \
		"$AOSP"/build/target/product/security/testkey.pk8 \
		"$OUTFILE" "$OUTFILE"-signed
	    mv "$OUTFILE"-signed "$OUTFILE"

	elif [ "$TARGET" = "i897_hsupa" ]; then
	    echo "Building $TARGET.zip"
	    cp arch/arm/boot/zImage build/captivate-hsupa/updates
	    OUTFILE="$PWD/$TARGET.zip"
	    pushd build/captivate-hsupa
	    eval "$MKZIP" >/dev/null 2>&1
	    popd
	    java -jar "$AOSP"/out/host/linux-x86/framework/signapk.jar \
		"$AOSP"/build/target/product/security/testkey.x509.pem \
		"$AOSP"/build/target/product/security/testkey.pk8 \
		"$OUTFILE" "$OUTFILE"-signed
	    mv "$OUTFILE"-signed "$OUTFILE"

	fi
fi
T3=$(date +%s)
echo "Packaging took $(($T3 - $T2)) seconds."
