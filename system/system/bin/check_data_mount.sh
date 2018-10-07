#!/system/bin/sh

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


function move_log {
	local dst_file=$1
	local src_file=$2

	#dst_file=/data/logger/kernel.log
	#src_file=/cache/encryption_log/kernel.log

	if [ -f $src_file ]
	then
		START=`date +%s`
		src_file_size=`du -sh $src_file`

		rm -f ${dst_file}.tmp

		echo "\n========= BEGIN copy from $src_file ====== " >> ${dst_file}
		cp $dst_file ${dst_file}.tmp
		chmod 644 ${dst_file}.tmp

		cat $src_file >> ${dst_file}.tmp
		MID=`date +%s`
		time_diff=$(($MID - $START))
		echo "\n======== END copy from $src_file (size $src_file_size, time $time_diff s) ====== " >> ${dst_file}.tmp

		mv -f ${dst_file}.tmp $dst_file
		rm -f $src_file

		END=`date +%s`
		time_diff=$(($END - $START))
		echo "\n======== All Done copy from $src_file (size $src_file_size, time $time_diff s) ====== " >> ${dst_file}
	fi
}


