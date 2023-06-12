include config.mk

TOP_LEVEL=$(shell git rev-parse --show-toplevel)
BUILD_DIR := $(TOP_LEVEL)/build
SUBDIRS := static base base-devel go-devel rust-devel openj9-devel openj9 multitool
BUILD_ORDER_FILE := $(BUILD_DIR)/build_order.json
PREREQUISITES_FILE := $(BUILD_DIR)/prerequisites.json
DEPS_FILE := $(TOP_LEVEL)/image_deps.json
DEPS_SCRIPT := $(TOP_LEVEL)/get_deps.py
comma := ,
space := $(null) #

.DEFAULT_GOAL := all

.PHONY: all
all: build test

.PHONY: build
build: build-order download-skippable-images
	mkdir -p $(BUILD_DIR); \
	jq -c -r '.[][]' $(BUILD_ORDER_FILE) | while read dir; do \
		echo "building $$dir"; \
		$(MAKE) -C images/$$dir build || exit $$?; \
	done

.PHONY: build-order
build-order:
	mkdir -p $(BUILD_DIR); \
	rm -f $(BUILD_ORDER_FILE); \
	$(DEPS_SCRIPT) --deps-file $(DEPS_FILE) --images $(subst $(space),$(comma),$(SUBDIRS)) --build-order --out-file $(BUILD_ORDER_FILE)

.PHONY: build-candidates
build-candidates: build-order
	jq -c -j '.[][] + " "' $(BUILD_ORDER_FILE) | xargs echo -n

.PHONY: identify-skippable-images
identify-skippable-images:
	mkdir -p $(BUILD_DIR); \
	rm -f $(PREREQUISITES_FILE); \
	$(DEPS_SCRIPT) --deps-file $(DEPS_FILE) --images $(subst $(space),$(comma),$(SUBDIRS)) --prerequisites --out-file  $(PREREQUISITES_FILE)

.PHONY: download-skippable-images
download-skippable-images: identify-skippable-images
	if [ -z $(PUBLISH_URL) ]; then \
		echo "publish URL is empty - skip downloading prerequisites"; exit 0; \
	fi; \
	jq -c -r '.[]' $(PREREQUISITES_FILE) | while read dir; do \
		echo "downloading pre-exiting image for $$dir"; \
		$(MAKE) -C images/$$dir pull || exit $$?; \
	done

.PHONY: pkgs
pkgs:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C images/$$dir pkgs || exit $$?; \
	done

.PHONY: test
test:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C images/$$dir test || exit $$?; \
	done

.PHONY: publish
publish:
	for dir in $(SUBDIRS); do \
		$(MAKE) -C images/$$dir publish || exit $$?; \
	done

.PHONY: clean
clean: 
	for dir in $(SUBDIRS); do \
		$(MAKE) -C images/$$dir clean; \
	done; \
	rm -rf $(BUILD_DIR)
