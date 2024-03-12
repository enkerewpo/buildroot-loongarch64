echo " ";
echo "*************************************************************************"
echo "*********************************STARG 3*********************************"
echo "*******************this stage for check log and reboot*******************"
echo "*************************************************************************"
echo " ";

# sda1 / 	usb1
# sda2 data usb2
# sda3 swap usb3
# sda4 backup usb4

#防止前面的脚本出现错误，导致没有解除挂载一些已经挂载的分区。
check_and_umount_for_safe()
{
	for i in /mnt/usb*; do
	{
		if mountpoint -q i; then
			sync;
			umount i;
		fi
	}
	done
}

#防止前面的脚本出现错误，导致没有解除挂载一些已经挂载的分区。
check_and_umount_for_safe;
/home/sys_config_tool

echo "-------------> stage3 install system finish! please reboot or shutdowm! <-------------"
reboot -f

echo "-------------> stage3 end <-------------"
