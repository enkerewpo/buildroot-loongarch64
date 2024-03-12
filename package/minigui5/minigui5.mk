################################################################################
#
# minigui5
#
################################################################################

ifeq ($(BR2_mipsel),y)

ifeq ($(BR2_TOOLCHAIN_EXTERNAL_GCC_4_9),y)
MINIGUI5_SITE = $(TOPDIR)/package/minigui5/minigui5-$(BR2_ARCH)_49.tar.gz
else
MINIGUI5_SITE = $(TOPDIR)/package/minigui5/minigui5-$(BR2_ARCH)_49.tar.gz
endif

else
MINIGUI5_SITE = $(TOPDIR)/package/minigui5/minigui5-$(BR2_ARCH)_49.tar.gz
endif
MINIGUI5_SITE_METHOD = file
MINIGUI5_DEPENDENCIES = zlib icu libpng jpeg freetype harfbuzz libdrm mtdev kmod udev libinput sqlite pixman

MINIGUI5_INSTALL_STAGING = YES
MINIGUI5_INSTALL_TARGET = YES

MINIGUI5_EX_PATH = $(BUILD_DIR)/minigui5-install

define MINIGUI5_EXTRACT_CMDS
	echo "see        "$(BR2_TOOLCHAIN_EXTERNAL_GCC_4_9)
	echo "see        "$(MINIGUI5_SITE)
	tar -zxf $(MINIGUI5_SITE) -C $(BUILD_DIR)/
endef

define MINIGUI5_CONFIGURE_CMDS
	echo "nothing to do"
endef

define MINIGUI5_BUILD_CMDS
	echo "nothing to do"
endef

define MINIGUI5_INSTALL_TARGET_CMDS
	cd $(MINIGUI5_EX_PATH) && cp ./etc/* $(TOPDIR)/output/target/etc && mkdir -p $(TOPDIR)/output/target/usr/local/share && cp ./lib/* $(TOPDIR)/output/target/usr/lib && cp -a ./share/* $(TOPDIR)/output/target/usr/local/share && cp -a ./minigui-sample/ $(TOPDIR)/output/target/home
endef
# Must be last so can override all options set by Buildroot

$(eval $(generic-package))

