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

unpack_debs() {
  rootfs="$1"
  pkgs_file="$2"

  dldir=$(mktemp -d "${TMPDIR:-/tmp}"/XXXXXX)

  dpkg --add-architecture "$ARCH"

  DEBIAN_FRONTEND=noninteractive \
    xargs apt-get -y --reinstall install \
    "--option=Dir::Cache::Archives=$dldir" \
    --no-install-recommends \
    --download-only <$pkgs_file

  echo DLDIR="$dldir"
  ls "$dldir"/

  for file in "$dldir"/*.deb
  do
    dpkg-deb -xv "$file" "$rootfs"
  done

  rm -rf "$dldir"
}

unpack_rpm() {
  rootfs="$1"
  pkg="$2"
  arch="$(canonical_arch $ARCH)"

  dldir=$(mktemp -d "${TMPDIR:-/tmp}"/XXXXXX)

  dnf download --arch noarch,"$arch" --nodocs --downloaddir="$dldir" "$pkg"

  ls "$dldir"

  cwd=$(pwd)

  cd "$rootfs" || exit 1

  rpm2cpio "$dldir"/"$(ls $dldir)" | cpio -idmv

  cd "$cwd" || exit 1

  rm -rf "$dldir"
}

unpack_rpms() {
  rootfs="$1"
  pkg="$2"

  dldir=$(mktemp -d "${TMPDIR:-/tmp}"/XXXXXX)

  xargs dnf download --nodocs --downloaddir="$dldir" <$pkgs_file

  echo DLDIR="$dldir"
  ls "$dldir"/

  cwd=$(pwd)

  cd "$rootfs" || exit 1

  for file in "$dldir"/*.rpm
  do
    rpm2cpio "$file" | cpio -idmv
  done

  cd "$cwd" || exit 1

  rm -rf "$dldir"
}

install_certs() {
  rootfs="$1"; shift

  # The certs are normally unpacked by a separate script when the pkg is installed
  echo "copy certs -> [$rootfs/]"
  case $DISTRO in
    debian | ubuntu)
      cp -r /etc/ssl/certs "$rootfs"/etc/ssl/
      ;;
    rockylinux)
      cp -r /etc/ssl/ "$rootfs"/etc/
      cp -r /etc/pki/ "$rootfs"/etc/
      ;;
    *)
      exit 1
      ;;
  esac
}

install_pkgs() {
  rootfs="$1"; shift
  echo "install packages"

  echo "setup tools"
  case $DISTRO in
    debian | ubuntu)
      apt-get update
      ;;
    rockylinux)
      dnf makecache --refresh
      ;;
    *)
      exit 1
      ;;
  esac

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

install_pkgs_from_file() {
  rootfs="$1"
  pkgs_file="$2"

  if [ -s $pkgs_file ]; then
    echo "install packages: $pkgs_file -> [$rootfs/]"
  else
    echo "empty packages file: $pkgs_file - assuming no pkgs should be installed"
    return 0
  fi

  echo "setup tools"
  case $DISTRO in
    debian | ubuntu)
      apt-get update
      unpack_debs "$rootfs" "$pkgs_file"
      ;;
    rockylinux)
      dnf makecache --refresh
      unpack_rpms "$rootfs" "$pkgs_file"
      ;;
    *)
      exit 1
      ;;
  esac
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

update_host_pkgs() {
  echo "host_update"
  case $DISTRO in
    ubuntu | debian)
      apt-get update && apt-get dist-upgrade -y
      ;;
    rockylinux)
      dnf -y update --refresh
      ;;
    *)
      exit 1
      ;;
  esac
}

install_host_pkgs() {
  update_host_pkgs

  echo "host_install: $@"
  case $DISTRO in
    ubuntu | debian)
      apt-get install --no-install-recommends -y "$@"
      ;;
    rockylinux)
      dnf -y install "$@"
      ;;
    *)
      exit 1
      ;;
  esac
}
