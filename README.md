# hvisor linux vm rootfs port

wheatfox 2024.3.12

---

## Build Instructions for 3A5000 hvisor Rootfs

**Note**: This Git repository does not include the `dl` folder in the root directory (which contains compressed source code packages for programs in the rootfs, approximately 2 GB in size). You can let buildroot automatically download them or use the ones I uploaded to baiducloud(not full sources but enough for my defconfig):

[https://pan.baidu.com/s/1sVPRt0JiExUxFm2QiCL_nA?pwd=la64](https://pan.baidu.com/s/1sVPRt0JiExUxFm2QiCL_nA?pwd=la64)

This code is based on Loongson's buildroot adaptation for the 2K1000 board. Updates for 3A5000 adaptation will be made in this repository, intended for mounting a simple rootfs when launching a Linux virtual machine using **hvisor**.

### GCC Requirement

Please use:   `loongarch64-unknown-linux-gnu-gcc`  . Download it here: [https://github.com/sunhaiyong1978/CLFS-for-LoongArch/releases/download/8.0/loongarch64-clfs-8.0-cross-tools-gcc-full.tar.xz](https://github.com/sunhaiyong1978/CLFS-for-LoongArch/releases/download/8.0/loongarch64-clfs-8.0-cross-tools-gcc-full.tar.xz)

### Building the rootfs for 3A5000 hvisor

```bash
make loongson3a5000_hvisor_defconfig

# You can change the GCC path to your own by
# entering menuconfig and adjusting toolchain settings

make menuconfig # This modifies the .config file
# which is the actual configuration used during the build process.

make -j8 # Build the rootfs
```

### Build-Time Logging and Configuration Tips

#### Monitoring Build Progress
The file `output/build/build-time.log` shows which tool is currently being compiled in real-time. Use this file to monitor the build process.

#### Configuration Updates Before Building

Before starting the build process, modify the `.config` file or directly edit `loongson3a5000_hvisor_defconfig` to ensure the toolchain paths and settings are correctly configured.

Update the following fields to match the location and name of your local toolchain:

- **`BR2_TOOLCHAIN_EXTERNAL_PATH`**  
- **Compiler Prefix**

---

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