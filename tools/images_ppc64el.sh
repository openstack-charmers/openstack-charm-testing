#!/bin/bash -e
# Download ppc64el images and add to glance.

# Download images if not already present
mkdir -p ~/images
[ -f ~/images/xenial-server-cloudimg-ppc64el-disk1.img ] || {
    wget -O ~/images/xenial-server-cloudimg-ppc64el-disk1.img http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-ppc64el-disk1.img
}
[ -f ~/images/wily-server-cloudimg-ppc64el-disk1.img ] || {
    wget -O ~/images/wily-server-cloudimg-ppc64el-disk1.img http://cloud-images.ubuntu.com/wily/current/wily-server-cloudimg-ppc64el-disk1.img
}
[ -f ~/images/trusty-server-cloudimg-ppc64el-disk1.img ] || {
    wget -O ~/images/trusty-server-cloudimg-ppc64el-disk1.img http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-ppc64el-disk1.img
}

# Upload glance images to overcloud
glance image-create --name="xenial-ppc64el" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/xenial-server-cloudimg-ppc64el-disk1.img
glance image-create --name="wily-ppc64el" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/wily-server-cloudimg-ppc64el-disk1.img
glance image-create --name="trusty-ppc64el" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/trusty-server-cloudimg-ppc64el-disk1.img

glance image-update --property architecture=ppc64 xenial-ppc64el
glance image-update --property architecture=ppc64 wily-ppc64el
glance image-update --property architecture=ppc64 trusty-ppc64el
