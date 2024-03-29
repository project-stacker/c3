MAKE?=make
COMMIT=$(shell git describe --always --tags --long --dirty)
COMMIT_HASH=$(shell git rev-parse --short HEAD)
DEFAULT_BRANCH?=$(shell git rev-parse --short HEAD)  # Default branch used for publishing with default image tags
DEFAULT_BRANCH_HASH=$(shell git rev-parse --short $(DEFAULT_BRANCH))  # tip of default branch
OS?=linux			# other options: <none>
ARCH?=amd64		# other options: arm64
DISTRO?=ubuntu	# other options: debian, rockylinux
DISTRO_REL?=jammy	# other options: bullseye, 9
LAYER_TYPE?=tar	# type of layer produced: tar or squashfs
PUBLISH_URL?=	# URL where to publish the results, for example docker://localhost:5000/c3
PUBLISH_EXTRA_ARGS= 	# string containing situational arguments
PUBLISH_TAG?=	# if set, it will override the image specific tags
PUBLISH_TAG_SUFFIX?=$(if $(shell git status --porcelain --untracked-files=no),$(COMMIT_HASH)-dirty,$(COMMIT_HASH))
PUBLISH_USERNAME?=	# if set, this username will be used to publish the images on the registry
PUBLISH_PASSWORD?= 	# if set, this password will be used to publish the images on the registry
PULL_EXTRA_ARGS?=	# string containing credentials and/or other situational arguments

PUBLISH_CREDS :=
ifneq ($(PUBLISH_USERNAME),)
PUBLISH_CREDS := --username '$(PUBLISH_USERNAME)' --password '$(PUBLISH_PASSWORD)'
endif

ifeq ($(strip $(DEFAULT_BRANCH_HASH)),$(strip $(COMMIT_HASH)))
PUBLISH_TAGS=$(strip $(PUBLISH_TAG)) $(strip $(PUBLISH_TAG))-$(strip $(PUBLISH_TAG_SUFFIX))
PUBLISH_TAGS_ARGS=--tag $(strip $(PUBLISH_TAG)) --tag $(strip $(PUBLISH_TAG))-$(strip $(PUBLISH_TAG_SUFFIX))
else
PUBLISH_TAGS=$(strip $(PUBLISH_TAG))-$(strip $(PUBLISH_TAG_SUFFIX))
PUBLISH_TAGS_ARGS=--tag $(strip $(PUBLISH_TAG))-$(strip $(PUBLISH_TAG_SUFFIX))
endif
