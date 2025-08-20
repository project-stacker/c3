TOP_LEVEL=$(shell git rev-parse --show-toplevel)
TOOLS_DIR := $(TOP_LEVEL)/hack/tools
TOOLS_BIN_DIR := $(TOOLS_DIR)/bin
BUILD_DIR := $(TOP_LEVEL)/build
BUILD_OCI_DIR := $(BUILD_DIR)/oci
STACKER_VERSION := v1.0.0-rc4

export STACKER := $(TOOLS_BIN_DIR)/stacker
export SKOPEO := skopeo

STACKER_WITH_BUILD_DIR := $(STACKER) --stacker-dir $(BUILD_DIR)/.stacker --oci-dir $(BUILD_OCI_DIR) --roots-dir $(BUILD_DIR)/roots

$(STACKER):
	mkdir -p $(TOOLS_BIN_DIR)
	curl -fsSL https://github.com/project-stacker/stacker/releases/download/$(STACKER_VERSION)/stacker -o "$@"
	chmod +x $@

.PHONY: check-skopeo
check-skopeo:
	$(SKOPEO) -v || (echo "You need skopeo to be installed in order to copy images"; exit 1)

.PHONY: clean
clean: $(STACKER)
	$(STACKER_WITH_BUILD_DIR) clean

.PHONY: tags
tags:
	@echo $(PUBLISH_TAGS)

.PHONY: vars
vars:
	$(foreach v, $(.VARIABLES), $(info $(v) = $($(v))))