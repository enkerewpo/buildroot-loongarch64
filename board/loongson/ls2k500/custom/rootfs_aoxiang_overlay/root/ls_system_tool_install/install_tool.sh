#! /bin/sh

cmd_version_name="ls_system_tool"
shell_dir_name="shell"
shell_dir="./$shell_dir_name"

sofeware_target_dir="/usr/bin"
shell_target_dir="/opt/ls_system_config"

sudo_exist=1;

check_env()
{
	if [ ! -f $cmd_version_name ]; then
		echo "error: not found cmd version ls_system_tool"
		echo "       cur check dir is : $PWD"
		return 1
	fi
	if [ ! -d $shell_dir ]; then
		echo "warning: not found $shell_dir"
	fi

	whereis sudo | grep /
	if [ $? -ne 0 ]; then
		sudo_exist=0;
	fi
}

install()
{
	if [ -f $cmd_version_name ]; then
		echo "install sofeware $cmd_version_name ..."
		if [ $sudo_exist -eq 1 ]; then
			sudo cp $cmd_version_name $sofeware_target_dir
		else
			cp $cmd_version_name $sofeware_target_dir
		fi
		echo "install sofeware finish"
	fi
	if [ -d $shell_dir ]; then
		echo "install $shell_dir to $shell_target_dir ..."
		if [ $sudo_exist -eq 1 ]; then
			sudo mkdir -p $shell_target_dir
		else
			mkdir -p $shell_target_dir
		fi

		# delete shell dir
		if [ -d $shell_target_dir"/$shell_dir_name" ]; then
			if [ $sudo_exist -eq 1 ]; then
				sudo rm -rf "$shell_target_dir/$shell_dir_name"
			else
				rm -rf "$shell_target_dir/$shell_dir_name"
			fi
		fi

		if [ $sudo_exist -eq 1 ]; then
			sudo cp -a $shell_dir $shell_target_dir
		else
			cp -a $shell_dir $shell_target_dir
		fi
		echo "install $shell_dir finish"
	fi
}

start()
{
	check_env
	if [ $? -ne 0 ]; then
		return 1
	fi

	install;

	echo "success"
}

start
