MAKE?=make
COMMIT_HASH=$(shell git describe --always --tags --long)
COMMIT?=$(if $(shell git status --porcelain --untracked-files=no),$(COMMIT_HASH)-dirty,$(COMMIT_HASH))
OS?=linux			# other options: <none>
ARCH?=amd64		# other options: arm64
DISTRO?=ubuntu	# other options: debian, rockylinux
DISTRO_REL?=jammy	# other options: bullseye, 9
# busybox
BUSYBOX?=1.35.0
# go
GOLANG?=1.19.2
GOLANG_HASH?=5e8c5a74fe6470dd7e055a461acda8bb4050ead8c2df70f227e3ff7d8eb7eeb6
GOLANG_DLV?=v1.9.1
GOLANG_LINTER?=v1.49.0
# openj9
OPENJDK?=11.0.16.1
OPENJ9?=0.33.1
OPENJ9_JDK_HASH?=4eb9dc86bf92e144d7a2c8d6c2a6beac28c17b7348f2f0524e715548f52fd8f1
OPENJ9_JRE_HASH?=038a44d5c81f14bce6458040f7b4eec48535dcbbdc59e3c536d6adc3326b64c7
