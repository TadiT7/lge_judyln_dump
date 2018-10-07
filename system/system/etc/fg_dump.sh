#!/vendor/bin/sh
let count=0

local utime
local ktime
local pause_time=10

fg_log_prop=`getprop persist.service.fg.enable`

if [ -n "$1" ]; then
	pause_time=$1
fi

dump_peripheral () {
	local base=$1
	local size=$2
	local dump_path=$3
	echo $base > $dump_path/address
	echo $size > $dump_path/count
	cat $dump_path/data
}

fg_dumper() {
	echo DATE: $(date)
	echo "Starting dumps!"
	echo "Dump path = $dump_path, pause time = $pause_time"

    while true
    do
		utime=($(cat /proc/uptime))
		ktime=${utime[0]}
		echo "FG SRAM Dump Started at ${ktime}"
		dump_peripheral 0 500 "/sys/kernel/debug/fg/sram"
		uptime=($(cat /proc/uptime))
		ktime=${utime[0]}
		echo "FG SRAM Dump done at ${ktime}"
		let count=$count+1
		sleep $pause_time
    done
}
if [ "$fg_log_prop" == "1" ] || [ "$fg_log_prop" == "2" ] || [ "$fg_log_prop" == "3" ] || [ "$fg_log_prop" == "4" ] || [ "$fg_log_prop" == "5" ]; then
if [ -n "$2" ]
then
    touch $2
    chmod -h 644 $2
    fg_dumper >> "$2"
else
    fg_dumper
fi
fi
