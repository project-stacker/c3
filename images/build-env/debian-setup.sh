#!/bin/sh

dpkg --add-architecture arm64

# No additional setup should be needed to make arm64 package downloads possible
# as the URLs are already configurable through variables