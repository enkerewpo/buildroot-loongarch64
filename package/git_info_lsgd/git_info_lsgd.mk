################################################################################
#
# git_info_lsgd
#
################################################################################

GIT_INFO_LSGD_SITE=$(TOPDIR)/dl/git_info_lsgd/git_info_lsgd.tar.gz
GIT_INFO_LSGD_SITE_METHOD=file

define GIT_INFO_LSGD_EXTRACT_CMDS
	tar -zxf $(GIT_INFO_LSGD_SITE) -C $(@D)
endef

define GIT_INFO_LSGD_BUILD_CMDS
	cd $(@D) && chmod a+x git-info-get.sh && ./git-info-get.sh
	cd $(@D) && chmod a+x fs_git_info_lsgd
endef

define GIT_INFO_LSGD_INSTALL_TARGET_CMDS
	cd $(@D) && cp git_info_ls $(TARGET_DIR)/etc
	cd $(@D) && cp fs_git_info_lsgd $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
