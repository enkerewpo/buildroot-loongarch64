#! /bin/sh

#shell_info_start
#name:PWM DO test
#type:interface
#mul:0
#desc:PWM DO test
#board:LS2K500-MODI_HCT
#shell_info_end

pwm0_DO_num=1
pwm0_DO_result=1
pwmchip0_dir_path="/sys/class/pwm/pwmchip0"
pwm0_dev_path="$pwmchip0_dir_path/pwm0"

pwm1_DO_num=3
pwm1_DO_result=1
pwmchip1_dir_path="/sys/class/pwm/pwmchip1"
pwm1_dev_path="$pwmchip1_dir_path/pwm0"

pwm2_DO_num=5
pwm2_DO_result=1
pwmchip2_dir_path="/sys/class/pwm/pwmchip2"
pwm2_dev_path="$pwmchip2_dir_path/pwm0"

pwm3_DO_num=7
pwm3_DO_result=1
pwmchip3_dir_path="/sys/class/pwm/pwmchip4"
pwm3_dev_path="$pwmchip3_dir_path/pwm0"

pwm_polarity="normal"

pwm_tip="1KHz"
pwm_period=1000000
pwm_duty_cycle_1=0
pwm_duty_cycle_2=5000
pwm_duty_cycle_3=250000
pwm_duty_cycle_4=500000
pwm_duty_cycle_5=750000
pwm_duty_cycle_6=1000000

export_pwm_single()
{
	echo 0 > $1"/export";
}

export_all_pwm()
{
	export_pwm_single $pwmchip0_dir_path;
	export_pwm_single $pwmchip1_dir_path;
	export_pwm_single $pwmchip2_dir_path;
	export_pwm_single $pwmchip3_dir_path;
}

unexpoer_pwm_single()
{
	echo 0 > $1"/unexport";
}

unexport_all_pwm()
{
	if [ -d $pwm0_dev_path ]; then
		unexpoer_pwm_single $pwmchip0_dir_path;
	fi
	if [ -d $pwm1_dev_path ]; then
		unexpoer_pwm_single $pwmchip1_dir_path;
	fi
	if [ -d $pwm2_dev_path ]; then
		unexpoer_pwm_single $pwmchip2_dir_path;
	fi
	if [ -d $pwm3_dev_path ]; then
		unexpoer_pwm_single $pwmchip3_dir_path;
	fi
}

enable_pwm()
{
	echo 1 > $1"/enable" 2>/dev/null;
}

disenale_pwm()
{
	echo 0 > $1"/enable" 2>/dev/null;
}

set_period()
{
	echo $1 > $2"/period" 2>/dev/null;
}

set_duty_cycle()
{
	echo $1 > $2"/duty_cycle" 2>/dev/null;
}

setup_single_pwm_property()
{
	set_duty_cycle 1 $3
	set_period $1 $3
	set_duty_cycle $2 $3 #重复设置，因为会出现大小不符合的时候就会提示错误，重复设置就可以避免因错误而写不进去的问题

	enable_pwm $3;
}

setup_all_pwm_property()
{
	echo ""
	disenale_pwm $pwm0_dev_path
	disenale_pwm $pwm1_dev_path
	disenale_pwm $pwm2_dev_path
	disenale_pwm $pwm3_dev_path
	sleep 1;

	setup_single_pwm_property $1 $2 $pwm0_dev_path
	setup_single_pwm_property $1 $2 $pwm1_dev_path
	setup_single_pwm_property $1 $2 $pwm2_dev_path
	setup_single_pwm_property $1 $2 $pwm3_dev_path

	loop_read=1

	while [ $loop_read -eq 1 ];
	do
		echo -n "observer signal is standard?(y or n): "
		read result

		case $result in
			"y")
				return 0 ;;
			"n")
				return 1 ;;
		esac
	done
}

test_single_duty_cycle()
{
	rate_pwm=`awk 'BEGIN{printf "%.2f%\n",('$2'/'$1')*100}'`
	echo "set all pwm duty cycle: "$2" ($rate_pwm)";
	setup_all_pwm_property $1 $2;
}

start_test()
{
	echo "set all pwm Hz: "$pwm_tip;
	echo "set all pwm period: "$pwm_period;

	test_single_duty_cycle $pwm_period $pwm_duty_cycle_1
	test_single_duty_cycle $pwm_period $pwm_duty_cycle_2
	test_single_duty_cycle $pwm_period $pwm_duty_cycle_3
	test_single_duty_cycle $pwm_period $pwm_duty_cycle_4
	test_single_duty_cycle $pwm_period $pwm_duty_cycle_5
	test_single_duty_cycle $pwm_period $pwm_duty_cycle_6
}

run()
{
	unexport_all_pwm;

	export_all_pwm;

	start_test;

	unexport_all_pwm;

	echo "test finish"
}

./MS8844_setup.sh 1 >/dev/null
run;
./MS8844_setup.sh 0 >/dev/null
