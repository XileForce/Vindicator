#!/bin/bash

sdir="/home/ryan/Kernels/Vindicator"
udir="/home/ryan/Kernels/Vindicator/utils"
outdir="/home/ryan/Kernels/Vindicator_Out"
device="shamu"
cc="/home/ryan/arm-eabi-6.0Uber/bin/arm-eabi-"
filename="Vindicator.2.1.zip"

compile() {
  export CROSS_COMPILE=$cc
  export ARCH=arm
  export SUBARCH=arm
  export KBUILD_BUILD_USER=Xile
  export KBUILD_BUILD_HOST=Xile
  make clean && make mrproper
  make vindicator_defconfig
  make -j6
}

ramdisk() {
  cd $sdir/ramdisk
  chmod 750 init* sbin/adbd* sbin/healthd
  chmod 644 default* uevent* res/images/charger/*
  chmod 755 sbin sbin/lkconfig
  chmod 700 sbin/lk-post-boot.sh
  chmod 755 res res/images res/images/charger
  chmod 640 fstab.shamu
  find . | cpio -o -H newc | gzip > /tmp/ramdisk.img
  /bin/mkbootimg --kernel $sdir/arch/arm/boot/zImage-dtb  --ramdisk /tmp/ramdisk.img --cmdline "console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=shamu msm_rtb.filter=0x37 ehci-hcd.park=3 utags.blkdev=/dev/block/platform/msm_sdcc.1/by-name/utags utags.backup=/dev/block/platform/msm_sdcc.1/by-name/utagsBackup coherent_pool=8M androidboot.selinux=permissive" --pagesize 2048 -o $outdir/boot.img
}

zipit() {
  cd $udir
  cp -f $outdir/boot.img zip/
  cd zip
  zip -r $outdir/$1 *
  rm boot.img
  cd $sdir
} 

compile && ramdisk && zipit $filename 
