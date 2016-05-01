#!/bin/bash -e
# Download LXD images and add to glance

# Download images if not already present
mkdir -vp ~/images
[ -f ~/images/trusty-server-cloudimg-amd64-root.tar.xz ] || {
    wget -O ~/images/trusty-server-cloudimg-amd64-root.tar.xz http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-root.tar.xz
}
[ -f ~/images/xenial-server-cloudimg-amd64-root.tar.xz ] || {
    wget -O ~/images/xenial-server-cloudimg-amd64-root.tar.xz http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-root.tar.xz
}

# Upload glance images to overcloud
glance --os-image-api-version 1 image-create --name="trusty-lxd" --is-public=true --progress \
    --container-format=bare --disk-format=raw --property hypervisor_type=lxc \
    --property architecture=x86_64 < ~/images/trusty-server-cloudimg-amd64-root.tar.xz

glance --os-image-api-version 1 image-create --name="xenial-lxd" --is-public=true --progress \
    --container-format=bare --disk-format=raw --property hypervisor_type=lxc \
    --property architecture=x86_64 < ~/images/xenial-server-cloudimg-amd64-root.tar.xz
