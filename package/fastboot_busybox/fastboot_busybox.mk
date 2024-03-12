################################################################################
#
# fastboot_busybox
#
################################################################################

FASTBOOT_BUSYBOX_SITE = $(TOPDIR)/package/fastboot_busybox/fastboot_busybox.tar.gz
FASTBOOT_BUSYBOX_SITE_METHOD = file

FASTBOOT_BUSYBOX_DEPENDENCIES = git_info_lsgd busybox

define FASTBOOT_BUSYBOX_EXTRACT_CMDS
	echo "extract nothing"
	echo $(FASTBOOT_BUSYBOX_SITE)
	tar -zxf $(FASTBOOT_BUSYBOX_SITE) -C $(@D)/
endef

define FASTBOOT_BUSYBOX_BUILD_CMDS
	echo "build nothing"
endef

define FASTBOOT_BUSYBOX_INSTALL_TARGET_CMDS
	echo "install S99fastboot_ls and new rcK to /etc/init.d";
	cd $(@D) && chmod a+x S99fastboot-ls && cp S99fastboot-ls $(TARGET_DIR)/etc/init.d
	cd $(@D) && cp rcK $(TARGET_DIR)/etc/init.d
endef

$(eval $(generic-package))
