HuoLong

Intro
=====

This default configuration will allow you to start experimenting with the
buildroot environment for the HuoLong. With the current configuration
it will bring-up the board, and allow access through the serial console.

How to build it
===============

Configure Buildroot:

    $ make ls1b20_huolong_volp_defconfig

Compile everything and build the system:

    $ make

How to install system
========================

you can use {buildroot}/output/images/rootfs.ubi
to install in nand by uboot function
remember rootfs.ubi rename rootfs-ubifs-ze.img
