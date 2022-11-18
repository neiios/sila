#!/bin/bash

virt-install --connect qemu:///system --memory 4096 --vcpus 4 --video qxl --osinfo archlinux --cdrom ~/Downloads/archlinux-*-x86_64.iso --disk size=40

sudo virsh destroy archlinux && sudo virsh undefine archlinux --remove-all-storage

sudo virsh pool-refresh default
