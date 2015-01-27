#!/bin/bash

sdir="/home/ryan/Kernels/Ascension"
udir="/home/ryan/Kernels/Ascension/lk.utils"
objdir="/home/ryan/Kernels/Ascension_Out"
device="shamu"
cc="/home/ryan/Onyx/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin/arm-eabi-"
filename="Ascension.I.zip"
ocuc_branch="lk-lp-ocuc"

compile() {
  cd $sdir
  CROSS_COMPILE=$cc
  make clean && make mrproper
  make lk_defconfig
  make O=$objdir ARCH=arm -j5
}

ramdisk() {
  cd $sdir/lk.ramdisk
  chmod 750 init* sbin/adbd* sbin/healthd
  chmod 644 default* uevent* res/images/charger/*
  chmod 755 sbin sbin/lkconfig
  chmod 700 sbin/lk-post-boot.sh
  chmod 755 res res/images res/images/charger
  chmod 640 fstab.shamu
  find . | cpio -o -H newc | gzip > /tmp/ramdisk.img
  /bin/mkbootimg --kernel $sdir/arch/arm/boot/zImage-dtb  --ramdisk /tmp/ramdisk.img --cmdline "console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=shamu msm_rtb.filter=0x37 ehci-hcd.park=3 utags.blkdev=/dev/block/platform/msm_sdcc.1/by-name/utags utags.backup=/dev/block/platform/msm_sdcc.1/by-name/utagsBackup coherent_pool=8M" --pagesize 2048 -o /tmp/boot.img
}

zipit() {
  cd $udir
  cp -f /tmp/boot.img zip/
  cd zip
  zip -r /tmp/$1 *
  rm boot.img
  cd $sdir
} 

compile && ramdisk && zipit $filename 
