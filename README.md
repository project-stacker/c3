# c3: "composing concise containers" for everyone!

OCI-native distroless containers built using
[`stacker`](https://github.com/project-stacker/stacker).

This project is a OCI-native alternative to
[gcr/distroless](https://github.com/GoogleContainerTools/distroless).

Images from this repo are built, signed using
[`cosign`](https://github.com/sigstore/cosign) and pushed to [zothub.io](https://zothub.io).

**DISCLAIMER**: These images are experimental. We assume no responsibility for
these. Use these images at your own risk.

## Guiding Principles

* This is **NOT** a new distribution!

_Maintained distributions_ are hard because it is a continuous process of
updating dependencies and fixing functional and security bugs. Instead, the
approach we have taken is to use existing distributions (they are good at what
they do) and produce images that developers can then use to build their own,
while keeping the entire build process transparent.

* Package only what is needed and nothing more!

The container images are built based on use cases. It is possible that some of
the images may not have your favorite tools or binaries. You are welcome to
submit a PR or build your own private images based on these.

## Prerequisites

* Requires a Linux environment with recent 5.x kernel.

## Build Images Locally

```
$ make
```

## List of Images

The following [images](./images) are built and published. All `*-devel` images have [`busybox`](https://busybox.net/) shell packaged.

```
IMAGE NAME                        TAG                       DIGEST      SIGNED      SIZE
c3/debian/base-amd64              bullseye           bb12c3a2    true        7.5MB
c3/debian/base-amd64              bullseye-squashfs  5244ad07    true        6.5MB
c3/debian/go-devel-amd64          1.19.2             093793a6    true        197MB
c3/debian/go-devel-amd64          1.19.2-squashfs    dc9e3859    true        175MB
c3/debian/openj9-amd64            11                 88f56c3d    true        59MB
c3/debian/openj9-amd64            11-squashfs        73a60848    true        51MB
c3/debian/openj9-devel-amd64      11                 77c76e2a    true        220MB
c3/debian/openj9-devel-amd64      11-squashfs        eed380d8    true        206MB
c3/debian/static-amd64            bullseye           9fe28bc9    true        724kB
c3/debian/static-amd64            bullseye-squashfs  44e9d704    true        471kB
c3/rockylinux/base-amd64          9                  33459f96    true        4.5MB
c3/rockylinux/base-amd64          9-squashfs         d0da8f36    true        3.8MB
c3/rockylinux/go-devel-amd64      1.19.2             17d8a0d3    true        181MB
c3/rockylinux/go-devel-amd64      1.19.2-squashfs    9e2da7a5    true        161MB
c3/rockylinux/openj9-amd64        11                 5c799cbb    true        56MB
c3/rockylinux/openj9-amd64        11-squashfs        f8b776fb    true        48MB
c3/rockylinux/openj9-devel-amd64  11                 97772632    true        217MB
c3/rockylinux/openj9-devel-amd64  11-squashfs        77a8ffc4    true        203MB
c3/rockylinux/static-amd64        9                  045fe728    true        1.6MB
c3/rockylinux/static-amd64        9-squashfs         0053a0a4    true        1.3MB
c3/ubuntu/base-amd64              jammy              a1075430    true        8.6MB
c3/ubuntu/base-amd64              jammy-squashfs     45e3b064    true        7.5MB
c3/ubuntu/go-devel-amd64          1.19.2             1217eff3    true        189MB
c3/ubuntu/go-devel-amd64          1.19.2-squashfs    f248eba2    true        167MB
c3/ubuntu/openj9-amd64            11                 15fde901    true        60MB
c3/ubuntu/openj9-amd64            11-squashfs        fac84fa6    true        52MB
c3/ubuntu/openj9-devel-amd64      11                 7e8d8d51    true        221MB
c3/ubuntu/openj9-devel-amd64      11-squashfs        033f1f94    true        207MB
c3/ubuntu/static-amd64            jammy              2e569eb6    true        880kB
c3/ubuntu/static-amd64            jammy-squashfs     1293c5fd    true        623kB
```

## Verify Image Signatures

```
$ cat << EOF > cosign.pub
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE3zTfLns0khZYaHjq2a3eMOYQMPYb
GCDqRLgXRNVN6qcKoGhvM2yvNnl8g3MpbuvusJGZF1c6TdedluirqS4Y/w==
-----END PUBLIC KEY-----
EOF

$ cosign verify --key cosign.pub zothub.io/project-stacker/c3/go-devel-ubuntu-amd64:1.19.1

Verification for zothub.io/project-stacker/c3/go-devel-ubuntu-amd64:1.19.1 --
The following checks were performed on each of these signatures:
  - The cosign claims were validated
  - The signatures were verified against the specified public key

[{"critical":{"identity":{"docker-reference":"zothub.io/project-stacker/c3/go-devel-ubuntu-amd64"},"image":{"docker-manifest-digest":"sha256:e426048cc64ca2c8d4b73cdf4b466e0cbb902e6ae35381c05eea63265c225b1b"},"type":"cosign container image signature"},"optional":null}]
```

## Testing `*-devel` Images

### With `podman`

```
$ podman run -it zothub.io/project-stacker/c3/go-devel-ubuntu-amd64:1.19.1
/ # go version
go version go1.19.1 linux/amd64
/ #
```

# Contributing

We encourage and support an active, healthy community of contributors.

* Details are in the [code of conduct](./CODE_OF_CONDUCT.md)
* Details to get started on code development are in [contributing](./CONTRIBUTING.md) document.
