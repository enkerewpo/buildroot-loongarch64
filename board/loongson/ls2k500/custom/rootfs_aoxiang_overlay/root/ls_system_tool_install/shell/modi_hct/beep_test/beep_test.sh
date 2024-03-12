#! /bin/sh

#shell_info_start
#name:beep test
#type:interface
#board:LS2K500-MODI_HCT
#shell_info_end

beep_path="/sys/class/leds/buzz-pwm"
max_value=$beep_path"/max_brightness"
cur_value=$beep_path"/brightness"

check_env()
{
	if [ ! -d $beep_path ]; then
		echo "not find beep control path : $beep_path"
		return 1
	fi
	return 0
}

test()
{
	value=$(cat $max_value)
	if [ $value -lt 2 ]; then
		echo "error: pwm level($value) not support beep work"
		return 1
	fi
	value=$(($value / 2))
	echo "beep will work 1s"
	echo $value > $cur_value
	sleep 1
	echo "beep stop work"
	echo 0 > $cur_value
	return 0
}

check_env
if [ $? -ne 0 ]; then
	exit 1
fi
test
if [ $? -ne 0 ]; then
	exit 1
fi
