Buildroot is a simple, efficient and easy-to-use tool to generate embedded
Linux systems through cross-compilation.

The documentation can be found in docs/manual. You can generate a text
document with 'make manual-text' and read output/docs/manual/manual.text.
Online documentation can be found at http://buildroot.org/docs.html

To build and use the buildroot stuff, do the following:

1) run 'make menuconfig'
2) select the target architecture and the packages you wish to compile
3) run 'make'
4) wait while it compiles
5) find the kernel, bootloader, root filesystem, etc. in output/images

You do not need to be root to build or run buildroot.  Have fun!

Buildroot comes with a basic configuration for a number of boards. Run
'make list-defconfigs' to view the list of provided configurations.

Please feed suggestions, bug reports, insults, and bribes back to the
buildroot mailing list: buildroot@buildroot.org
You can also find us on #buildroot on OFTC IRC.

If you would like to contribute patches, please read
https://buildroot.org/manual.html#submitting-patches

以上是buildroot官方的README内容

下面将是广东龙芯针对buildroot做出的修改而修订的README内容

此份buildroot源码包括以下**功能的修改/新增：**

* 添加广东龙芯系列板卡的文件系统编译配置
* 添加对LoongArch64的架构的支持
* 添加部分源码包的编译(minigui环境支持、lvgl环境支持等)
* 添加龙芯嵌入式测试软件的包
* 添加龙芯SSD下的文件系统部署所用到的ramdisk编译支持

本源码需要在x86上的linux环境下编译
推荐编译条件为:

| 环境           |       推荐       |
| -------------  | ---------------- |
| 操作系统       | ubuntu 18.04     |
| 交叉编译工具链 | loongarch64: toolchain-loongarch64-linux-gnu-gcc8-host-x86_64-2022-07-18</br>mips64el:mips64el-linux-gcc-8.x</br>部署于/opt下，可从资料包中获取 |
| 硬盘容量       | 需要预留**20G或以上的空间**给buildroot存放编译中间文件 |
| 运行机器       | x86 机器，建议为多核，推荐在服务器上编译，个人电脑编译时间较长且占用大量空间 |

关于依赖环境，可以参考下面的命令进行安装，如果还是存在不能编译的情况，还请按照实际情况进行依赖环境的准备。
```
sudo apt -y install make git gcc g++ bison flex libncurses5-dev libssl-dev libelf-dev
sudo apt -y install cmake tree build-essential tcl-dev automake libtool
```

通过上述的官方说明可以清楚编译的流程是：

1. 生效要编译的配置(make XXX_defconfig)
2. make -j24 (-j24 指调用多少cpu核进行编译，根据实际的cpu核数而定，也可以只是make)
3. 前往./output/image 文件夹得到产出的文件系统进行文件

编译产出的文件为文件系统的镜像文件
可用的是rootfs.tar.gz 和 rootfs.ubi

| 文件           |       说明       |
| -------------  | ---------------- |
| rootfs.tar.gz  | ssd要用的文件系统镜像     |
| rootfs.ubi     | nand要用的文件系统镜像，根据龙芯板卡的烧录规则，还需要**改名为rootfs-ubifs-ze.img** |

关于如何定制buildroot的内容本处不再赘述，可以查看用户手册的 **12.2.1.1. buildroot简述** 一节，当然还推荐直接查阅官方手册。

编译产出的系统分为以下几种

| 系统类型        | 说明                   |
| --------------- | ---------------------  |
| 全量系统        | 和用户手册中说的busybox系统是一个概念，集成了相当部分的软件包 |
| 小型系统        | 只保留部分软件包，例如可用于外围电路测试软件，网络测试软件的系统，可用于验证板卡功能 |
| ramdisk         | 和广东龙芯板卡相关的SSD中系统的安装引导系统的构建</br>本质是一个busybox系统启动时运行安装系统的程序 |
| 快速启动系统    | 和全量系统一致，但是改为busybox启动，同时第一次启动之后的启动都会不启动其他服务</br>为了加快从内核到文件系统的速度</br>实测在ls2k500，如果busybox启动下，全部服务启动则需要4s，禁用服务之后，只需要1.8s </br> 如果想恢复服务，那么请把/root/init.d-bak里面的内容复制到/etc/init.d即可 |


全量系统的编译配置

| 板卡配置名                                   | 对应适用板卡           |
| -------------------------------------------- | ---------------------  |
| loongson2k1000_jinlong_defconfig             | ls2k1000mips版本的金龙板卡<br>或者其他ls2k1000mips版本的板卡<br>通用配置（以后可能改名） |
| loongson2k1000_LA_jinlong_defconfig          | ls2k1000LA版本的金龙板卡<br>或者其他ls2k1000LA版本的板卡<br>通用配置（以后可能改名） |
| loongson2k500_defconfig                      | ls2k500的板卡<br>通用配置（串口2作为调试串口） |
| loongson2k500_mini_dp_defconfig              | ls2k500的mini开发板卡<br>通用配置（串口2作为调试串口） |

小型系统的编译配置

| 板卡配置名                                   | 对应适用板卡           |
| -------------------------------------------- | ---------------------  |
| loongson2k1000_jinlong_mini_defconfig        | ls2k1000mips版本的金龙板卡<br>或者其他ls2k1000mips版本的板卡<br>小型系统通用配置（以后可能改名） |
| loongson2k1000_LA_jinlong_mini_defconfig     | ls2k1000LA版本的金龙板卡<br>或者其他ls2k1000LA版本的板卡<br>小型系统通用配置（以后可能改名） |
| loongson2k500_mini_defconfig                 | ls2k500的板卡<br>小型系统通用配置（串口2作为调试串口） |
| loongson2k500_mini_dp_mini_defconfig         | ls2k500的mini开发板卡<br>小型系统通用配置（串口2作为调试串口） |

ramdisk的编译配置

| 板卡配置名                                   | 对应适用板卡           |
| -------------------------------------------- | ---------------------  |
| loongson2k1000_LA_jinlong_ramdisk_defconfig  | ls2k1000LA版本的金龙板卡<br>或者其他ls2k1000LA版本的板卡<br>ramdisk编译通用配置（以后可能改名） |
| loongson2k500_ramdisk_defconfig              | ls2k500的板卡<br>ramdisk编译通用配置（串口2作为调试串口） |

快速启动系统的编译配置

| 板卡配置名                                   | 对应适用板卡           |
| -------------------------------------------- | ---------------------  |
| loongson2k1000_LA_jinlong_fastboot_defconfig | ls2k1000LA版本的金龙板卡<br>或者其他ls2k1000LA版本的板卡<br>快速启动系统通用配置（以后可能改名） |
| loongson2k500_fastboot_defconfig             | ls2k500的板卡<br>快速启动系统通用配置（串口2作为调试串口） |
| loongson2k500_mini_dp_fastboot_defconfig     | ls2k500的mini开发板卡<br>快速启动系统通用配置（串口2作为调试串口） |
