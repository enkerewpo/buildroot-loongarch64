################################################################################
#
# autoreboot 
#
################################################################################

AUTOREBOOT_SITE = $(TOPDIR)/package/autoreboot/autoreboot.tar.gz
AUTOREBOOT_SITE_METHOD = file

ifeq ($(BR2_INIT_SYSTEMD),y)
AUTOREBOOT_DEPENDENCIES = busybox systemd
endif

define AUTOREBOOT_EXTRACT_CMDS
	echo $(AUTOREBOOT_SITE)
	tar -zxf $(AUTOREBOOT_SITE) -C $(@D)/
endef


define AUTOREBOOT_BUILD_CMDS
	echo "[build]nothing to do"
endef

define AUTOREBOOT_INSTALL_STAGING_CMDS
	echo "[install_staging]nothing to do"
endef

ifeq ($(BR2_INIT_SYSTEMD),y)
define AUTOREBOOT_INSTALL_TARGET_CMDS
	echo "[install_target]install autoreboot.service"
	
	mkdir -p $(TARGET_DIR)/usr/lib/systemd/system/multi-user.target.wants
	cd $(@D)/autoreboot && cp autoreboot.service $(TARGET_DIR)/usr/lib/systemd/system/
	cd $(TARGET_DIR)/usr/lib/systemd/system/multi-user.target.wants && ln -b -s ../autoreboot.service autoreboot_service
	mkdir -p $(TARGET_DIR)/opt
	cd $(@D)/autoreboot && cp autoreboot.sh $(TARGET_DIR)/opt
endef
else
define AUTOREBOOT_INSTALL_TARGET_CMDS
	echo "[install_target][busybox] nothing to do"
endef
endif

#define BUILD_AUTOREBOOT_ADD_TLS_LINK
#	mkdir -p $(TARGET_DIR)/usr/lib64/tls; cd $(TARGET_DIR)/usr/lib64/tls; if ! test -L loongarch ; then ln -s ../../lib64/ loongarch; fi
#endef
#
#AUTOREBOOT_TARGET_FINALIZE_HOOKS += BUILD_AUTOREBOOT_ADD_TLS_LINK

$(eval $(generic-package))
