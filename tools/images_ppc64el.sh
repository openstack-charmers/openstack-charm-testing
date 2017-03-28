#!/bin/bash -ex
# Download ppc64el images and add to glance.

# Download images if not already present
: ${TEST_IMAGE_URL_XENIAL:="http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-ppc64el-disk1.img"}
: ${TEST_IMAGE2_URL_XENIAL:="http://download.cirros-cloud.net/daily/20150923/cirros-d150923-ppc64le-disk.img"}

mkdir -p ~/images
[ -f ~/images/xenial-server-cloudimg-ppc64el-disk1.img ] || {
    wget -O ~/images/xenial-server-cloudimg-ppc64el-disk1.img $TEST_IMAGE_URL_XENIAL
}
[ -f ~/images/cirros-d150923-ppc64le-disk.img ] || {
    wget -O ~/images/cirros-d150923-ppc64le-disk.img $TEST_IMAGE2_URL_XENIAL
}

# Upload glance images to overcloud
glance --os-image-api-version 1 image-create --name="xenial-ppc64el" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/xenial-server-cloudimg-ppc64el-disk1.img
glance --os-image-api-version 1 image-create --name="cirros-ppc64el" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/cirros-d150923-ppc64le-disk.img

# Set image architecture properties
glance --os-image-api-version 1 image-update --property architecture=ppc64 xenial-ppc64el
glance --os-image-api-version 1 image-update --property architecture=ppc64 cirros-ppc64el
