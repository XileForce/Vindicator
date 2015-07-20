#!/bin/bash
export version=$1
export KBUILD_BUILD_USER=Xile
export KBUILD_BUILD_HOST=Xile
export cross=/home/ryan/arm-eabi-6.0Uber/bin/arm-eabi-
make ARCH=arm SUBARCH=arm CROSS_COMPILE=${cross} -j6 vindicator_defconfig
make ARCH=arm SUBARCH=arm CROSS_COMPILE=${cross} -j6
cp arch/arm/boot/zImage-dtb zip/kernel/zImage
find -name '*.ko' -exec cp -av {} zip/system/lib/modules/ \;
cd zip
zip -q -r Vindicator-N6-${version}.zip META-INF kernel data system
mkdir ../../Vindicator-out
mv Vindicator-N6-${version}.zip ../../Vindicator_Out
rm kernel/zImage
rm system/lib/modules/*
