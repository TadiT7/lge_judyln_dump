#!/vendor/bin/sh

max_count=10
result_file=/data/ramoops/pstore_backup_result
crash_result_file=/data/ramoops/pstore_backup_crash
backup_folder=/data/ramoops
count_file=$backup_folder/pstore_next_count
crash_count_file=$backup_folder/pstore_crash_count
pstore_part=/dev/block/bootdevice/by-name/pstore
logger_folder=/data/logger
ftm_result_file=/data/ramoops/ftm_crash_result
ftm_count_file=$backup_folder/ftm_crash_count
ftm_part=/dev/block/bootdevice/by-name/ftm

do_copy=0
copy_ramoops()
{
	cp -fa $backup_folder/* $logger_folder/
}

function is_ext4_data_partition {
	local ret=0
	proc_mounts="/proc/mounts"

	while read -r line
	do
		mount_info=($line)
		mount_path=${mount_info[1]}
		mount_fs=${mount_info[2]}

		if [[ $mount_path == "/data" ]] && [[ $mount_fs == "ext4" ]]
		then
			ret=1
			break
		fi
	done < "$proc_mounts"
	echo $ret
}

data_partition=`is_ext4_data_partition`

if [ $data_partition -eq 0 ]; then
	exit 1
fi

rm -f $result_file
rm -f $crash_result_file
rm -r $ftm_result_file
/vendor/bin/pstore_backup $pstore_part
/vendor/bin/ftm_backup $ftm_part

if [ -f $result_file ] ; then
	if [ -f $count_file ] ; then
		count=`cat $count_file`
		case $count in
			"" ) count=0
		esac
	else
		count=0
	fi
	echo [[[[ Written $backup_folder/pstore_backup$count $max_count ]]]]
	mv $result_file $backup_folder/pstore_backup$count
	echo -e "\n" >> $backup_folder/pstore_backup$count
	cat /proc/cmdline >> $backup_folder/pstore_backup$count
	cat /proc/cmdline > $backup_folder/cmdline$count
	# reason is att permission certification
	chmod -h 664 $backup_folder/pstore_backup$count
	chmod -h 664 $backup_folder/cmdline$count
	count=$(($count+1))
	if (($count>=$max_count)) ; then
		count=0
	fi
	echo $count > $count_file
	chmod -h 664 $count_file
	do_copy=1
fi

if [ -f $crash_result_file ] ; then
	if [ -f $crash_count_file ] ; then
		count=`cat $crash_count_file`
		case $count in
			"" ) count=0
		esac
	else
		count=0
	fi
	echo [[[[ Written $backup_folder/pstore_crash$count $max_count ]]]]
	mv $crash_result_file $backup_folder/pstore_crash$count
	# reason is att permission certification
	chmod -h 664 $backup_folder/pstore_crash$count
	count=$(($count+1))
	if (($count>=$max_count)) ; then
		count=0
	fi
	echo $count > $crash_count_file
	chmod -h 664 $crash_count_file
	do_copy=1
fi

if [ -f $ftm_result_file ] ; then
	mv $ftm_result_file $backup_folder/ftm_crash
	# reason is att permission certification
	chmod -h 664 $backup_folder/ftm_crash
    	do_copy=1
fi

if [ do_copy -eq 1 ] ; then
	copy_ramoops
fi
