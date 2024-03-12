#! /bin/sh

#shell_info_start
#name:DO output enable
#type:config
#args:1
#args_tip:enable all DO output
#args:0
#args_tip:disable all DO output
#board:LS2K500-MODI_HCT
#shell_info_end

res=0
o4_gpio_dir="/sys/class/gpio/gpio1"
o1_gpio_dir="/sys/class/gpio/gpio38"
o2_gpio_dir="/sys/class/gpio/gpio37"
o3_gpio_dir="/sys/class/gpio/gpio36"

export_gpio()
{
    if [ ! -d $1 ]; then
        echo $2 > /sys/class/gpio/export
        if [ $? -ne 0 ]; then
            echo "export gpio $2 failed!"
            return 1
        fi
    fi
}

set_output()
{
    if [ -d $1 ]; then
        echo out > $1"/direction"
        echo $2 > $1"/value"
    else
        echo "not found $1, setup gpio failed!"
        return 1
    fi
}

config_gpio()
{
    export_gpio $1 $2
    if [ $? -ne 0 ]; then
        return 1
    fi
    set_output $1 $3
    if [ $? -ne 0 ]; then
        return 1
    fi
}

config_all_gpio()
{
    res=0
    config_gpio $o4_gpio_dir 1 $1
    if [ $? -ne 0 ]; then
        res=1
    fi
    config_gpio $o1_gpio_dir 38 $1
    if [ $? -ne 0 ]; then
        res=1
    fi
    config_gpio $o2_gpio_dir 37 $1
    if [ $? -ne 0 ]; then
        res=1
    fi
    config_gpio $o3_gpio_dir 36 $1
    if [ $? -ne 0 ]; then
        res=1
    fi
    if [ $res -ne 0 ]; then
        return 1
    fi
}

config_all_gpio $1
if [ $? -eq 0 ]; then
    echo "operate success!"
else
    echo "operate failed!"
fi
