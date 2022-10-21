include config.mk

TOOLS_DIR := hack/tools
TOOLS_BIN_DIR := $(TOOLS_DIR)/bin
export STACKER := $(TOOLS_BIN_DIR)/stacker

export BUILD_DIR := build/

SUBDIRS := images

.PHONY: all
all: $(STACKER) subdirs

$(STACKER):
	mkdir -p $(TOOLS_BIN_DIR)
	curl -fsSL https://github.com/project-stacker/stacker/releases/latest/download/stacker -o $@
	chmod +x $@

.PHONY: subdirs
subdirs:
	mkdir -p $(BUILD_DIR)
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir; \
	done

.PHONY: clean
clean: 
	for dir in $(SUBDIRS); do \
		$(MAKE) -C $$dir clean; \
	done
