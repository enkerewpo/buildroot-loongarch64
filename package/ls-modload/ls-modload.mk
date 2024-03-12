################################################################################
#
# boot_run
#
################################################################################

LS_MODLOAD_SITE = $(TOPDIR)/package/ls-modload/ls-modload.tar.gz
LS_MODLOAD_SITE_METHOD = file

define LS_MODLOAD_EXTRACT_CMDS
	echo $(LS_MODLOAD_SITE)
	tar -zxf $(LS_MODLOAD_SITE) -C $(@D)/
endef

ifeq ($(BR2_PACKAGE_LS_MODLOAD_DELAY),y)
define LS_MODLOAD_DELAY_LOAD_SETUP
	cd $(@D) && $(SED) 's/#sleep 5/sleep 5/g' module_load_install.sh
endef
endif

ifeq ($(BR2_PACKAGE_LS_MODLOAD_ALL),y)

define LS_MODLOAD_BUILD_CMDS
	echo "create module_load_install.sh"
	cd $(@D) && cp module_load_all.sh module_load_install.sh
	$(LS_MODLOAD_DELAY_LOAD_SETUP)
endef

else
define LS_MODLOAD_BUILD_CMDS
	echo "create module_load_install.sh"
	cd $(@D) && cp module_load.sh module_load_install.sh
	$(LS_MODLOAD_DELAY_LOAD_SETUP)
endef

endif

define LS_MODLOAD_INSTALL_STAGING_CMDS
	echo "nothing to do"
endef

define LS_MODLOAD_INSTALL_TARGET_CMDS
	echo "install boot_run.service and boot_run.sh"
	mkdir -p $(TARGET_DIR)/etc/init.d
	cd $(@D) && chmod a+x ./S09modload && cp S09modload $(TARGET_DIR)/etc/init.d
	mkdir -p $(TARGET_DIR)/root/init_shell
	cd $(@D) && chmod a+x module_load_install.sh && cp module_load_install.sh $(TARGET_DIR)/root/init_shell/module_load.sh
endef

$(eval $(generic-package))
