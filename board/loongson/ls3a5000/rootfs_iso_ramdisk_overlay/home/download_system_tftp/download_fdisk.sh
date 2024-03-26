#! /bin/sh

tftp_ip=$1
config_name=config.txt
fdisk_name=fdisk.txt

disk_config="null"

root_partition="/dev/sda1"
data_partition="/dev/sda2"
swap_partition="/dev/sda3"
backup_partition="/dev/sda4"

root_mount_point="/mnt/usb1"
data_mount_point="/mnt/usb2"
swap_mount_point="/mnt/usb3"
backup_mount_point="/mnt/usb4"

download_partition="/dev/sda4"
download_mount_point="/mnt/usb4"

head_line_target=`ifconfig -a | grep "lo" | tr -s ' ' | cut -d ' ' -f2`
dev_list_size=0
eth_dev_name=""

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

get_eth_dev_name()
{
	eth_dev_name=`ifconfig -a | grep $head_line_target | grep -v lo | grep -v can | grep -v usb | grep -v sit | tr -s ' ' | cut -d ' ' -f1 | head -$1 | tail -1`
}

get_up_eth()
{
	ifconfig $eth_dev_name $1 netmask 255.255.255.0
	echo "wait 10s to let eth up dev_name: $eth_dev_name"
	time_count=1
	while [ $time_count -le 10 ];
	do
		printf "\r"$time_count"s..."
		sleep 1
		time_count=$(($time_count+1))
	done
	echo ""
	echo "check server connect....."
	tftp -r "uImage" -g $tftp_ip -b 8192 2>/dev/null
	check_server_result=$?
	if [ $check_server_result -ne 0 ]; then
		ifconfig $eth_dev_name down
	fi
	if [ -f "uImage" ]; then
		rm uImage
	fi
	return $check_server_result
}

connect_tftp_server()
{
	dev_list_size=`ifconfig -a | grep $head_line_target | grep -v lo | grep -v can | grep -v usb | grep -v sit | wc -l`
	cur_test_eth_num=1
	while [ $cur_test_eth_num -le $dev_list_size ]
	do
		get_eth_dev_name $cur_test_eth_num
		get_up_eth $1
		if [ $? -eq 0 ]; then
			return 0;
		fi
		echo "$eth_dev_name can t connect tftp server, try other eth!"
		cur_test_eth_num=$(($cur_test_eth_num+1))
	done
	error_inf_print "Error!!! not connect server, please check your network!!!"
	return 1
}

run()
{
	connect_tftp_server $2
	if [ $? -ne 0 ]; then
		return 1
	fi
	echo "start download file by tftp"
	tftp -r $fdisk_name -g $tftp_ip -b 4096 2>/dev/null

	if [ $? -eq 0 ]; then
		/home/install_fdisk_analysis.sh 1 $fdisk_name
	else
		tftp -r $config_name -g $tftp_ip -b 4096 2>/dev/null

		if [ -f $config_name ]; then
			disk_config=`cat $config_name | head -n1`
			/home/install_fdisk_analysis.sh 2 $disk_config
		else
			/home/install_fdisk_analysis.sh
		fi
	fi

	sync;
	#查看分区表的变化
	echo ""
	fdisk -l | grep "/dev/sda";
	sleep 1;

	/home/install_format_all_disk.sh
	if [ $? -ne 0 ]; then
		return $?
	fi

	if [ ! -e $download_partition ]; then
		download_partition="/dev/sda1"
		download_mount_point="/mnt/usb1"
	fi

	mount $download_partition $download_mount_point
	/home/download_system_tftp/download.sh $tftp_ip $download_mount_point
	result=$?
	umount $download_mount_point
	return $result
}

run $1 $2;
exit $?;