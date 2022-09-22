include ../../config.mk

SRC := $(wildcard *.yaml)
IMAGES := $(patsubst %.yaml,%,$(SRC))

.PHONY: all
all: $(IMAGES) test

.PHONY: %
%:
	stacker build -f $*.yaml \
		--substitute REVISION=$(COMMIT) \
		--substitute LICENSES="$(shell cat LICENSE.md)" \
		--substitute DESCRIPTION="$(shell cat README.md)" \
		--substitute OS=$(OS) \
		--substitute ARCH=$(ARCH) \
		--substitute DISTRO=$(DISTRO) \
		--substitute DISTRO_REL=$(DISTRO_REL) \
		--substitute OPENJDK=$(OPENJDK) \
		--substitute OPENJ9=$(OPENJ9) \
		--substitute BUSYBOX=$(BUSYBOX)

.PHONY: test
test:

.PHONY: clean
clean:
	stacker clean
