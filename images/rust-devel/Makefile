include ../../config.mk
include ../../config_rust.mk
include ../../tools.mk

ifeq ($(strip $(PUBLISH_TAG)),)
override PUBLISH_TAG := $(RUST)
endif

LAYER_SUFFIX :=
ifeq ($(LAYER_TYPE),squashfs)
LAYER_SUFFIX := "-squashfs"
endif

PUBLISH_IMAGE_NAME := $(shell basename $$(pwd))-$(ARCH)

# we'll need to redesign the repo later to accomodate multiple arch names / hashes
RUST_ARCH =
ifeq ($(strip $(ARCH)),amd64)
RUST_ARCH = x86_64-unknown-linux-gnu
endif

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
		--substitute RUST=$(RUST) \
		--substitute RUST_ARCH=$(RUST_ARCH) \
		--substitute RUST_INIT=$(RUST_INIT) \
		--substitute RUST_INIT_HASH=$(RUST_INIT_HASH)

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
		--substitute RUST=$(RUST) \
		--substitute RUST_ARCH=$(RUST_ARCH) \
		--substitute RUST_INIT=$(RUST_INIT) \
		--substitute RUST_INIT_HASH=$(RUST_INIT_HASH) \
		--url $(PUBLISH_URL)/$(DISTRO) \
		$(PUBLISH_TAGS_ARGS) \
		$(PUBLISH_CREDS) \
		$(PUBLISH_EXTRA_ARGS)

.PHONY: test
test: $(STACKER)
	$(STACKER_WITH_BUILD_DIR) \
		build -f stacker-test.yaml \
		--layer-type $(LAYER_TYPE) \
		--substitute LAYER_SUFFIX=$(LAYER_SUFFIX) \
		--substitute BUILD_OCI_DIR=$(BUILD_OCI_DIR) \
		--substitute OS=$(OS) \
		--substitute ARCH=$(ARCH) \
		--substitute DISTRO=$(DISTRO) \
		--substitute DISTRO_REL=$(DISTRO_REL)

.PHONY: pkgs
pkgs:

.PHONY: pull
pull: check-skopeo
	skopeo copy $(PULL_EXTRA_ARGS) $(PUBLISH_URL)/$(strip $(DISTRO))/$(strip $(PUBLISH_IMAGE_NAME)):$(PUBLISH_TAG)$(LAYER_SUFFIX) oci:$(BUILD_OCI_DIR):$(PUBLISH_IMAGE_NAME)$(LAYER_SUFFIX)
