#! /bin/sh

bak_config_name="bak_LA64_config"
bak_config_dir=""
new_config_dir="./LA64_config_arch"

check_dir1="/usr/share/misc/"
check_dir2="../support/gnuconfig/"

target=""

check_and_update()
{
	target=`cat $1/config.sub | grep loongarch | head -n1`
	if [ -z "$target" ]; then
		bak_config_dir="$1/$bak_config_name"
		if [ ! -d $bak_config_dir ]; then
			sudo mkdir $bak_config_dir
			sudo mv "$1/config.guess" "$1/config.sub" "$bak_config_dir/"
		fi
		sudo cp "$new_config_dir/config.guess" "$new_config_dir/config.sub" $1
	fi
}

check_and_update_no_root()
{
        target=`cat $1/config.sub | grep loongarch | head -n1`
        if [ -z "$target" ]; then
                bak_config_dir="$1/$bak_config_name"
                if [ ! -d $bak_config_dir ]; then
                        mkdir $bak_config_dir
                        mv "$1/config.guess" "$1/config.sub" "$bak_config_dir/"
                fi
                cp "$new_config_dir/config.guess" "$new_config_dir/config.sub" $1
        fi
}

check_and_update $check_dir1
check_and_update_no_root $check_dir2
echo finish!
