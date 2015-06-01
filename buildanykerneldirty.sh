#!/bin/bash
# build script by jamcswain
#

export KBUILD_BUILD_USER=Xile
export KBUILD_BUILD_HOST=Xile
export cross=/home/ryan/arm-eabi-6.0/bin/arm-eabi-
export filename="Vindicator.2.1.zip"

make ARCH=arm SUBARCH=arm CROSS_COMPILE=${cross} -j4 vindicator_defconfig
make ARCH=arm SUBARCH=arm CROSS_COMPILE=${cross} -j4
cp arch/arm/boot/zImage-dtb zip/kernel/zImage

cd zip
zip -q -r ${filename} META-INF kernel data system
if [ ! -e ../../Vindicator_Out ]; then
mkdir ../../Vindicator_Out
fi;
mv ${filename} ../../Vindicator_Out
rm kernel/zImage
