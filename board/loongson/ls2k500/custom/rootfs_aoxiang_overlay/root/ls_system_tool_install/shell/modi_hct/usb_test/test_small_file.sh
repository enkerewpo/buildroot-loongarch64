#! /bin/sh

# 1: 测试的设备类型
# 2: 写的位置
# 3: 测试的设备名字
# 4: 测试类型 0R 1W

test_dev_type=""

test_dir="";

test_dev="";

write_dir_path="";
speed_mark_file_path="/home/loongson_small_file_mark.txt"

small_file_save_dir_name="loongson_test_small_file_dir"

small_file_prepare_path="/home/loongson_pre_test_small_file_dir"
small_file_prepare_other_path="/home/loongson_pre_test_small_file_dir"

small_file_count=1000

small_file_pre_file_front_name="$small_file_prepare_path""file_"

cp_dir_cmd()
{
	mode=1;
	if [ $mode -eq 1 ]; then
		chmod a+x ./cp
		./cp -r -ig $1 $2
		#cp -r $1 $2
	fi
	if [ $mode -eq 2 ]; then
		old_path=$PWD
		if [ ! -d $2 ]; then
			mkdir -p $2
		fi
		cd $1
		for file in $(ls)
		do
			dd if=$file of=$2/$file conv=fsync
		done
		cd $old_path
	fi
}

dd_new_file()
{
	if [ -e /dev/urandom ]; then
		dd if=/dev/urandom of=$1 conv=fsync bs=1M count=$2 2>/dev/null
	else
		dd if=/dev/zero of=$1 conv=fsync bs=1M count=$2 2>/dev/null
	fi
}

prepare_file()
{
	echo "prepare "$small_file_count" small file"
	if [ ! -d $small_file_prepare_path ]; then
		mkdir -p "$small_file_prepare_path"
	fi
	loop=1

	while [ $loop -le $small_file_count ];
	do
		printf "\rprocess: $loop / $small_file_count";
		dd_new_file "$small_file_prepare_path""/file_""$loop" 2
		loop=$(($loop+1));
	done

	echo "";

	sync;
}

test_small_write()
{
	echo "test small file write"
	cp_dir_cmd "$small_file_prepare_path" $write_dir_path
	rm -r "$small_file_prepare_path"
	sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"
}

test_small_read()
{
	sync;
	sleep 1;
	echo "test small file read"
	cp_dir_cmd $write_dir_path "$small_file_prepare_path"
	rm -r "$small_file_prepare_path"
	sudo sh -c "sync && echo 3 > /proc/sys/vm/drop_caches"
}

if [ $# -eq 4 ]; then
	test_dev_type=$1;
	test_dir=$2
	test_dev=$3

	write_dir_path=$test_dir"/"$small_file_save_dir_name"_"$test_dev_type
	if [ -d $write_dir_path ]; then
		echo "Error! exist path:"$write_dir_path" for data safe, this write test stop!";
		exit 1;
	fi

	mkdir -p $write_dir_path;

	prepare_file;

	test_small_write;

	test_small_read;

	rm -r $write_dir_path;

	if [ -d $small_file_prepare_other_path ]; then
		rm -r $small_file_prepare_other_path
	fi
fi
