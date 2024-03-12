#! /bin/sh

base_num=0
base_num_pwm=0

test_EN1=38
test_EN2=37
test_EN3=36
test_EN4=1

test_EN_DO1=1;
test_EN_DO2=1;
test_EN_DO3=1;
test_EN_DO4=1;

test_DO_mode=1
pwm_class_dir="/sys/class/pwm/pwmchip0"

generate_export_num()
{
	test_EN_DO1=$(($test_EN12+$base_num));
	test_EN_DO2=$(($test_EN34+$base_num));
	test_EN_DO3=$(($test_EN56+$base_num));
	test_EN_DO4=$(($test_EN78+$base_num));
}

export_gpio_single()
{
	if [ -d "gpio""$1" ]; then
		echo $1 > ./unexport
	fi
	echo $1 > ./export
	echo out > ./"gpio""$1"/direction
}

export_all_gpio()
{
	cd /sys/class/gpio

	export_gpio_single $test_EN_DO1
	export_gpio_single $test_EN_DO2
	export_gpio_single $test_EN_DO3
	export_gpio_single $test_EN_DO4

	cd - >/dev/null
}

unexport_gpio_single()
{
	if [ -d "gpio""$1" ]; then
		echo $1 > ./unexport
	fi
}

unexport_all_gpio()
{
	cd /sys/class/gpio

	unexport_gpio_single $test_EN_DO1
	unexport_gpio_single $test_EN_DO2
	unexport_gpio_single $test_EN_DO3
	unexport_gpio_single $test_EN_DO4

	cd - >/dev/null
}

set_gpio_value_single()
{
	if [ -d "gpio""$1" ]; then
		if [ $4 -ne 1 ]; then
			echo "set DO"$3" value: "$2
		fi
		echo $2 > ./"gpio""$1"/value
	else
		echo "error! not export DO, couldnt set DO value"
	fi
}

disable_all_output()
{
	cd /sys/class/gpio

	set_gpio_value_single $test_EN_DO1 0 "EN12" 1
	set_gpio_value_single $test_EN_DO2 0 "EN34" 1
	set_gpio_value_single $test_EN_DO3 0 "EN56" 1
	set_gpio_value_single $test_EN_DO4 0 "EN78" 1

	cd - >/dev/null
}

enable_all_output()
{
	cd /sys/class/gpio

	set_gpio_value_single $test_EN_DO1 1 "EN12" 1
	set_gpio_value_single $test_EN_DO2 1 "EN34" 1
	set_gpio_value_single $test_EN_DO3 1 "EN56" 1
	set_gpio_value_single $test_EN_DO4 1 "EN78" 1

	cd - >/dev/null
}

generate_export_num;
export_all_gpio;

if [ $1 -eq 1 ]; then
	enable_all_output;
else
	disable_all_output;
fi

unexport_all_gpio;
