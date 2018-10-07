#!/system/bin/sh

source check_data_mount.sh
log_to_data_partition=`is_ext4_data_partition`
log_file="ccaudit.log"
rcv_log_file="last_log"

ro_build_ab_update=`getprop ro.build.ab_update`
if [ "$ro_build_ab_update" = "true" ]; then
tmp_log_path="vendor/els"
else
tmp_log_path="cache"
fi

ccmode_supported='0'
ccmode_status='0'
ccmode_audit_bit='0'

ccaudit_log_prop=`getprop persist.service.ccaudit.enable`

if [ -f  /proc/sys/crypto/cc_mode_flag ];then
    ccmode_supported='1'
    ccmode_status=$(cat /proc/sys/crypto/cc_mode_flag)
else
    ccmode_supported='0'
    ccmode_status='0'
fi

let "ccmode_audit_bit = ccmode_status & 2"

touch /data/ccaudit/${log_file}
chmod 0644 /data/ccaudit/${log_file}

if  [ "$ccmode_audit_bit" = "2" ] || [ "$ccaudit_log_prop" = "1" ] ; then
    if [[ $log_to_data_partition == 1 ]]; then
        move_log "/data/ccaudit/${log_file}" "/${tmp_log_path}/encryption_log/${log_file}"
        move_log "/data/ccaudit/${log_file}" "/${tmp_log_path}/recovery/${rcv_log_file}"

        /system/bin/logcat -v threadtime -b ccaudit -f /data/ccaudit/${log_file} -n 5 -r 4096
    else
        touch /${tmp_log_path}/encryption_log/${log_file}
        chmod 0644 /${tmp_log_path}/encryption_log/${log_file}
        /system/bin/logcat -v threadtime -b ccaudit -f /${tmp_log_path}/encryption_log/${log_file} -n 5 -r 4096
    fi
fi
