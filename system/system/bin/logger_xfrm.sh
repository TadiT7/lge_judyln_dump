#!/system/bin/sh

source check_data_mount.sh
log_to_data_partition=`is_ext4_data_partition`
log_file="xfrm.log"

xfrm_log_prop=`getprop persist.service.xfrm.enable`

touch /data/logger/${log_file}
chmod 0644 /data/logger/${log_file}

file_size_kb=16376
file_cnt=0

case "$xfrm_log_prop" in
        1)
            file_cnt=4
            ;;
        0)
            file_cnt=0
            ;;
        *)
            file_cnt=0
            ;;
esac

if [[ $file_cnt > 0 ]]; then
    if [[ $log_to_data_partition == 1 ]]; then
        #move_log "/data/logger/${log_file}" "/cache/encryption_log/${log_file}"
        /system/bin/ip -t xfrm monitor > /data/logger/${log_file}
    fi
fi

