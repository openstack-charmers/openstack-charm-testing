#!/bin/bash -ex
# Download images and add to glance.

: ${WGET_MODE}:=""
: ${TEST_IMAGE_URL_XENIAL:="http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-arm64-uefi1.img"}
: ${CIRROS_IMAGE_URL_XENIAL:="http://download.cirros-cloud.net/daily/20150522/cirros-d150522-aarch64-disk.img"}

mkdir -vp ~/images
[ -f ~/images/xenial-server-cloudimg-arm64-uefi1.img ] || {
    wget ${WGET_MODE} -O ~/images/xenial-server-cloudimg-arm64-uefi1.img $TEST_IMAGE_URL_XENIAL
}

export http_proxy=http://squid.internal:3128
    wget ${WGET_MODE} -O ~/images/cirros_test.img $CIRROS_IMAGE_URL_XENIAL
export http_proxy=''

# Create glance image
openstack image show xenial-uefi ||\
  openstack image create --public --container-format bare --disk-format qcow2 --property hw_firmware_type=uefi --file ~/images/xenial-server-cloudimg-arm64-uefi1.img xenial-uefi

openstack image show xenial-cirros ||\
  openstack image create --public --container-format bare --disk-format qcow2 --property hw_firmware_type=uefi --file ~/images/cirros_test.img xenial-cirros

openstack image show bionic || \
([ -f ~/images/bionic-server-cloudimg-arm64.img ] || {
    export http_proxy=http://squid.internal:3128
    wget ${WGET_MODE} -O ~/images/bionic-server-cloudimg-arm64.img http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-arm64.img
    export http_proxy=''
}
openstack image create --public --container-format bare --disk-format qcow2 --property hw_firmware_type=uefi --file ~/images/bionic-server-cloudimg-arm64.img bionic
)

openstack image show bionic-lxd || \
([ -f ~/images/bionic-server-cloudimg-arm64-lxd.tar.xz ] || {
    export http_proxy=http://squid.internal:3128
    wget ${WGET_MODE} -O ~/images/bionic-server-cloudimg-arm64-lxd.tar.xz http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-arm64-lxd.tar.xz
    export http_proxy=''
}
openstack image create --public --container-format bare --disk-format qcow2 --property hw_firmware_type=uefi --file ~/images/bionic-server-cloudimg-arm64-lxd.tar.xz bionic
)
