################################################################################
#
# network-manager
#
################################################################################

NETWORK_MANAGER_VERSION_MAJOR = 1.22
NETWORK_MANAGER_VERSION = $(NETWORK_MANAGER_VERSION_MAJOR).16
NETWORK_MANAGER_SOURCE = NetworkManager-$(NETWORK_MANAGER_VERSION).tar.xz
NETWORK_MANAGER_SITE = https://download.gnome.org/sources/NetworkManager/$(NETWORK_MANAGER_VERSION_MAJOR)
NETWORK_MANAGER_INSTALL_STAGING = YES
NETWORK_MANAGER_DEPENDENCIES = host-pkgconf udev gnutls libglib2 \
	libgcrypt wireless_tools util-linux host-intltool readline libndp
NETWORK_MANAGER_LICENSE = GPL-2.0+ (app), LGPL-2.1+ (libnm)
NETWORK_MANAGER_LICENSE_FILES = COPYING COPYING.LGPL CONTRIBUTING
NETWORK_MANAGER_CPE_ID_VENDOR = gnome
NETWORK_MANAGER_CPE_ID_PRODUCT = networkmanager
NETWORK_MANAGER_SELINUX_MODULES = networkmanager

NETWORK_MANAGER_CONF_ENV = \
	ac_cv_path_LIBGCRYPT_CONFIG=$(STAGING_DIR)/usr/bin/libgcrypt-config \
	ac_cv_file__etc_fedora_release=no \
	ac_cv_file__etc_mandriva_release=no \
	ac_cv_file__etc_debian_version=no \
	ac_cv_file__etc_redhat_release=no \
	ac_cv_file__etc_SuSE_release=no

NETWORK_MANAGER_CONF_OPTS = \
	--disable-introspection \
	--disable-tests \
	--disable-qt \
	--disable-more-warnings \
	--with-crypto=gnutls \
	--with-iptables=/usr/sbin/iptables \
	--disable-ifupdown \
	--without-nm-cloud-setup

ifeq ($(BR2_PACKAGE_OFONO),y)
NETWORK_MANAGER_DEPENDENCIES += ofono
NETWORK_MANAGER_CONF_OPTS += --with-ofono
else
NETWORK_MANAGER_CONF_OPTS += --without-ofono
endif

ifeq ($(BR2_PACKAGE_LIBCURL),y)
NETWORK_MANAGER_DEPENDENCIES += libcurl
NETWORK_MANAGER_CONF_OPTS += --enable-concheck
else
NETWORK_MANAGER_CONF_OPTS += --disable-concheck
endif

ifeq ($(BR2_PACKAGE_NETWORK_MANAGER_TUI),y)
NETWORK_MANAGER_DEPENDENCIES += newt
NETWORK_MANAGER_CONF_OPTS += --with-nmtui=yes
else
NETWORK_MANAGER_CONF_OPTS += --with-nmtui=no
endif

ifeq ($(BR2_PACKAGE_NETWORK_MANAGER_PPPD),y)
NETWORK_MANAGER_DEPENDENCIES += pppd
NETWORK_MANAGER_CONF_OPTS += --enable-ppp
else
NETWORK_MANAGER_CONF_OPTS += --disable-ppp
endif

ifeq ($(BR2_PACKAGE_NETWORK_MANAGER_MODEM_MANAGER),y)
NETWORK_MANAGER_DEPENDENCIES += modem-manager
NETWORK_MANAGER_CONF_OPTS += --with-modem-manager-1
else
NETWORK_MANAGER_CONF_OPTS += --without-modem-manager-1
endif

ifeq ($(BR2_PACKAGE_DHCP_CLIENT),y)
NETWORK_MANAGER_CONF_OPTS += --with-dhclient=/sbin/dhclient
endif

ifeq ($(BR2_PACKAGE_DHCPCD),y)
NETWORK_MANAGER_CONF_OPTS += --with-dhcpcd=/sbin/dhcpcd
endif

ifeq ($(BR2_PACKAGE_NETWORK_MANAGER_OVS),y)
NETWORK_MANAGER_CONF_OPTS += --enable-ovs
NETWORK_MANAGER_DEPENDENCIES += jansson
else
NETWORK_MANAGER_CONF_OPTS += --disable-ovs
endif

define NETWORK_MANAGER_INSTALL_INIT_SYSV
	$(INSTALL) -m 0755 -D package/network-manager/S45network-manager $(TARGET_DIR)/etc/init.d/S45network-manager
endef

define NETWORK_MANAGER_INSTALL_INIT_SYSTEMD
	cd $(TARGET_DIR)/usr/lib/systemd/system/ && ln -sf NetworkManager.service dbus-org.freedesktop.NetworkManager.service
endef

$(eval $(autotools-package))
