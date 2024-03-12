#!/bin/bash
#set -x

dest_dir=../package/
file_name=libopenssl
file=$dest_dir/$file_name

if [ -e $file ]; then
	if [ -L $file ]; then
		rm -rvf $file
	fi
fi
		

cd $dest_dir
if [ $# = 1 ] ; then
	if [ $1 = 3 ]; then
		echo "use openssl3.x"
		ln -sv ${file_name}3 $file_name
		if [ -e $file_name/${file_name}.mk3 ] ; then
			cd $file_name
			mv ${file_name}.mk{3,}
			cd -
		fi
	else
		echo "use openssl1.x"
		ln -sv ${file_name}1 $file_name
		cd ${file_name}3
		mv ${file_name}.mk{,3}
		cd -
	fi
else
	echo "use default openssl1.x"
	ln -sv ${file_name}1 $file_name
	cd ${file_name}3
	mv ${file_name}.mk{,3}
	cd -
fi
cd -
