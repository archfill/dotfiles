#!/usr/bin/env bash

# Detect OS architecture
get_os_bit() {
    uname -m
}

# Detect Linux distribution name
get_os_distribution() {
    local distri_name="unknown"

    if [[ -e /etc/lsb-release ]]; then
        distri_name="ubuntu"
    elif [[ -e /etc/debian_version || -e /etc/debian_release ]]; then
        distri_name="debian"
    elif [[ -e /etc/fedora-release ]]; then
        distri_name="fedora"
    elif [[ -e /etc/oracle-release ]]; then
        distri_name="oracle"
    elif [[ -e /etc/redhat-release ]]; then
        distri_name="redhat"
    elif [[ -e /etc/arch-release ]]; then
        distri_name="arch"
    elif [[ -e /etc/SuSE-release ]]; then
        distri_name="suse"
    elif [[ -e /etc/mandriva-release ]]; then
        distri_name="mandriva"
    elif [[ -e /etc/vine-release ]]; then
        distri_name="vine"
    elif [[ -e /etc/gentoo-release ]]; then
        distri_name="gentoo"
    fi

    echo "${distri_name}"
}

# Output OS distribution and architecture
get_os_info() {
    echo "$(get_os_distribution) $(get_os_bit)"
}

# Execute
get_os_info
