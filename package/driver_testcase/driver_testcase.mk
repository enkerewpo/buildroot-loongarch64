################################################################################
#
# driver_testcase
#
################################################################################

DRIVER_TESTCASE_VERSION = origin/master
DRIVER_TESTCASE_SITE = http://10.120.1.5:3000/base/driver_testcase
DRIVER_TESTCASE_SITE_METHOD = git
DRIVER_TESTCASE_GIT_SUBMODULES = YES
DRIVER_TESTCASE_CFLAGS = $(TARGET_CFLAGS)

ifeq ($(BR2_PACKAGE_DRIVER_TESTCASE_QT),y)
DRIVER_TESTCASE_DEPENDENCIES = qt5base
endif

#define DRIVER_TESTCASE_EXTRACT_CMDS
	
#endef

#$(TARGET_MAKE_ENV) $(MAKE) CC=$(TARGET_CC) AR=$(TARGET_AR) -C $(@D)

ifeq ($(BR2_PACKAGE_DRIVER_TESTCASE_QT),y)
define DRIVER_TESTCASE_BUILD_QT_VER_CMDS
	cd $(@D)/Qtver/driver_testcase/ && $(HOST_DIR)/bin/qmake driver_testcase.pro && $(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/Qtver/driver_testcase/
endef
define DRIVER_TESTCASE_INSTALL_QT_VER_CMDS
	echo "install Qt version sofeware" && cd $(@D)/Qtver/driver_testcase/ && cp driver_testcase $(TARGET_DIR)/root/loongson_test_case/
endef
else
define DRIVER_TESTCASE_BUILD_QT_VER_CMDS
	echo "not build Qt version"
endef
define DRIVER_TESTCASE_INSTALL_QT_VER_CMDS
	echo "not install Qt version"
endef
endif

ifeq ($(BR2_PACKAGE_DRIVER_TESTCASE_QT_AUTO_START),y)

ifeq ($(BR2_PACKAGE_BOOT_RUN),y)
define DRIVER_TESTCASE_INSTALL_AUTO_EXEC_AFTER_BOOT_CMDS
	echo "auto run in boot in /root/boot_run.sh"
endef
else
define DRIVER_TESTCASE_INSTALL_AUTO_EXEC_AFTER_BOOT_CMDS
	echo "install auto boot Qt version sofeware service" && cd $(TOPDIR)/package/driver_testcase/ && cp driver_testcase.service $(TARGET_DIR)/usr/lib/systemd/system/ && cd $(TARGET_DIR)/usr/lib/systemd/system/ && mkdir -p multi-user.target.wants && cd $(TARGET_DIR)/usr/lib/systemd/system/multi-user.target.wants && ln -s -f ../driver_testcase.service driver_testcase.service
endef
endif

else
define DRIVER_TESTCASE_INSTALL_AUTO_EXEC_AFTER_BOOT_CMDS
	echo "nothing to do"
endef
endif

define DRIVER_TESTCASE_BUILD_CMDS
	echo "first cmake all single test case"
	cd $(@D) && mkdir -p build && cd ./build && cmake -D CMAKE_C_COMPILER=$(TARGET_CC) ../
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D)/build/
	cd $(@D) && export CC=$(TARGET_CC); export $(TARGET_MAKE_ENV); export ARCH=$(BR2_ARCH); export CROSS_COMPILE=$(BR2_TOOLCHAIN_EXTERNAL_CUSTOM_PREFIX)-; ./compile_ob_cp.sh && ./install_single_test.sh
	echo "second build cmd version sofeware"
	cd $(@D)/test-server-project && export $(TARGET_MAKE_ENV); export CC=$(TARGET_CC); export ARCH=$(BR2_ARCH); export CROSS_COMPILE=$(BR2_TOOLCHAIN_EXTERNAL_CUSTOM_PREFIX)-; ./build.sh rebuild
	$(DRIVER_TESTCASE_BUILD_QT_VER_CMDS)
endef

define DRIVER_TESTCASE_INSTALL_STAGING_CMDS
	echo "nothing to do"
endef

define DRIVER_TESTCASE_INSTALL_TARGET_CMDS
	echo "install all single test case"
	cd $(TARGET_DIR)/ && mkdir -p ./root/loongson_test_case
	cd $(@D) && cd out/loongson_test_case/ && cp -r * $(TARGET_DIR)/root/loongson_test_case/
	echo "install test-server(all test case test tool)"
	mkdir -p $(TARGET_DIR)/root/loongson-test-server
	cd $(@D)/test-server-project && cp test-server $(TARGET_DIR)/root/loongson-test-server
	#cd $(@D)/test-server-project && cp can_client $(TARGET_DIR)/root/loongson-test-server
	$(DRIVER_TESTCASE_INSTALL_QT_VER_CMDS)
	$(DRIVER_TESTCASE_INSTALL_AUTO_EXEC_AFTER_BOOT_CMDS)
endef

$(eval $(generic-package))
