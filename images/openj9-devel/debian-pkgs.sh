#!/bin/sh

PKGS="ca-certificates-java"
# java is not installed using a deb
PKGS_EXCLUDE="dpkg debconf openjdk-17-jre-headless default-jre-headless"
PKGS_FILE=debian-pkgs
