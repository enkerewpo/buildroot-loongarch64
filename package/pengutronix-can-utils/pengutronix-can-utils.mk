################################################################################
#
# pengutronix can-utils
#
################################################################################

PENGUTRONIX_CAN_UTILS_VERSION = master
PENGUTRONIX_CAN_UTILS_SITE = https://github.com/jmore-reachtech/can-utils
PENGUTRONIX_CAN_UTILS_AUTORECONF = YES

$(eval $(autotools-package))
