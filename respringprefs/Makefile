TARGET := iphone:clang:latest:14.5

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = ReSpringPrefs

ReSpringPrefs_FILES = $(shell find Sources/ReSpringPrefs -name '*.swift') $(shell find Sources/ReSpringPrefsC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
ReSpringPrefs_SWIFTFLAGS = -ISources/ReSpringPrefsC/include
ReSpringPrefs_INSTALL_PATH = /Library/PreferenceBundles
ReSpringPrefs_CFLAGS = -fobjc-arc
ReSpringPrefs_LIBRARIES = gcuniversal

include $(THEOS_MAKE_PATH)/bundle.mk
