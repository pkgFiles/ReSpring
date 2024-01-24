TARGET := iphone:clang:latest:14.4
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ReSpring

ReSpring_FILES = $(shell find Sources/ReSpring -name '*.swift') $(shell find Sources/ReSpringC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
ReSpring_SWIFTFLAGS = -ISources/ReSpringC/include
ReSpring_CFLAGS = -fobjc-arc -ISources/ReSpringC/include

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += respringprefs
include $(THEOS_MAKE_PATH)/aggregate.mk
