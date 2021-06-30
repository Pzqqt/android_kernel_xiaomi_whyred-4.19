#!/bin/bash

yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
gre='\e[0;32m'
ZIMG=./out/arch/arm64/boot/Image.gz-dtb

export LOCALVERSION=-v1.1

rm -f $ZIMG

export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64
export CLANG_PATH=/home/pzqqt/build_toolchain/clang-r416183d-12.0.7

export KBUILD_BUILD_HOST="wsl2"
export KBUILD_BUILD_USER="pzqqt"

ccache_=`which ccache`

make mrproper O=out || exit 1
make vendor/whyred_defconfig O=out || exit 1

Start=$(date +"%s")

yes '1' | make -j$(nproc --all) \
	O=out \
	CC="${ccache_} ${CLANG_PATH}/bin/clang" \
	CLANG_TRIPLE=aarch64-linux-gnu- \
	CROSS_COMPILE="/home/pzqqt/build_toolchain/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-" \
	CROSS_COMPILE_ARM32="/home/pzqqt/build_toolchain/gcc-arm-10.2-2020.11-x86_64-arm-none-linux-gnueabihf/bin/arm-none-linux-gnueabihf-"

exit_code=$?
End=$(date +"%s")
Diff=$(($End - $Start))

if [ -f $ZIMG ]; then
	echo -e "$gre << Build completed in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds >> \n $white"
else
	echo -e "$red << Failed to compile Image.gz-dtb, fix the errors first >>$white"
	exit $exit_code
fi
