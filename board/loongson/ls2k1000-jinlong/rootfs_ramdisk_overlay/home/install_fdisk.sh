#! /bin/sh

disk_size=0
disk_size_root=0
disk_size_data=0
disk_size_swap=2
disk_size_backup=4
disk_size_ex_swap=0
disk_size_root_and_data=0

#读取SSD的大小
read_disk_size()
{
	disk_size=$(fdisk -l | grep "Disk /dev/sda" | cut -d ' ' -f3);
	disk_size_ex_swap=$(($disk_size-$disk_size_swap));
}

#不是16G的盘，那么root和data 1 2分(整数) 多的就给root
split_root_and_data()
{
	disk_size_root=0
	disk_size_data=0
	while [ $disk_size_root_and_data -ge 3 ]
	do
		disk_size_root=$(($disk_size_root+1))
		disk_size_data=$(($disk_size_data+2))
		disk_size_root_and_data=$(($disk_size_root_and_data-3))
	done
	disk_size_root=$(($disk_size_root+$disk_size_root_and_data))
}

#这是开始格式化分区的函数
#注意分区的数字需要参数传入，否则不能识别
fdisk_run_four_part()
{
	fdisk /dev/sda >/dev/null << !
d
1
d
2
d
3
d
4

n
p
1

+$1G

n
p
2

+$2G

n
p
3

+$3G

n
p
4



t
3
82

p

w
!
}


#分析4分区, 不包括乒乓系统
analy_four_part()
{
	#16G的特别对待，保证root能装满系统
	if [ $disk_size -le 16 ]; then
		disk_size_root=6
		disk_size_data=3
	else
		disk_size_root_and_data=$(($disk_size_ex_swap-$disk_size_backup))
		split_root_and_data;
	fi
}

#分析4分区，包括乒乓系统
analy_pingpang()
{
	if [ $disk_size -le 16 ]; then
		disk_size_root=4
		disk_size_data=2
	else
		#/2会向下取整，也就是bakcup的大小 >= root+data
		disk_size_root_and_data=$(($disk_size_ex_swap/2))
		split_root_and_data;
	fi
}

#fdisk_four_part 不包括4分区
#fidks_pingpang 包括4分区
#这两个函数都是接口。

fdisk_four_part()
{
	read_disk_size;
	analy_four_part;
	fdisk_run_four_part $disk_size_root $disk_size_data $disk_size_swap;
}

fdisk_pingpang()
{
	read_disk_size;
	analy_pingpang;
	fdisk_run_four_part $disk_size_root $disk_size_data $disk_size_swap;
}

if [ $1 -eq 0 ]; then
	fdisk_four_part;
elif [ $1 -eq 1 ]; then
	fdisk_pingpang;
fi