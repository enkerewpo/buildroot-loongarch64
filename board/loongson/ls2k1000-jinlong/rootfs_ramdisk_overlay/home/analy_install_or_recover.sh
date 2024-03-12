#! /bin/sh

cmdline="";
flag="";
recover_flag="recover_system=1"

read_cmdLine()
{
	cmdline=$(cat "/proc/cmdline")
}

analy_cmdline()
{
	flag=$(echo $cmdline | tr -s " " | rev | cut -d " " -f1 | rev);
	if [ $flag == $recover_flag ]; then
		echo "Recover System!!!"
		/home/recover_backup.sh
	else
		echo "Install System To SSD!!!"
		/home/install_usb.sh
	fi
}

read_cmdLine;
analy_cmdline;
