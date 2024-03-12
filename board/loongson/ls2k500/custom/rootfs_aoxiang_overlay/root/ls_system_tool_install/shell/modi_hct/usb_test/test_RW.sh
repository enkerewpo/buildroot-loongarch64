#! /bin/sh

#通用测试RW指令脚本
#参数1 测试的类型 这个可以随意 比如我要测SSD 可以是SSD 也可以是SSD2 无所谓
#参数2 测试的文件夹，为了数据安全，所以需要指定一个测试用的文件夹
#参数3 测试的设备文件 比如 /dev/sda

#同时，如果要测试USB，那么这个脚本不包挂载等事项，请上层脚本先挂载好，然后再调用此脚本。

test_dir="";
test_name="";

test_base_path="/home"

md5_file_temp_path=$test_base_path
md5_file_temp=$md5_file_temp_path"/md5_ls_check"

big_file_prepare_path="$test_base_path""/loongson_pre_test_big_file_dir"
big_file_prepare_other_path="/media/loongson_pre_test_big_file_dir"
big_file_prepare_name=$big_file_prepare_path"/testbig"

cp_file_cmd()
{
	mode=2;
	if [ $mode -eq 1 ]; then
		chmod a+x ./cp
		./cp -ig $1 $2
	fi
	if [ $mode -eq 2 ]; then
		dd if=$1 of="$2" conv=fsync
	fi
}

md5_check_cmd()
{
	md5sum $1 $2 > $md5_file_temp
	md5sum -c $md5_file_temp --quiet
	md5_res=$?
	rm $md5_file_temp
	if [ $md5_res -eq 0 ]; then
		echo "md5 check success"
		return 0
	else
		echo "md5 check failed"
		return 1
	fi
}

dd_new_file()
{
	echo "prepare a $2""M file"
	if [ -e /dev/urandom ]; then
		dd if=/dev/urandom of=$1 conv=fsync bs=1M count=$2 2>/dev/null
	else
		dd if=/dev/zero of=$1 conv=fsync bs=1M count=$2 2>/dev/null
	fi
}

prepare_file()
{
	if [ ! -d $big_file_prepare_path ]; then
		mkdir -p $big_file_prepare_path >/dev/null
	fi
	dd_new_file $big_file_prepare_name 100
	sync;
}

test_big_read()
{
	sync;
	sleep 1
	cp_file_cmd $test_name $big_file_prepare_name
	md5_check_cmd $test_name $big_file_prepare_name
	rm $big_file_prepare_name
	rm $test_name
	sync && echo 3 > /proc/sys/vm/drop_caches
	sync;
}

test_big_write()
{
	sync;
	cp_file_cmd $big_file_prepare_name $test_name
	md5_check_cmd $test_name $big_file_prepare_name
	rm $big_file_prepare_name
	sync && echo 3 > /proc/sys/vm/drop_caches
	sync
}

test_mode1_rootfs_big()
{
	if [ $# -eq 3 ]; then
		test_dir=$2
		test_name=$test_dir"/testbig"

		if [ ! -d $test_base_path ]; then
			mkdir -p $test_base_path
		fi

		prepare_file
		echo "---------------------------------------"
		echo "test big file write"
		test_big_write;
		echo "---------------------------------------"
		echo "test big file read"
		test_big_read;
		echo "---------------------------------------"

		rm -r $big_file_prepare_path
		if [ -d $big_file_prepare_other_path ]; then
			rm -r $big_file_prepare_other_path
		fi

		# echo "test small file write and read"
		# "$PWD/test_small_file.sh" $1 $2 $3 1
		# echo "---------------------------------------"
	fi
}

test_start()
{
	test_mode1_rootfs_big $1 $2 $3
}

test_start $1 $2 $3
