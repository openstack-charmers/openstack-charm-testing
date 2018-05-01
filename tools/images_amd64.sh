#!/bin/bash -ex
# Download amd64 images and add to glance.

: ${WGET_MODE}:=""
: ${TEST_IMAGE_NAME_XENIAL:="xenial"}
: ${TEST_IMAGE_NAME_CIRROS:="cirros"}
: ${TEST_IMAGE_NAME_BIONIC:="bionic"}

# Presumes cirros is available in a swift bucket
[[ -z "$SWIFT_IP" ]] && export SWIFT_IP="10.245.161.162"

# Download images if not already present
if [ -d ~/images ] ; then
        mkdir -vp ~/images
fi

openstack image show xenial || \
([ -f ~/images/xenial-server-cloudimg-amd64-disk1.img ] || {
    wget ${WGET_MODE} -O ~/images/xenial-server-cloudimg-amd64-disk1.img http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
}
glance --os-image-api-version 1 image-create --name="xenial" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/xenial-server-cloudimg-amd64-disk1.img

glance --os-image-api-version 1 image-update --property architecture=x86_64 xenial)


openstack image show bionic || \
([ -f ~/images/bionic-server-cloudimg-amd64-disk1.img ] || {
    wget ${WGET_MODE} -O ~/images/bionic-server-cloudimg-amd64.img http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
}
glance --os-image-api-version 1 image-create --name="bionic" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/bionic-server-cloudimg-amd64.img

glance --os-image-api-version 1 image-update --property architecture=x86_64 bionic)

openstack image show cirros || \
([ -f ~/images/cirros-0.3.4-x86_64-disk.img ] || {
    wget ${WGET_MODE} -O ~/images/cirros-0.3.4-x86_64-disk.img http://$SWIFT_IP:80/swift/v1/images/cirros-0.3.4-x86_64-disk.img
}


[ -f ~/images/cirros-0.3.4-x86_64-uec.tar.gz ] || {
    wget ${WGET_MODE} -O ~/images/cirros-0.3.4-x86_64-uec.tar.gz http://$SWIFT_IP:80/swift/v1/images/cirros-0.3.4-x86_64-uec.tar.gz
    (cd ~/images && tar -xzf cirros-0.3.4-x86_64-uec.tar.gz)
}

glance --os-image-api-version 1 image-create --name="cirros" --is-public=true  --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/cirros-0.3.4-x86_64-disk.img

glance --os-image-api-version 1 image-update --property architecture=x86_64 cirros)
