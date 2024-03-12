#! /bin/sh

eth_dev_name="eth0"
head_line_target=`ifconfig -a | grep "lo" | tr -s ' ' | cut -d ' ' -f2`
get_eth_dev_name()
{
	eth_dev_name=`ifconfig -a | grep $head_line_target | grep -v lo | grep -v can | grep -v usb | grep -v sit | tr -s ' ' | cut -d ' ' -f1 | head -$1 | tail -1`
}

ifconfig $eth_dev_name 10.120.1.136 netmask 255.255.255.0

