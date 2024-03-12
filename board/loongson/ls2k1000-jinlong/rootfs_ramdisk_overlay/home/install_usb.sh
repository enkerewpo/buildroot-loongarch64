echo " ";
echo "*************************************************************************"
echo "*********************************STARG 1*********************************"
echo "************this stage for format SSD and copy file to backup************"
echo "*************************************************************************"
echo " ";
sleep 2;

usb_partition="/dev/sdb1"
root_partition="/dev/sda1"
data_partition="/dev/sda2"
swap_partition="/dev/sda3"
backup_partition="/dev/sda4"

usb_mount_point="/mnt/usb0"
root_mount_point="/mnt/usb1"
data_mount_point="/mnt/usb2"
swap_mount_point="/mnt/usb3"
backup_mount_point="/mnt/usb4"

create_all_mount_point()
{
	if [ ! -d $usb_mount_point ]; then
		mkdir $usb_mount_point
	fi
	if [ ! -d $root_mount_point ]; then
		mkdir $root_mount_point
	fi
	if [ ! -d $data_mount_point ]; then
		mkdir $data_mount_point
	fi
	if [ ! -d $swap_mount_point ]; then
		mkdir $swap_mount_point
	fi
	if [ ! -d $backup_mount_point ]; then
		mkdir $backup_mount_point
	fi
}

check_and_umount_for_safe()
{
	for i in /mnt/usb*; do
	{
		if mountpoint -q $i; then
			sync;
			umount $i;
		fi
	}
	done
}

#错误信息输出到usb的install文件夹里的error.log
#注意安装系统时install文件夹不要存放error.log
#否则会先改名error.log.bak,多次执行后，这样可能会造成数据丢失
error_inf_write_usb()
{
	if mountpoint -q $usb_mount_point; then
		echo $1 >> $usb_mount_point"/install/error.log";
	else
		mount $usb_partition $usb_mount_point;
		if mountpoint -q $usb_mount_point; then
			echo $1 >> $usb_mount_point"/install/error.log";
			sync;
			umount $usb_mount_point;
		else
			echo "-------------> log error: couldn't mount usb("$usb_partition") <-------------"
		fi
	fi
}

error_inf_print()
{
	echo "";
	echo "*************************************************************************"
	echo "********************************Error Log********************************"
	echo "*************************************************************************"
	echo $1
	error_inf_write_usb $1
	check_and_umount_for_safe;
	echo "*************************************************************************"
	echo ""
	exit 1;
}

# sda1 / 	usb1
# sda2 data usb2
# sda3 swap usb3
# sda4 backup usb4

#fdisk_SSD 使用fdisk进行分区 必要
#format_all_partition 格式化所有分区 必要
#copy_file_to_backup 复制文件到backup分区 必要

#检查文件是否齐全
check_file_for_safe()
{
	#检查是不是缺少部分文件，不然分了区才说没文件系统，那么原来的系统就会丢失。
	#能来这里执行，就代表本来就有uImage
	echo "-------------> stage1 check_file_for_safe <-------------"
	if [ ! -f $usb_mount_point"/install/rootfs.tar.gz" ]; then
		error_inf_print "Error! not found "$usb_mount_point"/install/rootfs.tar.gz please check your USB disk"
		exit 1;
	fi
}

#进行分区
#默认2分区
#有fdisk.txt按fdisk.txt来分
#有名字为4part的文件, 那么4分区来分
#有名字为twosys的文件, 那么按乒乓系统的份额分(backup大点)
fdisk_SSD()
{
	echo "-------------> stage1.1 fdisk disk <-------------"
	#分区信息导入
	if [ -f $usb_mount_point"/install/fdisk.txt" ]; then
		fdisk /dev/sda < /mnt/usb0/install/fdisk.txt >/dev/null;
	elif [ -e $usb_mount_point"/install/4part" ]; then
		/home/install_fdisk.sh 0
	elif [ -e $usb_mount_point"/install/twosys" ]; then
		/home/install_fdisk.sh 1
	else
		echo ""
		echo "would split sda to 2 partition! /dev/sda1 and /dev/sda3"
		sleep 1;
		fdisk /dev/sda < /home/fdisk.txt >/dev/null;
	fi
	sync;
	#查看分区表的变化
	echo ""
	fdisk -l | grep "/dev/sda";
	sleep 1;
	return 0;
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
	/home/mke2fs -c -t ext4 -L rootfs -F $root_partition -O ^metadata_csum >/dev/null;
	if [ $? -eq 0 ]; then
		echo "-------------> stage1.2 format / partition --- success <-------------"
	else
		error_inf_print "Error! format / partition failed! please check partition info and try again"
		exit 1;
	fi
	sync

	if [ -e $data_partition ]; then
		echo "-------------> stage1.2 format data partition --- start <-------------"
		/home/mke2fs -c -t ext4 -L data -F $data_partition >/dev/null;
		if [ $? -eq 0 ]; then
			echo "-------------> stage1.2 format data partition --- success <-------------"
		else
			error_inf_print "Error! format data partition failed! please check partition info and try again"
			exit 1;
		fi
		sync
	fi

	echo "-------------> stage1.2 format swap partition --- start <-------------"
	if [ -e $swap_partition ]; then
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
		/home/mke2fs -c -t ext4 -L rootfs -F $backup_partition -O ^metadata_csum >/dev/null;
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

#相关分区
#存放rootfs.tar.gz的分区 sda1或者sda4
#U盘
#把U盘里面的内核和文件系统复制到SSD
copy_file_to_SSD()
{
	echo "-------------> stage1.3: copy file to SSD <-------------"

	mount $1 $2;
	if mountpoint -q $2; then
		sleep 1;
		#检查是否存在用于恢复用的busybox制作的系统
		#如果有，那么就把系统复制到备份分区，并且改名ramdisk.gz（和Recovery System对应）
		#如果没有，那么就会提示找不到，然后到时候Recovery System则无法使用，可以人为手动加备份分区只要名字是ramdisk.gz即可
		if [ -e $backup_partition ]; then
			cp -pv /mnt/usb0/install/ramdisk.gz $2/ramdisk.gz
			wait $!
			sync;
		fi

		echo "      -----> copy uImage"
		cp -pv $usb_mount_point/install/uImage $2
		wait $!

		echo "      -----> copy rootfs.tar.gz (wait a few minutes)"
		rsync -P $usb_mount_point/install/rootfs.tar.gz $2
		wait $!
		sync

		umount $2;
	else
		error_inf_print "Error! mount "$1" failed! Counldn't copy file to SSD! Please try again"
		exit 1;
	fi
}

#相关分区
#U盘
start_stage1()
{
	#挂载U盘
	mount -t vfat -o utf8 $usb_partition $usb_mount_point;
	sleep 1;
	if mountpoint -q $usb_mount_point; then
		if [ -f $usb_mount_point/install/error.log ]; then
			echo "-------------> stage1 warning: found error.log <-------------"
			echo "-------------> stage1 warning: backup this error.log <-------------"
			mv $usb_mount_point/install/error.log $usb_mount_point/install/error.log.bak
		fi

		echo "-------------> stage1 mount /dev/sdb1(usb) success <-------------";

		check_file_for_safe;
		echo ""
		fdisk_SSD;
		echo ""
		format_all_partition;
		echo ""
		#参数含义：参数1 backup分区的设备 参数2 backup分区的挂载点
		if [ -e $backup_partition ]; then
			copy_file_to_SSD $backup_partition $backup_mount_point
		else
			copy_file_to_SSD $root_partition $root_mount_point
		fi

		umount /mnt/usb0;
	else
		error_inf_print "mount USB disk failed! Please check USB format(fat32?) and try again!"
	fi
}

###################start##########################
###################start##########################
###################start##########################

create_all_mount_point;
start_stage1;
echo "-------------> stage1 end <-------------"
/home/install_disk.sh
