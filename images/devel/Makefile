include ../../config.mk
include ../../config_busybox.mk
include ../../tools.mk

ifeq ($(strip $(PUBLISH_TAG)),)
override PUBLISH_TAG := $(DISTRO_REL)
endif

LAYER_SUFFIX :=
ifeq ($(LAYER_TYPE),squashfs)
LAYER_SUFFIX := "-squashfs"
endif

PUBLISH_IMAGE_NAME := $(shell basename $$(pwd))-$(ARCH)

.DEFAULT_GOAL := all

.PHONY: all
all: build test

.PHONY: build
build: $(STACKER)
	$(STACKER_WITH_BUILD_DIR) \
		build -f stacker.yaml \
		--layer-type $(LAYER_TYPE) \
		--substitute LAYER_SUFFIX=$(LAYER_SUFFIX) \
		--substitute BUILD_OCI_DIR=$(BUILD_OCI_DIR) \
		--substitute REVISION=$(COMMIT) \
		--substitute LICENSES="$(shell cat LICENSE.md)" \
		--substitute DESCRIPTION="$(shell cat README.md)" \
		--substitute OS=$(OS) \
		--substitute ARCH=$(ARCH) \
		--substitute DISTRO=$(DISTRO) \
		--substitute DISTRO_REL=$(DISTRO_REL) \
		--substitute BUSYBOX=$(BUSYBOX)

.PHONY: test
test:

.PHONY: publish
publish: $(STACKER)
	$(STACKER_WITH_BUILD_DIR) \
		publish -f stacker.yaml \
		--layer-type $(LAYER_TYPE) \
		--substitute LAYER_SUFFIX=$(LAYER_SUFFIX) \
		--substitute BUILD_OCI_DIR=$(BUILD_OCI_DIR) \
		--substitute REVISION=$(COMMIT) \
		--substitute LICENSES="$(shell cat LICENSE.md)" \
		--substitute DESCRIPTION="$(shell cat README.md)" \
		--substitute OS=$(OS) \
		--substitute ARCH=$(ARCH) \
		--substitute DISTRO=$(DISTRO) \
		--substitute DISTRO_REL=$(DISTRO_REL) \
		--substitute BUSYBOX=$(BUSYBOX) \
		--url $(PUBLISH_URL)/$(DISTRO) \
		--tag $(PUBLISH_TAG) \
		$(PUBLISH_EXTRA_ARGS)

.PHONY: pull
pull:
	skopeo copy $(PULL_EXTRA_ARGS) $(PUBLISH_URL)/$(strip $(DISTRO))/$(strip $(PUBLISH_IMAGE_NAME)):$(PUBLISH_TAG)$(LAYER_SUFFIX) oci:$(BUILD_OCI_DIR):$(PUBLISH_IMAGE_NAME)$(LAYER_SUFFIX)
