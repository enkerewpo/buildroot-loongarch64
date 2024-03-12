################################################################################
#
# libelectric-fence
#
################################################################################

LIBELECTRIC_FENCE_VERSION = 2.2.6
LIBELECTRIC_FENCE_SITE = http://deb.debian.org/debian/pool/main/e/electric-fence
LIBELECTRIC_FENCE_SOURCE = electric-fence_$(LIBELECTRIC_FENCE_VERSION).tar.gz
LIBELECTRIC_FENCE_CFLAGS = $(TARGET_CFLAGS)

#cp $(LIBELECTRIC_FENCE_PACKAGE_DIR)/*.patch $(LIBELECTRIC_FENCE_DL_DIR)/
#cd $(LIBELECTRIC_FENCE_DL_DIR) && tar -zxf $(LIBELECTRIC_FENCE_SOURCE) && cp *.patch work/ && cd work && patch -p1 < *.patch && cd .. && mv work/* $(BUILD_DIR)/libelectric-fence-$(LIBELECTRIC_FENCE_VERSION)/
define LIBELECTRIC_FENCE_EXTRACT_CMDS
	echo $(BUILD_DIR)
	cd $(LIBELECTRIC_FENCE_DL_DIR) && tar -zxf $(LIBELECTRIC_FENCE_SOURCE) && mv work/* $(BUILD_DIR)/libelectric-fence-$(LIBELECTRIC_FENCE_VERSION)/
endef

define LIBELECTRIC_FENCE_BUILD_CMDS
	echo $(CC)
	echo $(CROSS_COMPILER)
	echo $(TARGET_CC)
	echo $(HOST_CC)
	$(TARGET_MAKE_ENV) $(MAKE) CC=$(TARGET_CC) AR=$(TARGET_AR) -C $(@D)
endef

define LIBELECTRIC_FENCE_INSTALL_STAGING_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) CC=$(TARGET_CC) AR=$(TARGET_AR)  -C $(@D) DESTDIR=$(STAGING_DIR) install
endef

define LIBELECTRIC_FENCE_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) DESTDIR=$(TARGET_DIR) install
endef

define LIBELECTRIC_FENCE_REMOVE_LIBELECTRIC_FENCE_ENGINES
	rm -rf $(TARGET_DIR)/usr/lib/libefence.so.0.0
	rm -rf $(TARGET_DIR)/usr/lib/libefence.so.0
	rm -rf $(TARGET_DIR)/usr/lib/libefence.so
	rm -rf $(TARGET_DIR)/usr/lib/libefence.a
endef

$(eval $(generic-package))
