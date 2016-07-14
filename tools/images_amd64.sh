#!/bin/bash -e
# Download ppc64el images and add to glance.

# Presumes cirros is available in a swift bucket
[[ -z "$SWIFT_IP" ]] && export SWIFT_IP="10.245.161.162"

# Download images if not already present
mkdir -vp ~/images
[ -f ~/images/xenial-server-cloudimg-amd64-disk1.img ] || {
    wget -O ~/images/xenial-server-cloudimg-amd64-disk1.img http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
}
[ -f ~/images/trusty-server-cloudimg-amd64-disk1.img ] || {
    wget -O ~/images/trusty-server-cloudimg-amd64-disk1.img http://cloud-images.ubuntu.com/trusty/current/trusty-server-cloudimg-amd64-disk1.img
}
[ -f ~/images/precise-server-cloudimg-amd64-disk1.img ] || {
    wget -O ~/images/precise-server-cloudimg-amd64-disk1.img http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img
}
[ -f ~/images/cirros-0.3.4-x86_64-disk.img ] || {
    wget -O ~/images/cirros-0.3.4-x86_64-disk.img http://$SWIFT_IP:80/swift/v1/images/cirros-0.3.4-x86_64-disk.img
}
[ -f ~/images/cirros-0.3.4-x86_64-uec.tar.gz ] || {
    wget -O ~/images/cirros-0.3.4-x86_64-uec.tar.gz http://$SWIFT_IP:80/swift/v1/images/cirros-0.3.4-x86_64-uec.tar.gz
    (cd ~/images && tar -xzf cirros-0.3.4-x86_64-uec.tar.gz)
}

# Upload glance images to overcloud
glance --os-image-api-version 1 image-create --name="xenial" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/xenial-server-cloudimg-amd64-disk1.img
glance --os-image-api-version 1 image-create --name="trusty" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/trusty-server-cloudimg-amd64-disk1.img
glance --os-image-api-version 1 image-create --name="precise" --is-public=true --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/precise-server-cloudimg-amd64-disk1.img
glance --os-image-api-version 1 image-create --name="cirros" --is-public=true  --progress \
    --container-format=bare --disk-format=qcow2 < ~/images/cirros-0.3.4-x86_64-disk.img

glance --os-image-api-version 1 image-update --property architecture=x86_64 xenial
glance --os-image-api-version 1 image-update --property architecture=x86_64 trusty
glance --os-image-api-version 1 image-update --property architecture=x86_64 precise
glance --os-image-api-version 1 image-update --property architecture=x86_64 cirros
