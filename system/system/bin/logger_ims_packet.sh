#!/system/bin/sh

packet_log_prop=`getprop persist.service.ims.enable`

touch /data/logger/ims_packet.pcap
chmod 0644 /data/logger/ims_packet.pcap

optionC="-C20"


if test "1" -eq "$packet_log_prop"
then

build_type=`getprop ro.build.type`
#ims_iface='getprop persist.service.ims.iface'
ims_iface="rmnet_data1"

case "$build_type" in
        "user")
            /system/xbin/tcd -i $ims_iface $optionC -W 10 -Z root -s 0 -w /data/logger/ims_packet.pcap
        ;;
esac
case "$build_type" in
        "eng" | "userdebug")
            /system/xbin/tcpdump -i $ims_iface $optionC -W 10 -Z root -s 0 -w /data/logger/ims_packet.pcap
        ;;
esac

fi
