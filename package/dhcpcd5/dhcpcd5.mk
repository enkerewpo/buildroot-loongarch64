################################################################################
#
# dhcpcd5
#
################################################################################

DHCPCD5_VERSION = 7.1.0
DHCPCD5_SOURCE = dhcpcd5-$(DHCPCD5_VERSION).tar.gz
DHCPCD5_SITE = https://roy.marples.name/projects/dhcpcd
DHCPCD5_DEPENDENCIES = host-pkgconf
DHCPCD5_LICENSE = BSD-2-Clause
DHCPCD5_LICENSE_FILES = LICENSE
DHCPCD5_CPE_ID_VENDOR = dhcpcd5_project

DHCPCD5_CONFIG_OPTS = \
	--libexecdir=/lib/dhcpcd5 \
	--dbdir=/var/db/dhcpcd5 \
	--rundir=/var/run \
	--os=linux

# AUDIT_ARCH_{OPENRISC,SH,SHEL,SH64,SHEL64} are only available with kernel >= 3.7
ifeq ($(BR2_or1k)$(BR2_sh):$(BR2_TOOLCHAIN_HEADERS_AT_LEAST_3_7),y:)
DHCPCD5_CONFIG_OPTS += --disable-privsep
endif

# AUDIT_ARCH_MICROBLAZE is only available with kernel >= 3.18
ifeq ($(BR2_microblazeel)$(BR2_microblazebe):$(BR2_TOOLCHAIN_HEADERS_AT_LEAST_3_18),y:)
DHCPCD5_CONFIG_OPTS += --disable-privsep
endif

# AUDIT_ARCH_XTENSA is only available with kernel >= 5.0
ifeq ($(BR2_xtensa):$(BR2_TOOLCHAIN_HEADERS_AT_LEAST_5_0),y:)
DHCPCD5_CONFIG_OPTS += --disable-privsep
endif

# AUDIT_ARCH_{ARCOMPACT,ARCV2,NDS32,NIOS2} are only available with kernel >= 5.2
ifeq ($(BR2_arceb)$(BR2_arcle)$(BR2_nds32)$(BR2_nios2):$(BR2_TOOLCHAIN_HEADERS_AT_LEAST_5_2),y:)
DHCPCD5_CONFIG_OPTS += --disable-privsep
endif

ifeq ($(BR2_PACKAGE_HAS_UDEV),y)
DHCPCD5_CONFIG_OPTS += --with-udev
DHCPCD5_DEPENDENCIES += udev
else
DHCPCD5_CONFIG_OPTS += --without-udev
endif

ifeq ($(BR2_STATIC_LIBS),y)
DHCPCD5_CONFIG_OPTS += --enable-static
endif

ifeq ($(BR2_USE_MMU),)
DHCPCD5_CONFIG_OPTS += --disable-fork --disable-privsep
endif

define DHCPCD5_CONFIGURE_CMDS
	(cd $(@D); $(TARGET_CONFIGURE_OPTS) ./configure $(DHCPCD5_CONFIG_OPTS))
endef

define DHCPCD5_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) all
endef

define DHCPCD5_INSTALL_TARGET_CMDS
	$(TARGET_MAKE_ENV) $(MAKE) -C $(@D) install DESTDIR=$(TARGET_DIR)
endef

# When network-manager is enabled together with dhcpcd, it will use
# dhcpcd as a DHCP client, and will be in charge of running, so we
# don't want the init script or service file to be installed.
ifeq ($(BR2_PACKAGE_NETWORK_MANAGER),)
define DHCPCD5_INSTALL_INIT_SYSV
	$(INSTALL) -m 755 -D package/dhcpcd5/S41dhcpcd5 \
		$(TARGET_DIR)/etc/init.d/S41dhcpcd5
endef

define DHCPCD5_INSTALL_INIT_SYSTEMD
	$(INSTALL) -D -m 0644 package/dhcpcd5/dhcpcd5.service \
		$(TARGET_DIR)/usr/lib/systemd/system/dhcpcd5.service
endef
endif

define DHCPCD5_USERS
	dhcpcd5 -1 dhcpcd5 -1 * - - - dhcpcd5 user
endef

# NOTE: Even though this package has a configure script, it is not generated
# using the autotools, so we have to use the generic package infrastructure.

$(eval $(generic-package))
