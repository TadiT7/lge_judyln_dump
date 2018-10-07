#!/vendor/bin/sh

#
# Allow USB enumeration with default PID/VID
#
if [ -e /sys/class/android_usb/f_mass_storage/lun/nofua ];
then
    echo 1  > /sys/class/android_usb/f_mass_storage/lun/nofua
fi
if [ -e /sys/class/android_usb/f_cdrom_storage/lun/nofua ];
then
    echo 1  > /sys/class/android_usb/f_cdrom_storage/lun/nofua
fi
if [ -e /sys/class/android_usb/f_mass_storage/rom/nofua ];
then
    echo 1  > /sys/class/android_usb/f_mass_storage/rom/nofua
fi

bootmode=`getprop ro.bootmode`
if [ "${bootmode:0:3}" != "qem" ] && [ "${bootmode:0:3}" != "pif" ]; then
    # correct the wrong usb property
    usb_config=`getprop persist.sys.usb.config`
    case "$usb_config" in
        "" | "pc_suite" | "mtp_only" | "auto_conf")
            setprop persist.sys.usb.config mtp
            ;;
        "adb" | "pc_suite,adb" | "mtp_only,adb" | "auto_conf,adb")
            setprop persist.sys.usb.config mtp,adb
            ;;
        "ptp_only")
            setprop persist.sys.usb.config ptp
            ;;
        "ptp_only,adb")
            setprop persist.sys.usb.config ptp,adb
            ;;
        * ) ;; #USB persist config exists, do nothing
    esac

    # boot overloading
    target_operator=`getprop ro.build.target_operator`
    case "$target_operator" in
        "ATT" | "CRK")
            setprop sys.usb.boot.config.name mtp
            ;;
        *)
            setprop sys.usb.boot.config.name boot
            ;;
    esac
fi

# remove symlink if configfs is mounted
if [ -d /config/usb_gadget ]; then
    rm /config/usb_gadget/g1/configs/b.1/f1
    rm /config/usb_gadget/g1/configs/b.1/f2
    rm /config/usb_gadget/g1/configs/b.1/f3
    rm /config/usb_gadget/g1/configs/b.1/f4
    rm /config/usb_gadget/g1/configs/b.1/f5
    rm /config/usb_gadget/g1/configs/b.2/f1
    rm /config/usb_gadget/g1/configs/b.2/f2
    rm /config/usb_gadget/g1/configs/b.2/f3
    rm /config/usb_gadget/g1/configs/b.2/f4
    rm /config/usb_gadget/g1/configs/b.2/f5
    rm /config/usb_gadget/g1/configs/b.1/strings/0x409/configuration
    rm /config/usb_gadget/g1/configs/b.2/strings/0x409/configuration
    rmdir /config/usb_gadget/g1/configs/b.2/strings/0x409
    rmdir /config/usb_gadget/g1/configs/b.2
fi



################################################################################
# QCOM
################################################################################

chown -h root.system /sys/devices/platform/msm_hsusb/gadget/wakeup
chmod -h 220 /sys/devices/platform/msm_hsusb/gadget/wakeup

# Set platform variables
if [ -f /sys/devices/soc0/hw_platform ]; then
    soc_hwplatform=`cat /sys/devices/soc0/hw_platform` 2> /dev/null
else
    soc_hwplatform=`cat /sys/devices/system/soc/soc0/hw_platform` 2> /dev/null
fi

# Get hardware revision
if [ -f /sys/devices/soc0/revision ]; then
    soc_revision=`cat /sys/devices/soc0/revision` 2> /dev/null
else
    soc_revision=`cat /sys/devices/system/soc/soc0/revision` 2> /dev/null
fi

#
# Allow persistent usb charging disabling
# User needs to set usb charging disabled in persist.usb.chgdisabled
#
target=`getprop ro.board.platform`
usbchgdisabled=`getprop persist.usb.chgdisabled`
case "$usbchgdisabled" in
    "") ;; #Do nothing here
    * )
    case $target in
        "msm8660")
        echo "$usbchgdisabled" > /sys/module/pmic8058_charger/parameters/disabled
        echo "$usbchgdisabled" > /sys/module/smb137b/parameters/disabled
        ;;
        "msm8960")
        echo "$usbchgdisabled" > /sys/module/pm8921_charger/parameters/disabled
        ;;
    esac
esac

usbcurrentlimit=`getprop persist.usb.currentlimit`
case "$usbcurrentlimit" in
    "") ;; #Do nothing here
    * )
    case $target in
        "msm8960")
        echo "$usbcurrentlimit" > /sys/module/pm8921_charger/parameters/usb_max_current
        ;;
    esac
esac

#
# Check ESOC for external MDM
#
# Note: currently only a single MDM is supported
#
if [ -d /sys/bus/esoc/devices ]; then
for f in /sys/bus/esoc/devices/*; do
    if [ -d $f ]; then
        if [ `grep "^MDM" $f/esoc_name` ]; then
            esoc_link=`cat $f/esoc_link`
            break
        fi
    fi
done
fi

target=`getprop ro.board.platform`

# soc_ids for 8937
if [ -f /sys/devices/soc0/soc_id ]; then
	soc_id=`cat /sys/devices/soc0/soc_id`
else
	soc_id=`cat /sys/devices/system/soc/soc0/id`
fi

baseband=`getprop ro.baseband`
case "$baseband" in
    "apq")
         target="apq"
   ;;
esac

# set USB controller's device node
case "$target" in
    "msm8996")
        setprop sys.usb.controller "6a00000.dwc3"
        setprop sys.usb.rndis.func.name "rndis_bam"
        setprop sys.usb.rmnet.func.name "rmnet_bam"
	;;
    "msm8998" | "msmcobalt")
        setprop sys.usb.controller "a800000.dwc3"
        setprop sys.usb.rndis.func.name "gsi"
        setprop sys.usb.rmnet.func.name "gsi"
	;;
    "sdm660")
        setprop sys.usb.controller "a800000.dwc3"
        setprop sys.usb.rndis.func.name "rndis_bam"
        setprop sys.usb.rmnet.func.name "rmnet_bam"
        echo 15916 > /sys/module/usb_f_qcrndis/parameters/rndis_dl_max_xfer_size
        ;;
    "sdm845")
        setprop sys.usb.controller "a600000.dwc3"
        setprop sys.usb.rndis.func.name "gsi"
        setprop sys.usb.rmnet.func.name "gsi"
        ;;
    *)
	;;
esac

# check configfs is mounted or not
if [ -d /config/usb_gadget ]; then
    bootmode=`getprop ro.bootmode`
    case "$bootmode" in
        "qem_56k" | "qem_910k" | "pif_56k" | "pif_910k")
            setprop persist.sys.usb.${bootmode}.func factory
            setprop sys.usb.config factory
            ;;
        "qem_130k" | "pif_130k")
            setprop persist.sys.usb.${bootmode}.func factory2
            setprop sys.usb.config factory2
            ;;
        *)
            ;;
    esac
    setprop sys.usb.configfs 1
fi

#
# Do target specific things
#
case "$target" in
    "msm8974")
# Select USB BAM - 2.0 or 3.0
        echo ssusb > /sys/bus/platform/devices/usb_bam/enable
    ;;
    "apq8084")
        if [ "$baseband" == "apq" ]; then
            echo "msm_hsic_host" > /sys/bus/platform/drivers/xhci_msm_hsic/unbind
        fi
        echo qti,ether > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    "msm8226")
         if [ -e /sys/bus/platform/drivers/msm_hsic_host ]; then
             if [ ! -L /sys/bus/usb/devices/1-1 ]; then
                 echo msm_hsic_host > /sys/bus/platform/drivers/msm_hsic_host/unbind
             fi
         fi
    ;;
    "msm8994" | "msm8992" | "msm8996" | "msm8953")
        echo BAM2BAM_IPA > /sys/class/android_usb/android0/f_rndis_qc/rndis_transports
        echo qti,bam2bam_ipa > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    "msm8952" | "msm8976")
        echo BAM2BAM_IPA > /sys/class/android_usb/android0/f_rndis_qc/rndis_transports
        # Increase RNDIS DL max aggregation size to 11K
        echo 11264 > /sys/module/g_android/parameters/rndis_dl_max_xfer_size
        echo qti,bam2bam_ipa > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    "apq8064")
        echo hsic,hsic > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    "msm8909")
        echo qti,bam > /sys/class/android_usb/android0/f_rmnet/transports
    ;;
    "msm8937")
        case "$soc_id" in
            "313")
                echo BAM2BAM_IPA > /sys/class/android_usb/android0/f_rndis_qc/rndis_transports
                echo qti,bam2bam_ipa > /sys/class/android_usb/android0/f_rmnet/transports
            ;;
            *)
                echo qti,bam > /sys/class/android_usb/android0/f_rmnet/transports
                echo 10 > /sys/module/g_android/parameters/rndis_dl_max_pkt_per_xfer
                echo 3 > /sys/module/g_android/parameters/rndis_ul_max_pkt_per_xfer
            ;;
        esac
    ;;
    * )
        echo smd,bam > /sys/class/android_usb/android0/f_rmnet/transports
        echo 10 > /sys/module/g_android/parameters/rndis_dl_max_pkt_per_xfer
        echo 5 > /sys/module/g_android/parameters/rndis_ul_max_pkt_per_xfer
    ;;
esac

#
# set module params for embedded rmnet devices
#
rmnetmux=`getprop persist.rmnet.mux`
case "$baseband" in
    "mdm" | "dsda" | "sglte2")
        case "$rmnetmux" in
            "enabled")
                    echo 1 > /sys/module/rmnet_usb/parameters/mux_enabled
                    echo 8 > /sys/module/rmnet_usb/parameters/no_fwd_rmnet_links
                    echo 17 > /sys/module/rmnet_usb/parameters/no_rmnet_insts_per_dev
            ;;
        esac
        echo 1 > /sys/module/rmnet_usb/parameters/rmnet_data_init
        # Allow QMUX daemon to assign port open wait time
        chown -h radio.radio /sys/devices/virtual/hsicctl/hsicctl0/modem_wait
    ;;
    "dsda2")
          echo 2 > /sys/module/rmnet_usb/parameters/no_rmnet_devs
          echo hsicctl,hsusbctl > /sys/module/rmnet_usb/parameters/rmnet_dev_names
          case "$rmnetmux" in
               "enabled") #mux is neabled on both mdms
                      echo 3 > /sys/module/rmnet_usb/parameters/mux_enabled
                      echo 8 > /sys/module/rmnet_usb/parameters/no_fwd_rmnet_links
                      echo 17 > write /sys/module/rmnet_usb/parameters/no_rmnet_insts_per_dev
               ;;
               "enabled_hsic") #mux is enabled on hsic mdm
                      echo 1 > /sys/module/rmnet_usb/parameters/mux_enabled
                      echo 8 > /sys/module/rmnet_usb/parameters/no_fwd_rmnet_links
                      echo 17 > /sys/module/rmnet_usb/parameters/no_rmnet_insts_per_dev
               ;;
               "enabled_hsusb") #mux is enabled on hsusb mdm
                      echo 2 > /sys/module/rmnet_usb/parameters/mux_enabled
                      echo 8 > /sys/module/rmnet_usb/parameters/no_fwd_rmnet_links
                      echo 17 > /sys/module/rmnet_usb/parameters/no_rmnet_insts_per_dev
               ;;
          esac
          echo 1 > /sys/module/rmnet_usb/parameters/rmnet_data_init
          # Allow QMUX daemon to assign port open wait time
          chown -h radio.radio /sys/devices/virtual/hsicctl/hsicctl0/modem_wait
    ;;
esac

# soc_ids for 8937
if [ -f /sys/devices/soc0/soc_id ]; then
	soc_id=`cat /sys/devices/soc0/soc_id`
else
	soc_id=`cat /sys/devices/system/soc/soc0/id`
fi

# enable rps cpus on msm8937 target
setprop sys.usb.rps_mask 0
case "$soc_id" in
	"294" | "295")
		setprop sys.usb.rps_mask 40
	;;
esac

################################################################################
# DEVICE
################################################################################

if [ -f "/vendor/bin/init.lge.usb.dev.sh" ]
then
    source /vendor/bin/init.lge.usb.dev.sh
fi
