#!/bin/bash

enable_userns() {
    SYSCTL_USERNS="/etc/sysctl.d/00-enable-userns.conf"
    if ! [ -s "${SYSCTL_USERNS}" ]; then
        echo "Add kernel tunables to enable user namespaces in $SYSCTL_USERNS "
        cat <<EOF | sudo tee "${SYSCTL_USERNS}"
kernel.apparmor_restrict_unprivileged_io_uring = 0
kernel.apparmor_restrict_unprivileged_unconfined = 0
kernel.apparmor_restrict_unprivileged_userns = 0
kernel.apparmor_restrict_unprivileged_userns_complain = 0
kernel.apparmor_restrict_unprivileged_userns_force = 0
kernel.unprivileged_bpf_disabled = 2
kernel.unprivileged_userns_apparmor_policy = 0
kernel.unprivileged_userns_clone = 1
EOF
        sudo sysctl -p /etc/sysctl.d/00-enable-userns.conf
    fi
}

enable_userns
