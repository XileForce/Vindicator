#!/bin/bash

export KERNELDIR=/home/ryan/Vindicator
export INITRAMFS_DEST=$KERNELDIR/kernel/usr/initramfs
export PACKAGEDIR=/home/ryan/android
export INITRAMFS_SOURCE=/home/ryan
export Meta=/home/ryan/Vindicator/lk.utils/zip/META-INF
export ARCH=arm
export CROSS_COMPILE=/home/ryan/Onyx/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-

echo "Remove old Package Files"
rm -rf $PACKAGEDIR/*

echo "Remove old zImage"
rm $PACKAGEDIR/zImage

echo "Remove old ramdisk"
rm $INITRAMFS_SOURCE/ramdisk.img.gz

echo "Clean Environment"
cd $KERNELDIR
make clean

echo "Make the kernel"
make lk_defconfig

echo "${bldcya}Compiling.... ${txtrst}"
script -q ~/Compile.log -c " 
make -j6"


if [ -e $KERNELDIR/arch/arm/boot/zImage ]; then
	echo -e "${bldred} Copy modules to Package ${txtrst}"
	cp -a $(find . -name *.ko -print |grep -v initramfs) $PACKAGEDIR/system/lib/modules/
 	
	echo ""

	echo -e "${bldred} Copy zImage to Package ${txtrst}"
	cp $KERNELDIR/arch/arm/boot/zImage $PACKAGEDIR/zImage
 	
	echo ""

	echo -e "${bldred} Ramdisk Readying.. ${txtrst}"
	cp $KERNELDIR/mkbootfs $INITRAMFS_SOURCE
	cd $KERNELDIR/
	./mkbootfs ramdisk | gzip > ramdisk.Vindicator.gz
 	rm mkbootfs
	echo ""

	echo -e "${bldred} Making Boot.img.. ${txtrst}"
	cp $KERNELDIR/mkbootimg $PACKAGEDIR
	cp $INITRAMFS_SOURCE/Vindicator/ramdisk.Vindicator.gz $PACKAGEDIR
	cd $PACKAGEDIR
	./mkbootimg --cmdline 'console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=shamu msm_rtb.filter=0x37 ehci-hcd.park=3 utags.blkdev=/dev/block/platform/msm_sdcc.1/by-name/utags utags.backup=/dev/block/platform/msm_sdcc.1/by-name/utagsBackup coherent_pool=8M' --kernel $PACKAGEDIR/zImage --ramdisk $PACKAGEDIR/ramdisk.Vindicator.gz --base 0x00000000 --pagesize 2048 --ramdisk_offset 0x02000000 --tags_offset 0x01E00000 --output $PACKAGEDIR/boot.img
	rm mkbootimg
 	
	echo ""

	export curdate=`date "+%m-%d-%Y"`
        cp ~/Compile.log ~/android/compile_logs/Success-Vindicator-$curdate.log
        rm ~/Compile.log
	cd $PACKAGEDIR
	rm ramdisk.Vindicator.gz
	rm zImage
	rm ../../Vindicator-*.zip
	rm ../ramdisk.Vindicator.gz
	rm ../zImage
	zip -r ../Vindicator-$curdate.zip .
	mv ../Vindicator-$curdate.zip ~/android/kernel

	echo "Vindicator Completed"

else
	echo "KERNEL DID NOT BUILD! no zImage exist"
	export curdate=`date "+%m-%d-%Y"`
	cp ~/Compile.log ~/android/compile_logs/Failed-Vindicator-$curdate.log
fi;

exit 0
