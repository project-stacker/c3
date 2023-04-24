include config.mk
include tools.mk

SUBDIRS := static base devel go-devel openj9-devel openj9 multitool
BUILD_ORDER_FILE := $(BUILD_DIR)/build_order.json
PREREQUISITES_FILE := $(BUILD_DIR)/prerequisites.json

.DEFAULT_GOAL := all

.PHONY: all
all: $(STACKER) build

.PHONY: build
build: build-order download-skippable-images
	mkdir -p $(BUILD_DIR); \
	jq -c -r '.[][]' $(BUILD_ORDER_FILE) | while read dir; do \
		echo "building $$dir"; \
		$(MAKE) -C images/$$dir || exit $$?; \
	done

.PHONY: build-order
build-order:
	mkdir -p $(BUILD_DIR); \
	rm -f $(BUILD_ORDER_FILE); \
	$(DEPS_SCRIPT) --deps-file $(DEPS_FILE) --images $(subst $(space),$(comma),$(SUBDIRS)) --build-order --out-file $(BUILD_ORDER_FILE)

.PHONY: identify-skippable-images
identify-skippable-images:
	mkdir -p $(BUILD_DIR); \
	rm -f $(PREREQUISITES_FILE); \
	$(DEPS_SCRIPT) --deps-file $(DEPS_FILE) --images $(subst $(space),$(comma),$(SUBDIRS)) --prerequisites --out-file  $(PREREQUISITES_FILE)

.PHONY: download-skippable-images
download-skippable-images: identify-skippable-images check-skopeo
	if [ -z $(PUBLISH_URL) ]; then \
		echo "publish URL is empty - skip downloading prerequisites"; exit 0; \
	fi; \
	jq -c -r '.[]' $(PREREQUISITES_FILE) | while read dir; do \
		echo "downloading pre-exiting image for $$dir"; \
		$(MAKE) -C images/$$dir pull || exit $$?; \
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
