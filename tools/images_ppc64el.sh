#!/bin/bash -e
# Download ppc64el images and add to glance.

# Download images if not already present
mkdir -p ~/images
[ -f ~/images/vivid-server-cloudimg-ppc64el-disk1.img ] || {
    wget -O ~/images/vivid-server-cloudimg-ppc64el-disk1.img http://cloud-images.ubuntu.com/vivid/current/vivid-server-cloudimg-ppc64el-disk1.img
}
[ -f ~/images/utopic-server-cloudimg-ppc64el-disk1.img ] || {
    wget -O ~/images/utopic-server-cloudimg-ppc64el-disk1.img http://cloud-images.ubuntu.com/utopic/current/utopic-server-cloudimg-ppc64el-disk1.img
}
[ -f ~/images/trusty-server-cloudimg-ppc64el-disk1.img ] || {
    wget -O ~/images/trusty-server-cloudimg-ppc64el-disk1.img http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-ppc64el-disk1.img
}

# Upload glance images to overcloud
glance image-create --name="vivid-ppc64el" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/vivid-server-cloudimg-ppc64el-disk1.img
glance image-create --name="utopic-ppc64el" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/utopic-server-cloudimg-ppc64el-disk1.img
glance image-create --name="trusty-ppc64el" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/trusty-server-cloudimg-ppc64el-disk1.img

glance image-update --property architecture=ppc64 vivid-ppc64el
glance image-update --property architecture=ppc64 utopic-ppc64el
glance image-update --property architecture=ppc64 trusty-ppc64el
