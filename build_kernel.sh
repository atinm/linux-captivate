#!/bin/sh
set -e
AOSP="/data/android/aosp"
CROSS_COMPILE="${HOME}/arm-none-eabi-4.3.4/bin/arm-none-eabi-"
MKZIP='7z -mx9 -mmt=1 a "$OUTFILE" .'
TARGET=i897
CLEAN=n
CCACHE="ccache"
DEFCONFIG=y
PRODUCE_TAR=n
PRODUCE_ZIP=y
export CCACHE_COMPRESS=1
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
make ARCH=arm CROSS_COMPILE="$CROSS_COMPILE" zImage
T2=$(date +%s)
echo "Compilation took $(($T2 - $T1)) seconds."
VERSION=$(git describe --tags)
if [ "$PRODUCE_TAR" = y ] ; then
	echo "Generating $TARGET-$VERSION.tar for flashing with Odin"
	tar c -C arch/arm/boot zImage >"$TARGET-$VERSION.tar"
fi
if [ "$PRODUCE_ZIP" = y ] ; then
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
fi
T3=$(date +%s)
echo "Packaging took $(($T3 - $T2)) seconds."
