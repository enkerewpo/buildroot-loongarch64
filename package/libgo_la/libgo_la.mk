################################################################################
#
# libgo_la
#
################################################################################

LIBGO_LA_SITE = $(TOPDIR)/package/libgo_la/libgo_la.tar.gz
LIBGO_LA_SITE_METHOD = file
LIBGO_LA_INSTALL_STAGING = YES
LIBGO_LA_INSTALL_TARGET = YES
LIBGO_LA_CONF_OPTS = -DBUILD_DYNAMIC=1

define LIBGO_LA_EXTRACT_CMDS
	echo $(LIBGO_LA_SITE)
	tar -zxf $(LIBGO_LA_SITE) -C $(@D)/
endef

$(eval $(cmake-package))
