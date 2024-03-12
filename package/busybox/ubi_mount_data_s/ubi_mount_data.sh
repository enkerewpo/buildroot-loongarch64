#! /bin/sh

mount_point="/home"
mount_disk="ubi1:data"

check_env()
{
    line_num=$(cat /proc/mtd | grep data | wc -l)

    if [ $line_num -eq 0 ]; then
        echo "error: not found about ubi data info!"
        return 1
    fi

    if [ -e "/dev/ubi1" ]; then
        echo "error: /dev/ubi1 already exist!"
        return 2
    fi

    mountpoint -q $mount_point
    if [ $? -eq 0 ]; then
        echo "error: $mount_point already mount!"
        return 3
    fi

    df | grep "$mount_disk" > /dev/null
    if [ $? -eq 0 ]; then
        echo "error: $mount_disk already mount!"
        return 4
    fi

    return 0
}

#sleep 5

mkdir -p $mount_point
check_env

if [ $? -ne 0 ]; then
    exit 1;
fi

mtd_num=$(cat /proc/mtd | grep data | head -n1 | cut -d ' ' -f 1 | sed 's/[^0-9]//g')

mkdir -p $mount_point
echo "nand ubi attch..."
ubiattach -m $mtd_num -d 1
mount -t ubifs $mount_disk $mount_point

if [ $? -ne 0 ]; then
    echo "init ubi data vol"
    ubidetach -d 1
    echo y >> ubi_mount_data_ok
    echo y >> ubi_mount_data_ok
    ubiformat /dev/mtd$mtd_num < ubi_mount_data_ok
    rm ubi_mount_data_ok
    echo "nand ubi attch..."
    ubiattach -m $mtd_num -d 1
    ubimkvol /dev/ubi1 -N data -m

    echo "init ubi dat vol finish"

    mount -t ubifs $mount_disk $mount_point

    if [ $? -ne 0 ]; then
        echo "error: coundlnt mount nand data vol as data part"
    fi
fi

echo "success mount nand data vol as data part"

