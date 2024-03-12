#! /bin/bash

host_dir="../output/host"
host_file_name="host.tar.gz"
host_file="../output/$host_file_name"

if [ ! -d $host_dir ]; then
	echo "not found host dir($host_dir)!!!"
	exit 0;
fi

cur_path=$PWD

echo "start zip host cross compile env"
cd ../output/host
cd $(ls | grep buildroot)
cd sysroot/usr/

if [ -d host ]; then
	rm -rf ./host
fi
mkdir host
cp -a ./include ./lib ./lib64 ./share ./libexec ./host
tar -zcf $host_file_name host
rm -rf ./host
mv $host_file_name $cur_path
cd $cur_path
echo "zip env finish!"

#mv $host_file ./

echo "unzip $host_file_name"
tar -zxf $host_file_name

toolchain_path=$(cat ../configs/$2 | grep BR2_TOOLCHAIN_EXTERNAL_PATH | cut -d "=" -f 2)

echo $toolchain_path > temp-path.txt
sed -i 's/^.//' temp-path.txt
sed -i 's/.$//' temp-path.txt
toolchain_path=$(cat temp-path.txt)
rm temp-path.txt

pwd_path=$PWD

echo "to delete all gcc lib"
cd ./host/lib64
#cd $(ls | grep buildroot)
#cd sysroot/usr/lib64
rm -r $(ls $toolchain_path/sysroot/usr/lib64)

cd ../include
rm -r $(ls $toolchain_path/sysroot/usr/include)

cd $pwd_path

rm -r $host_file_name

echo "re zip package"
tar -zcf $host_file_name host

rm -rf ./host

if [ $# -eq 2 ]; then
	mv $host_file_name ./$1
fi

