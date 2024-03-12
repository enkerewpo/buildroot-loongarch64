################################################################################
#
# lvgl_kit
#
################################################################################

LVGL_KIT_VERSION = origin/master
LVGL_KIT_SITE = http://10.120.1.5:3000/tao89959/lvgl-8.2
LVGL_KIT_SITE_METHOD = git
LVGL_KIT_GIT_SUBMODULES = YES
LVGL_KIT_CFLAGS = $(TARGET_CFLAGS)

LVGL_KIT_DEPENDENCIES = libdrm libxkbcommon

#$(TARGET_MAKE_ENV) $(MAKE) CC=$(TARGET_CC) AR=$(TARGET_AR) -C $(@D)

ABS_X_CALU_MAP = $(BR2_PACKAGE_TOUCH_SCREEN_MAP_VALUE_X)
ABS_Y_CALU_MAP = $(BR2_PACKAGE_TOUCH_SCREEN_MAP_VALUE_Y)

ifeq ($(BR2_PACKAGE_TOUCH_SCREEN_MAP_VALUE),y)
define BUILD_ABOUT_TOUCH_MAP_CMDS
	echo "create lvgl_config" && cd $(@D) && echo abs_x_calu_max=$(ABS_X_CALU_MAP) >> lvgl_config && echo abs_y_calu_max=$(ABS_Y_CALU_MAP) >> lvgl_config
endef
else
define BUILD_ABOUT_TOUCH_MAP_CMDS
	echo "not thing to do about touch abs map"
endef
endif

ifeq ($(BR2_PACKAGE_TOUCH_SCREEN_MAP_VALUE),y)
define INSTALL_ABOUT_TOUCH_MAP_CMDS
	cd $(@D) && cp lvgl_config $(TARGET_DIR)/etc/
endef
else
define INSTALL_ABOUT_TOUCH_MAP_CMDS
	echo "not thing to do about touch abs map"
endef
endif

define LVGL_KIT_BUILD_CMDS
	cd $(@D)/LVGL && export $(TARGET_MAKE_ENV); export CC=$(TARGET_CC); ./build.sh custom $(TARGET_CC)
	$(BUILD_ABOUT_TOUCH_MAP_CMDS)
endef

define LVGL_KIT_INSTALL_STAGING_CMDS
	echo "nothing to do"
endef

define LVGL_KIT_INSTALL_TARGET_CMDS
	cd $(@D)/LVGL/build/bin/ && cp demo $(TARGET_DIR)/usr/bin/lvgl-demo
	$(INSTALL_ABOUT_TOUCH_MAP_CMDS)
endef

$(eval $(generic-package))
