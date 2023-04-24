MAKE?=make
COMMIT_HASH=$(shell git describe --always --tags --long)
COMMIT?=$(if $(shell git status --porcelain --untracked-files=no),$(COMMIT_HASH)-dirty,$(COMMIT_HASH))
OS?=linux			# other options: <none>
ARCH?=amd64		# other options: arm64
DISTRO?=ubuntu	# other options: debian, rockylinux
DISTRO_REL?=jammy	# other options: bullseye, 9
LAYER_TYPE?=tar	# type of layer produced: tar or squashfs
PUBLISH_URL?=	# URL where to publish the results, for example docker://localhost:5000/c3
PUBLISH_EXTRA_ARGS= 	# string containing credentials and/or other situational arguments
PUBLISH_TAG?=	# if set, it will override the image specific tags
PULL_EXTRA_ARGS=	# string containing credentials and/or other situational arguments