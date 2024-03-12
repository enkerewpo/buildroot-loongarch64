################################################################################
#
# ls-usb-mount
#
################################################################################

LS_USB_MOUNT_SITE = $(TOPDIR)/package/ls-usb-mount/ls-usb-mount.tar.gz
LS_USB_MOUNT_SITE_METHOD = file

define LS_USB_MOUNT_EXTRACT_CMDS
	echo $(LS_USB_MOUNT_SITE)
	tar -zxf $(LS_USB_MOUNT_SITE) -C $(@D)/
endef

ifeq ($(BR2_PACKAGE_LS_USB_MOUNT_DELAY),y)
define LS_USB_MOUNT_DELAY_LOAD_SETUP
	cd $(@D) && $(SED) 's/#sleep 5/sleep 5/g' usb_probe.sh
endef
endif

define LS_USB_MOUNT_BUILD_CMDS
	echo "create module_load_install.sh"
	cd $(@D) && cp usb_probe_ori.sh usb_probe.sh
	$(LS_USB_MOUNT_DELAY_LOAD_SETUP)
endef

define LS_USB_MOUNT_INSTALL_STAGING_CMDS
	echo "nothing to do"
endef

define LS_USB_MOUNT_INSTALL_TARGET_CMDS
	echo "install usb auto mount shell"
	mkdir -p $(TARGET_DIR)/etc/init.d
	cd $(@D) && chmod a+x ./S89_usb_mount && cp S89_usb_mount $(TARGET_DIR)/etc/init.d
	mkdir -p $(TARGET_DIR)/root/init_shell
	cd $(@D) && chmod a+x usb_probe.sh && cp usb_probe.sh $(TARGET_DIR)/root/init_shell/
endef

$(eval $(generic-package))
