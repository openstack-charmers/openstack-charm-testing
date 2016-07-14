#!/bin/bash -e
# Download ppc64el images and add to glance.

# Download images if not already present
mkdir -p ~/images
[ -f ~/images/xenial-server-cloudimg-ppc64el-disk1.img ] || {
    wget -O ~/images/xenial-server-cloudimg-ppc64el-disk1.img http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-ppc64el-disk1.img
}
[ -f ~/images/trusty-server-cloudimg-ppc64el-disk1.img ] || {
    wget -O ~/images/trusty-server-cloudimg-ppc64el-disk1.img http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-ppc64el-disk1.img
}
[ -f ~/images/cirros-d150923-ppc64le-disk.img ] || {
    wget -O ~/images/cirros-d150923-ppc64le-disk.img http://download.cirros-cloud.net/daily/20150923/cirros-d150923-ppc64le-disk.img
}


# Upload glance images to overcloud
glance --os-image-api-version 1 image-create --name="xenial-ppc64el" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/xenial-server-cloudimg-ppc64el-disk1.img
glance --os-image-api-version 1 image-create --name="trusty-ppc64el" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/trusty-server-cloudimg-ppc64el-disk1.img
glance --os-image-api-version 1 image-create --name="cirros-ppc64el" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/cirros-d150923-ppc64le-disk.img


# Set image architecture properties
glance --os-image-api-version 1 image-update --property architecture=ppc64 xenial-ppc64el
glance --os-image-api-version 1 image-update --property architecture=ppc64 trusty-ppc64el
glance --os-image-api-version 1 image-update --property architecture=ppc64 cirros-ppc64el
