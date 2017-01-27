#!/bin/bash -e
# Download images and add to glance.

# Download images if not already present
mkdir -vp ~/images
[ -f ~/images/xenial-server-cloudimg-arm64-uefi1.img ] || {
    wget -O ~/images/xenial-server-cloudimg-arm64-uefi1.img http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-arm64-uefi1.img
}

# Create glance image
openstack image show xenial-uefi ||\
  openstack image create --container-format bare --disk-format qcow2 --property hw_firmware_type=uefi --file ~/images/xenial-server-cloudimg-arm64-uefi1.img xenial-uefi

