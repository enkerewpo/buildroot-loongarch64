#! /bin/sh

root_partition="/dev/sda1"
data_partition="/dev/sda2"
swap_partition="/dev/sda3"
backup_partition="/dev/sda4"


error_inf_print()
{
	echo "";
	echo "*************************************************************************"
	echo "********************************Error Log********************************"
	echo "*************************************************************************"
	echo $1
	sleep 2
	echo "*************************************************************************"
	echo ""
	exit 1;
}

#相关分区
#所有分区，这是格式化分区的函数
format_all_partition()
{
	# sda1 / 	usb1
	# sda2 data usb2
	# sda3 swap usb3
	# sda4 backup usb4

	#分区格式化
	echo "-------------> stage1.2 format / partition --- start <-------------"
	mke2fs -t ext4 -L rootfs -F $root_partition -O ^metadata_csum >/dev/null;
	if [ $? -eq 0 ]; then
		echo "-------------> stage1.2 format / partition --- success <-------------"
	else
		error_inf_print "Error! format / partition failed! please check partition info and try again"
		exit 1;
	fi
	sync

	if [ -e $data_partition ]; then
		echo "-------------> stage1.2 format data partition --- start <-------------"
		mke2fs -t ext4 -L data -F $data_partition >/dev/null;
		if [ $? -eq 0 ]; then
			echo "-------------> stage1.2 format data partition --- success <-------------"
		else
			error_inf_print "Error! format data partition failed! please check partition info and try again"
			exit 1;
		fi
		sync
	fi

	if [ -e $swap_partition ]; then
		echo "-------------> stage1.2 format swap partition --- start <-------------"
		mkswap $swap_partition >/dev/null;
		if [ $? -eq 0 ]; then
			echo "-------------> stage1.2 format swap partition --- success <-------------"
		else
			error_inf_print "Error! format swap partition failed! please check partition info and try again"
			exit 1;
		fi
		sync
	fi

	if [ -e $backup_partition ]; then
		echo "-------------> stage1.2 format backup partition --- start <-------------"
		mke2fs -t ext4 -L rootfs -F $backup_partition -O ^metadata_csum >/dev/null;
		if [ $? -eq 0 ]; then
			echo "-------------> stage1.2 format backup partition --- success <-------------"
		else
			error_inf_print "Error! format backup partition failed! please check partition info and try again"
			exit 1;
		fi
		sync
	fi

	sleep 1;
	return 0;
}

format_all_partition;
exit $?