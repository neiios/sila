#!/usr/bin/env bash

# Usage:
# $1 - either "uefi" or "bios". Will be used as a VM type.
# $2 - full path to the repo. Will be used for a VM folder passthrough.

set -euo pipefail
IFS=$'\n\t'

function pre_checks() {
    if [[ ! -d scripts ]]; then
        echo "Run the script from a project root"
        exit 69
    fi
}

function create_vm() {
    echo "Creating a virtual machine"

    if [[ "$vm_type" == "bios" ]]; then
        virt-install --connect qemu:///system --boot uefi \
            --name archlinux --ram 4096 --disk size=40 --vcpus 4 \
            --osinfo archlinux --video qxl \
            --cdrom "${repo_path}/archlinux.iso" \
            --filesystem "$repo_path,sila-repo-tag" &
    else
        virt-install --connect qemu:///system --boot uefi \
            --name archlinux --ram 4096 --disk size=40 --vcpus 4 \
            --osinfo archlinux --video qxl \
            --cdrom "${repo_path}/archlinux.iso" \
            --filesystem "$repo_path,sila-repo-tag" &
    fi

    trap cleanup_vm EXIT SIGINT

    echo "Waiting for the virtual machine to boot"
    while ! nc -z "$(sudo virsh domifaddr archlinux | sed -n 3p | awk '{print $4}' | cut -d/ -f1)" 22 &>/dev/null; do
        sleep 2
    done
    vm_ip="$(sudo virsh domifaddr archlinux | sed -n 3p | awk '{print $4}' | cut -d/ -f1)"

    sudo virsh set-user-password archlinux root root
}

function cleanup_vm() {
    sudo virsh destroy archlinux

    if [[ "$vm_type" == "bios" ]]; then
        sudo virsh undefine archlinux
    else
        sudo virsh undefine --nvram archlinux
    fi

    sudo rm /var/lib/libvirt/images/archlinux.qcow2
    sudo virsh pool-refresh default
}

function prepare_folder() {
    sshpass -p root ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "root@$vm_ip" \
        "mount --mkdir -t 9p -o trans=virtio,version=9p2000.L sila-repo-tag /tmp/sila"
    sshpass -p root ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "root@$vm_ip" \
        "echo 'bash /tmp/sila/scripts/1-archinstall.sh' >>/root/.zprofile"
    sshpass -p root ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "root@$vm_ip" \
        "reflector --save /etc/pacman.d/mirrorlist --country Germany, --protocol https --latest 20 --sort rate"
    sshpass -p root ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "root@$vm_ip" \
        "echo "Sila is ready. Press Ctrl-d" >>/dev/tty1"
}

repo_path="${2:-"/home/egor/Dev/sila"}"
vm_type="$1"

# HACK: This is a workaround for the issue I am having where libvirtd just gets stuck
sudo systemctl restart libvirtd

pre_checks "$@"
create_vm "$@"
prepare_folder

echo "Waiting for a VM to finish"
for job in $(jobs -p); do
    wait "$job"
done
