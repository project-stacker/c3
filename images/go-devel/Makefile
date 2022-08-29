include ../../config.mk

SRC := $(wildcard *.yaml)
IMAGES := $(patsubst %.yaml,%,$(SRC))

.PHONY: all
all: $(IMAGES) test

.PHONY: %
%:
	stacker build -f $*.yaml \
		--substitute BUILD_ID=$(COMMIT) \
		--substitute OS=$(OS) \
		--substitute ARCH=$(ARCH) \
		--substitute DISTRO=$(DISTRO) \
		--substitute DISTRO_REL=$(DISTRO_REL) \
		--substitute GOLANG=$(GOLANG) \
		--substitute GOLANG_DLV=$(GOLANG_DLV) \
		--substitute GOLANG_LINTER=$(GOLANG_LINTER) \
		--substitute BUSYBOX=$(BUSYBOX)

.PHONY: test
test:

.PHONY: clean
clean:
	stacker clean
