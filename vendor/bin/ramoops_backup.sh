#!/vendor/bin/sh

integer max_count=10
backup_folder=/data/ramoops
count_file=$backup_folder/next_count
kernel_enable=`getprop persist.service.kernel.enable`
logger_folder=/data/logger
console_ramoops=/sys/fs/pstore/console-ramoops-0

copy_ramoops()
{
    case "$kernel_enable" in
        "0")
            ;;
        *)
            cp -fa $backup_folder/* $logger_folder/
            ;;
    esac
}

if ls $console_ramoops ; then
    if ls $count_file ; then
        integer count=`cat $count_file`
        count=$count+0
        case $count in
            "" ) count=0
        esac
    else
        count=0
    fi
    echo [[[[ Written $backup_folder/ramoops$count $max_count ]]]]
    cat $console_ramoops > $backup_folder/ramoops$count
    cat /proc/cmdline >> $backup_folder/ramoops$count
    cat /proc/cmdline > $backup_folder/cmdline$count
    # reason is att permission certification
    chmod -h 664 $backup_folder/ramoops$count
    chmod -h 664 $backup_folder/cmdline$count
    echo update_time_state >> $backup_folder/ramoops$count
    echo update_time_state >> $backup_folder/cmdline$count
    count=$count+1
    if (($count>=$max_count)) ; then
        count=0
        echo restart
    fi
    echo $count > $count_file
    chmod -h 664 $count_file

    copy_ramoops
fi
