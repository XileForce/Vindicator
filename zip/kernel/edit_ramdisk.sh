#!/sbin/sh
#ramdisk_gov_sed.sh by show-p1984
#Features:
#cp old kernel to sdcard
#extracts ramdisk
#finds busbox in /system or sets default location if it cannot be found
#add init.d support if not already supported
#removes governor overrides
#removes min freq overrides
#adds module insertion to the ramdisk
#adds better ondemand settings
#repacks the ramdisk

#copy old kernel to sdcard
if [ ! -e /sdcard/pre_bricked_kernel_zImage ]; then
	cp /tmp/boot.img-zImage /sdcard/pre_bricked_kernel_zImage
fi

mkdir /tmp/ramdisk
cp /tmp/boot.img-ramdisk.gz /tmp/ramdisk/
cd /tmp/ramdisk/
gunzip -c /tmp/ramdisk/boot.img-ramdisk.gz | cpio -i
cd /

#add init.d support if not already supported
#this is no longer needed as the ramdisk now inserts our modules, but we will
#keep this here for user comfort, since having run-parts init.d support is a
#good idea anyway.
found=$(find /tmp/ramdisk/init.rc -type f | xargs grep -oh "run-parts /system/etc/init.d");
if [ "$found" != 'run-parts /system/etc/init.d' ]; then
        #find busybox in /system
        bblocation=$(find /system/ -name 'busybox')
        if [ -n "$bblocation" ] && [ -e "$bblocation" ] ; then
                echo "BUSYBOX FOUND!";
                #strip possible leading '.'
                bblocation=${bblocation#.};
        else
                echo "BUSYBOX NOT FOUND! init.d support will not work without busybox!";
                echo "Setting busybox location to /system/xbin/busybox! (install it and init.d will work)";
                #set default location since we couldn't find busybox
                bblocation="/system/xbin/busybox";
        fi
	#append the new lines for this option at the bottom
        echo "" >> /tmp/ramdisk/init.rc
        echo "service userinit $bblocation run-parts /system/etc/init.d" >> /tmp/ramdisk/init.rc
        echo "    oneshot" >> /tmp/ramdisk/init.rc
        echo "    class late_start" >> /tmp/ramdisk/init.rc
        echo "    user root" >> /tmp/ramdisk/init.rc
        echo "    group root" >> /tmp/ramdisk/init.rc
fi

#remove governor overrides, use kernel default
sed -i '/\/sys\/devices\/system\/cpu\/cpu0\/cpufreq\/scaling_governor/d' /tmp/ramdisk/init.flo.rc
sed -i '/\/sys\/devices\/system\/cpu\/cpu1\/cpufreq\/scaling_governor/d' /tmp/ramdisk/init.flo.rc
sed -i '/\/sys\/devices\/system\/cpu\/cpu2\/cpufreq\/scaling_governor/d' /tmp/ramdisk/init.flo.rc
sed -i '/\/sys\/devices\/system\/cpu\/cpu3\/cpufreq\/scaling_governor/d' /tmp/ramdisk/init.flo.rc
#remove min_freq overrides, use kernel default
sed -i '/\/sys\/devices\/system\/cpu\/cpu0\/cpufreq\/scaling_min_freq/d' /tmp/ramdisk/init.flo.rc
sed -i '/\/sys\/devices\/system\/cpu\/cpu1\/cpufreq\/scaling_min_freq/d' /tmp/ramdisk/init.flo.rc
sed -i '/\/sys\/devices\/system\/cpu\/cpu2\/cpufreq\/scaling_min_freq/d' /tmp/ramdisk/init.flo.rc
sed -i '/\/sys\/devices\/system\/cpu\/cpu3\/cpufreq\/scaling_min_freq/d' /tmp/ramdisk/init.flo.rc
#remove ondemand tuneable overrides, use better ones
sed -i 's/write\ \/sys\/devices\/system\/cpu\/cpufreq\/ondemand\/down_differential\ 10/write\ \/sys\/devices\/system\/cpu\/cpufreq\/ondemand\/down_differential\ 3/g' /tmp/ramdisk/init.flo.rc
sed -i 's/write\ \/sys\/devices\/system\/cpu\/cpufreq\/ondemand\/up_threshold_multi_core\ 60/write\ \/sys\/devices\/system\/cpu\/cpufreq\/ondemand\/up_threshold_multi_core\ 80/g' /tmp/ramdisk/init.flo.rc
sed -i 's/write\ \/sys\/devices\/system\/cpu\/cpufreq\/ondemand\/optimal_freq\ 918000/write\ \/sys\/devices\/system\/cpu\/cpufreq\/ondemand\/optimal_freq\ 384000/g' /tmp/ramdisk/init.flo.rc
sed -i 's/write\ \/sys\/devices\/system\/cpu\/cpufreq\/ondemand\/sync_freq\ 1026000/write\ \/sys\/devices\/system\/cpu\/cpufreq\/ondemand\/sync_freq\ 384000/g' /tmp/ramdisk/init.flo.rc

#add kernel module inserts to the ramdisk
#we ommit scsi_wait_scan.ko here since we usually do not have any scsi devices
echo "Checking for ramdisk modules insertion...";
found=$(find /tmp/ramdisk/init.flo.rc -type f | xargs grep -oh "# Insert Bricked-Kernel modules");
if [ "$found" != '# Insert Bricked-Kernel modules' ]; then
	#add it
	echo "Adding module insertion to ramdisk!";
	sed -i 's/service wcnss_init/on property:init.svc.wcnss_init=stopped\n    # Insert Bricked-Kernel modules\n    insmod \/system\/lib\/modules\/wlan.ko\n    insmod \/system\/lib\/modules\/tun.ko\n    insmod \/system\/lib\/modules\/cifs.ko\n    #insmod \/system\/lib\/modules\/scsi_wait_scan.ko\n\nservice wcnss_init/' /tmp/ramdisk/init.flo.rc
else
	echo "Found module insertion in ramdisk! - no action needed";
fi


rm /tmp/ramdisk/boot.img-ramdisk.gz
rm /tmp/boot.img-ramdisk.gz
cd /tmp/ramdisk/
find . | cpio -o -H newc | gzip > ../boot.img-ramdisk.gz
cd /
rm -rf /tmp/ramdisk

