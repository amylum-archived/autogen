PACKAGE = autogen
ORG = amylum

BUILD_DIR = /tmp/$(PACKAGE)-build
RELEASE_DIR = /tmp/$(PACKAGE)-release
RELEASE_FILE = /tmp/$(PACKAGE).tar.gz

PACKAGE_VERSION = 5.18.6
PATCH_VERSION = $$(cat version)
VERSION = $(PACKAGE_VERSION)-$(PATCH_VERSION)

SOURCE_URL = http://ftp.gnu.org/gnu/$(PACKAGE)/rel$(PACKAGE_VERSION)/$(PACKAGE)-$(PACKAGE_VERSION).tar.xz
SOURCE_PATH = /tmp/source
SOURCE_TARBALL = /tmp/source.tar.gz

PATH_FLAGS = --prefix=/usr --infodir=/tmp/trash
CFLAGS = -static -static-libgcc -Wl,-static

GMP_VERSION = 6.1.0-1
GMP_URL = https://github.com/amylum/gmp/releases/download/$(GMP_VERSION)/gmp.tar.gz
GMP_TAR = /tmp/gmp.tar.gz
GMP_DIR = /tmp/gmp
GMP_PATH = -I$(GMP_DIR)/usr/include -L$(GMP_DIR)/usr/lib

GC_VERSION = 7.4.2-2
GC_URL = https://github.com/amylum/gc/releases/download/$(GC_VERSION)/gc.tar.gz
GC_TAR = /tmp/gc.tar.gz
GC_DIR = /tmp/gc
GC_PATH = -I$(GC_DIR)/usr/include -L$(GC_DIR)/usr/lib

LIBATOMIC_OPS_VERSION = 7.4.2-1
LIBATOMIC_OPS_URL = https://github.com/amylum/libatomic_ops/releases/download/$(LIBATOMIC_OPS_VERSION)/libatomic_ops.tar.gz
LIBATOMIC_OPS_TAR = /tmp/libatomic_ops.tar.gz
LIBATOMIC_OPS_DIR = /tmp/libatomic_ops
LIBATOMIC_OPS_PATH = -I$(LIBATOMIC_OPS_DIR)/usr/include -L$(LIBATOMIC_OPS_DIR)/usr/lib

GUILE_VERSION = 2.0.11-2
GUILE_URL = https://github.com/amylum/guile/releases/download/$(GUILE_VERSION)/guile.tar.gz
GUILE_TAR = /tmp/guile.tar.gz
GUILE_DIR = /tmp/guile
GUILE_PATH = -I$(GUILE_DIR)/usr/include -L$(GUILE_DIR)/usr/lib

LIBFFI_VERSION = 3.2.1-2
LIBFFI_URL = https://github.com/amylum/libffi/releases/download/$(LIBFFI_VERSION)/libffi.tar.gz
LIBFFI_TAR = /tmp/libffi.tar.gz
LIBFFI_DIR = /tmp/libffi
LIBFFI_PATH = -I$(LIBFFI_DIR)/usr/include -L$(LIBFFI_DIR)/usr/lib

LIBUNISTRING_VERSION = 0.9.6-1
LIBUNISTRING_URL = https://github.com/amylum/libunistring/releases/download/$(LIBUNISTRING_VERSION)/libunistring.tar.gz
LIBUNISTRING_TAR = /tmp/libunistring.tar.gz
LIBUNISTRING_DIR = /tmp/libunistring
LIBUNISTRING_PATH = -I$(LIBUNISTRING_DIR)/usr/include -L$(LIBUNISTRING_DIR)/usr/lib

LIBTOOL_VERSION = 2.4.6-1
LIBTOOL_URL = https://github.com/amylum/libtool/releases/download/$(LIBTOOL_VERSION)/libtool.tar.gz
LIBTOOL_TAR = /tmp/libtool.tar.gz
LIBTOOL_DIR = /tmp/libtool
LIBTOOL_PATH = -I$(LIBTOOL_DIR)/usr/include -L$(LIBTOOL_DIR)/usr/lib

.PHONY : default source deps manual container build version push local

default: container

source:
	rm -rf $(SOURCE_PATH) $(SOURCE_TARBALL)
	mkdir $(SOURCE_PATH)
	curl -sLo $(SOURCE_TARBALL) $(SOURCE_URL)
	tar -x -C $(SOURCE_PATH) -f $(SOURCE_TARBALL) --strip-components=1

manual:
	./meta/launch /bin/bash || true

container:
	./meta/launch

deps:
	rm -rf $(GMP_DIR) $(GMP_TAR)
	mkdir $(GMP_DIR)
	curl -sLo $(GMP_TAR) $(GMP_URL)
	tar -x -C $(GMP_DIR) -f $(GMP_TAR)
	rm -rf $(GC_DIR) $(GC_TAR)
	mkdir $(GC_DIR)
	curl -sLo $(GC_TAR) $(GC_URL)
	tar -x -C $(GC_DIR) -f $(GC_TAR)
	rm /tmp/gc/usr/lib/libgc.la
	rm -rf $(LIBATOMIC_OPS_DIR) $(LIBATOMIC_OPS_TAR)
	mkdir $(LIBATOMIC_OPS_DIR)
	curl -sLo $(LIBATOMIC_OPS_TAR) $(LIBATOMIC_OPS_URL)
	tar -x -C $(LIBATOMIC_OPS_DIR) -f $(LIBATOMIC_OPS_TAR)
	rm -rf $(GUILE_DIR) $(GUILE_TAR)
	mkdir $(GUILE_DIR)
	curl -sLo $(GUILE_TAR) $(GUILE_URL)
	tar -x -C $(GUILE_DIR) -f $(GUILE_TAR)
	rm /tmp/guile/usr/lib/libguile-2.0.la
	rm -rf $(LIBFFI_DIR) $(LIBFFI_TAR)
	mkdir $(LIBFFI_DIR)
	curl -sLo $(LIBFFI_TAR) $(LIBFFI_URL)
	tar -x -C $(LIBFFI_DIR) -f $(LIBFFI_TAR)
	rm -rf $(LIBUNISTRING_DIR) $(LIBUNISTRING_TAR)
	mkdir $(LIBUNISTRING_DIR)
	curl -sLo $(LIBUNISTRING_TAR) $(LIBUNISTRING_URL)
	tar -x -C $(LIBUNISTRING_DIR) -f $(LIBUNISTRING_TAR)
	rm -rf $(LIBTOOL_DIR) $(LIBTOOL_TAR)
	mkdir $(LIBTOOL_DIR)
	curl -sLo $(LIBTOOL_TAR) $(LIBTOOL_URL)
	tar -x -C $(LIBTOOL_DIR) -f $(LIBTOOL_TAR)

build: source deps
	rm -rf $(BUILD_DIR)
	cp -R $(SOURCE_PATH) $(BUILD_DIR)
	cd $(BUILD_DIR) && autoreconf -i
	cd $(BUILD_DIR) && CC=musl-gcc LIBS='-lffi -lgmp -lunistring -lltdl' CFLAGS='$(CFLAGS) $(GMP_PATH) $(GC_PATH) $(LIBATOMIC_OPS_PATH) $(GUILE_PATH) $(LIBFFI_PATH) $(LIBUNISTRING_PATH) $(LIBTOOL_PATH)' ./configure $(PATH_FLAGS)
	cd $(BUILD_DIR) && make
	cd $(BUILD_DIR) && make DESTDIR=$(RELEASE_DIR) install
	rm -rf $(RELEASE_DIR)/tmp
	mkdir -p $(RELEASE_DIR)/usr/share/licenses/$(PACKAGE)
	cp $(BUILD_DIR)/COPYING $(RELEASE_DIR)/usr/share/licenses/$(PACKAGE)/LICENSE
	cd $(RELEASE_DIR) && tar -czvf $(RELEASE_FILE) *

version:
	@echo $$(($(PATCH_VERSION) + 1)) > version

push: version
	git commit -am "$(VERSION)"
	ssh -oStrictHostKeyChecking=no git@github.com &>/dev/null || true
	git tag -f "$(VERSION)"
	git push --tags origin master
	targit -a .github -c -f $(ORG)/$(PACKAGE) $(VERSION) $(RELEASE_FILE)
	@sha512sum $(RELEASE_FILE) | cut -d' ' -f1

local: build push

