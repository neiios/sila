#!/bin/bash

virt-install --connect qemu:///system --memory 4096 --vcpus 4 --osinfo archlinux --cdrom ~/Downloads/archlinux-2022.10.01-x86_64.iso --disk size=40

sudo virsh destroy archlinux && sudo virsh undefine archlinux --remove-all-storage

sudo virsh pool-refresh default
