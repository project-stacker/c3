#!/bin/sh

canonical_arch() {
  arch="$1"

  case $arch in
    amd64 | x86_64)
      carch=x86_64
      ;;
    *)
      carch="$arch"
      ;;
  esac

  echo "$carch"
}

canonical_os() {
  os="$1"

  case $os in
    GNU/Linux)
      cos=linux
      ;;
    *)
      carch="$os"
      ;;
  esac

  echo "$cos"
}

unpack_deb() {
  rootfs="$1"
  pkg="$2"
  arch="$(canonical_arch $ARCH)"

  apt-get update

  dldir=$(mktemp -d "${TMPDIR:-/tmp}"/XXXXXX)

  dpkg --add-architecture "$ARCH"

  DEBIAN_FRONTEND=noninteractive \
    apt-get -y --reinstall install \
    "--option=Dir::Cache::Archives=$dldir" \
    --no-install-recommends \
    --download-only \
    "$pkg":"$ARCH"

  echo DLDIR="$dldir"
  ls "$dldir"

  dpkg-deb -xv "$dldir"/"$pkg"_*.deb "$rootfs"

  rm -rf "$dldir"
}

unpack_rpm() {
  rootfs="$1"
  pkg="$2"
  arch="$(canonical_arch $ARCH)"

  yum makecache
  yum -y install cpio
  dnf -y install dnf-plugins-core

  dldir=$(mktemp -d "${TMPDIR:-/tmp}"/XXXXXX)

  dnf download --arch noarch,"$arch" --nodocs --downloaddir="$dldir" "$pkg"

  ls "$dldir"

  cwd=$(pwd)

  cd "$rootfs" || exit 1

  rpm2cpio "$dldir"/"$(ls $dldir)" | cpio -idmv

  cd "$cwd" || exit 1

  rm -rf "$dldir"
}

install_pkgs() {
  rootfs="$1"; shift

  for pkg in "$@"; do
    echo "install: $pkg -> [$rootfs/]"
    case $DISTRO in
      debian | ubuntu)
        unpack_deb "$rootfs" "$pkg"
        ;;
      rockylinux)
        unpack_rpm "$rootfs" "$pkg"
        ;;
      *)
        exit 1
        ;;
    esac
  done
}

install_busybox () {
 rootfs="$1"
 arch="$(canonical_arch $ARCH)"

 # busybox
 wget -N https://busybox.net/downloads/binaries/"$BUSYBOX"-"$arch"-"$OS"-musl/busybox
 chmod +x busybox
 mkdir -p "$rootfs"/bin
 cp busybox "$rootfs"/bin/
 #busybox_path=$(realpath "$rootfs"/bin)
 for i in $(./busybox --list-full); do 
   echo "$i" 
   dir=$(dirname "$i") 
   base=$(basename "$i") 
   mkdir -p "$rootfs"/"$dir"
   cwd=$(pwd)
   cd "$rootfs"/"$dir" || exit 1
   ln -sfv /bin/busybox "$base"
   cd "$cwd" || exit 1
 done;
}

cleanup_rootfs() {
   rootfs="$1"

  # rm all tmp/, var/ files
  rm -rf "$rootfs"/tmp/*
  rm -rf "${rootfs:?}"/var/*
  # remove all binaries unless explicitly installed
  rm -rf "${rootfs:?}"/usr/bin/*
  rm -rf "$rootfs"/usr/sbin/*
  # remove all docs
  rm -rf "$rootfs"/usr/share/doc/*
  rm -rf "$rootfs"/usr/share/man/*
}

pkg_rootfs() {
   rootfs="$1"

  cleanup_rootfs "$rootfs"

  cwd=$(pwd)
  cd "$rootfs" || exit 1

  if [ -f /rootfs.tar ]; then
    # Legacy layers would 'tar rpvf /rootfs.tar .'
    # make sure the repackaging rootfs.tar pattern is not allowed
    # and we rely on base images instead
    exit 1
  else
    tar cpvf /rootfs.tar .
  fi

  cd "$cwd" || exit 1

  ls -altr /rootfs.tar
  sha256sum /rootfs.tar
}

build_rootfs() {
  mkdir rootfs

  # install pkgs
  install_pkgs rootfs $PKGS

  # post-build packaging
  pkg_rootfs rootfs

  # post-packaging cleanup
  rm -rf rootfs
}

install_host_pkgs() {
  for pkg in "$@"; do
    echo "host_install: $pkg"
    case $DISTRO in
      ubuntu | debian)
        apt-get update && apt-get dist-upgrade -y
        apt-get install -y "$pkg"
        ;;
      rockylinux)
        yum makecache
        yum -y install "$pkg"
        ;;
      *)
        exit 1
        ;;
    esac
  done
}
