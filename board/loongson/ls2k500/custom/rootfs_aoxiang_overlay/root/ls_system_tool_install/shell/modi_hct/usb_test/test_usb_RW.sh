#! /bin/sh

#shell_info_start
#name:USB transfer test
#args:/dev/sda1
#args_tip:USB transfer test
#type:interface
#mul:0
#desc:USB transfer test
#board:LS2K500-MODI_HCT
#shell_info_end

usb_dev="/dev/sdb1"
usb_mount="/mnt/usb"
test_dir="/mnt/usb/loongson_usb_iotest"

test_usb_dev()
{
	if [ ! -e $usb_dev ]; then
		echo "not found usb! please check usb insert!";
		return 1;
	fi

	mountpoint -q $usb_mount
	if [ $? -eq 1 ]; then
		if [ ! -d $usb_mount ]; then
			mkdir -p $usb_mount;
		fi
		mount $usb_dev $usb_mount;
	fi

	mountpoint -q $usb_mount
	if [ $? -eq 1 ]; then
		echo "mount usb failed!";
		return 1;
	fi
	return 0;
}

if [ $# -eq 1 ]; then
	usb_dev=$1;
	test_usb_dev
	if [ $? -eq 1 ]; then
		exit 1;
	fi

	if [ ! -d $test_dir ]; then
		mkdir -p $test_dir;

		./test_RW.sh usb $test_dir $usb_dev

		rm -r $test_dir

		echo "USB IO test finish!"

		umount $usb_mount;
	else
		echo "$test_dir is exist in usb! test cancel!";
		umount $usb_mount;
	fi
fi
