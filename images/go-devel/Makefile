include ../../config.mk

TOOLS_DIR := ../../hack/tools
TOOLS_BIN_DIR := $(TOOLS_DIR)/bin
STACKER := $(TOOLS_BIN_DIR)/stacker
BUILD_DIR := ../../build

SRC := $(wildcard *.yaml)
IMAGES := $(patsubst %.yaml,%,$(SRC))

.PHONY: all
all: $(IMAGES) test

.PHONY: %
%:
	$(STACKER) \
		--stacker-dir $(BUILD_DIR)/.stacker \
		--oci-dir $(BUILD_DIR)/oci \
		--roots-dir $(BUILD_DIR)/roots \
		build -f $*.yaml \
		--substitute REVISION=$(COMMIT) \
		--substitute LICENSES="$(shell cat LICENSE.md)" \
		--substitute DESCRIPTION="$(shell cat README.md)" \
		--substitute OS=$(OS) \
		--substitute ARCH=$(ARCH) \
		--substitute DISTRO=$(DISTRO) \
		--substitute DISTRO_REL=$(DISTRO_REL) \
		--substitute GOLANG=$(GOLANG) \
		--substitute GOLANG_HASH=$(GOLANG_HASH) \
		--substitute GOLANG_DLV=$(GOLANG_DLV) \
		--substitute GOLANG_LINTER=$(GOLANG_LINTER) \
		--substitute BUSYBOX=$(BUSYBOX)

.PHONY: test
test:

.PHONY: clean
clean:
	$(STACKER) \
		--stacker-dir $(BUILD_DIR)/.stacker \
		--oci-dir $(BUILD_DIR)/oci \
		--roots-dir $(BUILD_DIR)/roots \
		clean
