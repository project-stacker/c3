#!/bin/sh -xe
apk update
apk --no-cache add libc-dev openssl-static-libs git
#git clone git://repo.or.cz/socat.git

