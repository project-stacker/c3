#!/bin/sh

dpkg --add-architecture arm64

# Ubuntu has different URLs for hosting repositories containing arm64 packages
cat > /etc/apt/sources.list << EOF
deb [arch=amd64,i386] http://archive.ubuntu.com/ubuntu/ ${DISTRO_REL} main multiverse universe restricted
deb [arch=amd64,i386] http://archive.ubuntu.com/ubuntu/ ${DISTRO_REL}-updates main multiverse universe restricted
deb [arch=amd64,i386] http://archive.ubuntu.com/ubuntu/ ${DISTRO_REL}-backports main multiverse universe restricted
deb [arch=amd64,i386] http://security.ubuntu.com/ubuntu/ ${DISTRO_REL}-security main multiverse universe restricted
deb [arch=arm64] http://ports.ubuntu.com/ ${DISTRO_REL} main multiverse universe restricted
deb [arch=arm64] http://ports.ubuntu.com/ ${DISTRO_REL}-security main multiverse universe restricted
deb [arch=arm64] http://ports.ubuntu.com/ ${DISTRO_REL}-backports main multiverse universe restricted
deb [arch=arm64] http://ports.ubuntu.com/ ${DISTRO_REL}-updates main multiverse universe restricted
EOF
