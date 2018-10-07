#!/vendor/bin/sh

case "$(getprop ro.boot.bootdevice)" in
*ufs*)
    #for ufs
    emmc_size="`cat /sys/block/sda/size`";;
*)
    #for emmc
    emmc_size="`cat /sys/block/mmcblk0/size`";;
esac

echo $emmc_size

TARGET_8GB_MODEL=16777216   # (8*1024*1024*1024)/512
TARGET_16GB_MODEL=33554432  # (16*1024*1024*1024)/512
TARGET_32GB_MODEL=67108864  # (32*1024*1024*1024)/512
TARGET_64GB_MODEL=134217728  # (64*1024*1024*1024)/512
TARGET_128GB_MODEL=268435456 # (128*1024*1024*1024)/512
TARGET_256GB_MODEL=536870912 # (256*1024*1024*1024)/512

if [ $emmc_size -lt $TARGET_8GB_MODEL ]; then
       setprop persist.sys.emmc_size 8G
       echo 8G model
elif [ $emmc_size -lt $TARGET_16GB_MODEL ]; then
       setprop persist.sys.emmc_size 16G
       echo 16G model
elif [ $emmc_size -lt $TARGET_32GB_MODEL ]; then
       setprop persist.sys.emmc_size 32G
       echo 32G model
elif [ $emmc_size -lt $TARGET_64GB_MODEL ]; then
       setprop persist.sys.emmc_size 64G
       echo 64G model
elif [ $emmc_size -lt $TARGET_128GB_MODEL ]; then
       setprop persist.sys.emmc_size 128G
       echo 128G model
else
       setprop persist.sys.emmc_size 256G
       echo 256G model
fi

