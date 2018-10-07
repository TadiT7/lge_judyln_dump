#!/system/bin/sh

packet_log_prop=`getprop persist.service.packet.enable`

touch /data/logger/packet.pcap
chmod 0644 /data/logger/packet.pcap

optionC="-C20"

storage_low_prop=`getprop persist.service.logger.low`

if [ "$radio_log_prop" = "3"]; then
    if [ "$storage_low_prop" = "1" ]; then
        optionC="-C2"
    fi
fi

if test "2" -eq "$packet_log_prop"
then
  optionSize="-s200"
else
  optionSize="-s0"
fi

if test "$packet_log_prop" -ge "1"
then
# 2013-08-08 hobbes.song@lge.com LGP_DATA_TOOL_TCPDUMP  @ver2[START]
build_type=`getprop ro.build.type`
case "$build_type" in
        "user")
            /system/xbin/tcd -i any $optionC -W 10 -Z root $optionSize -w /data/logger/packet.pcap
        ;;
esac
case "$build_type" in
        "eng" | "userdebug")
            /system/xbin/tcpdump -i any $optionC -W 10 -Z root $optionSize -w /data/logger/packet.pcap
        ;;
esac
# 2013-08-08 hobbes.song@lge.com LGP_DATA_TOOL_TCPDUMP  @ver2[END]
fi
