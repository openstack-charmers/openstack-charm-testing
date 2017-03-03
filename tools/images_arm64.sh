#!/bin/bash -e
# Download images and add to glance.

# Download images if not already present
: ${TEST_IMAGE_URL_XENIAL:="http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-arm64-uefi1.img"}

mkdir -vp ~/images
[ -f ~/images/xenial-server-cloudimg-arm64-uefi1.img ] || {
    wget -O ~/images/xenial-server-cloudimg-arm64-uefi1.img $TEST_IMAGE_URL_XENIAL
}

# Create glance image
openstack image show xenial-uefi ||\
  openstack image create --container-format bare --disk-format qcow2 --property hw_firmware_type=uefi --file ~/images/xenial-server-cloudimg-arm64-uefi1.img xenial-uefi

