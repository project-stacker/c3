# c3: "composing concise containers" for everyone!

OCI-native distroless containers built using
[stacker](https://github.com/project-stacker/stacker).

This project is a OCI-native alternative to
[gcr/distroless](https://github.com/GoogleContainerTools/distroless).

Images from this repo are built, signed using
[`cosign`](https://github.com/sigstore/cosign) and pushed to [zothub.io](https://zothub.io).

**DISCLAIMER**: These images are experimental. We assume no responsibility for
these. Use these images at your own risk.

## List of Images

The following [images](./images) built and published. All `*-devel` have the [`busybox`](https://busybox.net/) shell packaged.

```
zothub.io/project-stacker/c3/base-debian-amd64                              bullseye                  e8ea3b49      7.5MB
zothub.io/project-stacker/c3/base-rockylinux-amd64                          9                         d1433c16      4.5MB
zothub.io/project-stacker/c3/base-ubuntu-amd64                              jammy                     18f24db2      8.6MB
zothub.io/project-stacker/c3/go-devel-debian-amd64                          1.19.1                    8d1fe900      197MB
zothub.io/project-stacker/c3/go-devel-rockylinux-amd64                      1.19.1                    699b0f68      181MB
zothub.io/project-stacker/c3/go-devel-ubuntu-amd64                          1.19.1                    e426048c      189MB
zothub.io/project-stacker/c3/openj9-debian-amd64                            11                        2a3976c5      59MB
zothub.io/project-stacker/c3/openj9-devel-debian-amd64                      11                        2d1af0d0      220MB
zothub.io/project-stacker/c3/openj9-devel-rockylinux-amd64                  11                        6e47bf68      217MB
zothub.io/project-stacker/c3/openj9-devel-ubuntu-amd64                      11                        cc67cc9f      221MB
zothub.io/project-stacker/c3/openj9-rockylinux-amd64                        11                        4c2d336c      56MB
zothub.io/project-stacker/c3/openj9-ubuntu-amd64                            11                        c0ca37b3      60MB
zothub.io/project-stacker/c3/static-debian-amd64                            bullseye                  041ce0bd      726kB
zothub.io/project-stacker/c3/static-rockylinux-amd64                        9                         e0410020      1.6MB
zothub.io/project-stacker/c3/static-ubuntu-amd64                            jammy                     d2e150be      880kB
```

## Testing `*-devel` Images

### With `podman`

```
$ podman run -it zothub.io/project-stacker/c3/go-devel-ubuntu-amd64:1.19.1
/ # go version
go version go1.19.1 linux/amd64
/ #
```
