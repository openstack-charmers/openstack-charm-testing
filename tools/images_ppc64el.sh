#!/bin/bash -ex
# Download ppc64el images and add to glance.

# Download images if not already present
: ${WGET_MODE}:=""
: ${TEST_IMAGE_URL_XENIAL:="http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-ppc64el-disk1.img"}
: ${TEST_IMAGE2_URL_XENIAL:="http://download.cirros-cloud.net/daily/20150923/cirros-d150923-ppc64le-disk.img"}
: ${TEST_IMAGE_NAME_XENIAL:="xenial-ppc64el"}
: ${TEST_IMAGE2_NAME_XENIAL:="cirros-ppc64el"}

if [ ! -d ~/images ] ; then
        mkdir -p ~/images
fi

openstack image show ${TEST_IMAGE_NAME_XENIAL} ||
([ -f ~/images/xenial-server-cloudimg-ppc64el-disk1.img ] || {
    wget ${WGET_MODE} -O ~/images/xenial-server-cloudimg-ppc64el-disk1.img $TEST_IMAGE_URL_XENIAL
}

glance --os-image-api-version 1 image-create --name="xenial-ppc64el" --is-public=true --progress \
        --container-format=bare --disk-format=qcow2 < ~/images/xenial-server-cloudimg-ppc64el-disk1.img

glance --os-image-api-version 1 image-update --property architecture=ppc64 xenial-ppc64el)

openstack image show ${TEST_IMAGE2_NAME_XENIAL} ||
([ -f ~/images/cirros-d150923-ppc64le-disk.img ] || {
    wget ${WGET_MODE} -O ~/images/cirros-d150923-ppc64le-disk.img $TEST_IMAGE2_URL_XENIAL
}

glance --os-image-api-version 1 image-create --name="cirros-ppc64el" --is-public=true --progress \
        --container-format=bare --disk-format=qcow2 < ~/images/cirros-d150923-ppc64le-disk.img

glance --os-image-api-version 1 image-update --property architecture=ppc64 cirros-ppc64el)
