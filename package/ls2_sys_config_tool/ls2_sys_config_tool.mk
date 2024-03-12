################################################################################
#
# ls2_sys_config_tool
#
################################################################################

LS2_SYS_CONFIG_TOOL_VERSION = origin/master
LS2_SYS_CONFIG_TOOL_SITE = http://10.120.1.5:3000/base/sys_config_tool
LS2_SYS_CONFIG_TOOL_SITE_METHOD = git
LS2_SYS_CONFIG_TOOL_CFLAGS = $(TARGET_CFLAGS)

ifeq ($(BR2_PACKAGE_LS2_SYS_CONFIG_TOOL_QT),y)
LS2_SYS_CONFIG_TOOL_DEPENDENCIES = qt5base
endif

#define LS2_SYS_CONFIG_TOOL_EXTRACT_CMDS
	
#endef

#$(TARGET_MAKE_ENV) $(MAKE) CC=$(TARGET_CC) AR=$(TARGET_AR) -C $(@D)

ifeq ($(BR2_PACKAGE_LS2_SYS_CONFIG_TOOL_QT),y)
define LS2_SYS_CONFIG_TOOL_BUILD_QT_VER_CMDS
	cd $(@D)/Qtver/LS2_SYS_CONFIG_TOOL/ && $(HOST_DIR)/bin/qmake LS2_SYS_CONFIG_TOOL.pro && $(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/Qtver/LS2_SYS_CONFIG_TOOL/
endef
define LS2_SYS_CONFIG_TOOL_INSTALL_QT_VER_CMDS
	echo "install Qt version sofeware" && cd $(@D)/Qtver/LS2_SYS_CONFIG_TOOL/ && cp LS2_SYS_CONFIG_TOOL $(TARGET_DIR)/root/loongson_test_case/
endef
else
define LS2_SYS_CONFIG_TOOL_BUILD_QT_VER_CMDS
	echo "not build Qt version"
endef
define LS2_SYS_CONFIG_TOOL_INSTALL_QT_VER_CMDS
	echo "not install Qt version"
endef
endif

ifeq ($(BR2_PACKAGE_LS2_SYS_CONFIG_TOOL_QT_AUTO_START),y)

ifeq ($(BR2_PACKAGE_BOOT_RUN),y)
define LS2_SYS_CONFIG_TOOL_INSTALL_AUTO_EXEC_AFTER_BOOT_CMDS
	echo "auto run in boot in /root/boot_run.sh"
endef
else
define LS2_SYS_CONFIG_TOOL_INSTALL_AUTO_EXEC_AFTER_BOOT_CMDS
	echo "install auto boot Qt version sofeware service" && cd $(TOPDIR)/package/LS2_SYS_CONFIG_TOOL/ && cp LS2_SYS_CONFIG_TOOL.service $(TARGET_DIR)/usr/lib/systemd/system/ && cd $(TARGET_DIR)/usr/lib/systemd/system/ && mkdir -p multi-user.target.wants && cd $(TARGET_DIR)/usr/lib/systemd/system/multi-user.target.wants && ln -s -f ../LS2_SYS_CONFIG_TOOL.service LS2_SYS_CONFIG_TOOL.service
endef
endif

else
define LS2_SYS_CONFIG_TOOL_INSTALL_AUTO_EXEC_AFTER_BOOT_CMDS
	echo "nothing to do"
endef
endif

define LS2_SYS_CONFIG_TOOL_BUILD_CMDS
	echo "first build cmd version sofeware"
	cd $(@D)/cmd_version && $(MAKE) clean && $(TARGET_MAKE_ENV) $(MAKE) CC=$(TARGET_CC) BUILD_TYPE=2 && cp sys_config_tool update_system
	cd $(@D)/cmd_version && $(MAKE) clean && $(TARGET_MAKE_ENV) $(MAKE) CC=$(TARGET_CC)
	echo "second build qt version sofeware"
	$(LS2_SYS_CONFIG_TOOL_BUILD_QT_VER_CMDS)
endef

define LS2_SYS_CONFIG_TOOL_INSTALL_STAGING_CMDS
	echo "nothing to do"
endef

define LS2_SYS_CONFIG_TOOL_INSTALL_TARGET_CMDS
	echo "install cmd version sofeware"
	cd $(TARGET_DIR)/ && mkdir -p ./root/ls2_sys_config_tool/file
	cd $(@D)/file && cp -r download_system_tftp $(TARGET_DIR)/root/ls2_sys_config_tool/file/download_system
	cd $(@D)/file && cp -r install_system $(TARGET_DIR)/root/ls2_sys_config_tool/file/
	cd $(@D)/file && cp -r fstab $(TARGET_DIR)/root/ls2_sys_config_tool/file/
	cd $(@D)/cmd_version && cp sys_config_tool $(TARGET_DIR)/root/ls2_sys_config_tool/
	cd $(@D)/cmd_version && cp update_system $(TARGET_DIR)/root/ls2_sys_config_tool/
	$(LS2_SYS_CONFIG_TOOL_INSTALL_QT_VER_CMDS)
	$(LS2_SYS_CONFIG_TOOL_INSTALL_AUTO_EXEC_AFTER_BOOT_CMDS)
endef

$(eval $(generic-package))
