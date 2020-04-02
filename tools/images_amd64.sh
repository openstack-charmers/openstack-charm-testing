#!/bin/bash -ex
# Download amd64 images and add to glance.

: ${WGET_MODE}:=""
: ${TEST_IMAGE_NAME_XENIAL:="xenial"}
: ${TEST_IMAGE_NAME_CIRROS:="cirros"}
: ${TEST_IMAGE_NAME_BIONIC:="bionic"}

: ${WGET_MODE}:=""

# Presumes cirros is available in a swift bucket
[[ -z "$SWIFT_IP" ]] && export SWIFT_IP="10.245.161.162"

# Download images if not already present
if [ ! -d ~/images ] ; then
        mkdir -vp ~/images
fi


if  juju status nova-compute|grep "lxd/"; then
        openstack image show bionic-amd64 || \
        ([ -f ~/images/bionic-server-cloudimg-amd64-root.tar.xz ] || {
            export http_proxy=http://squid.internal:3128
            wget ${WGET_MODE} -O ~/images/bionic-server-cloudimg-amd64-root.tar.xz http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64-root.tar.xz
            export http_proxy=''
        }
        openstack image create --public --container-format bare --disk-format raw --property architecture=x86_64 --property hypervisor_type=lxc --file ~/images/bionic-server-cloudimg-amd64-root.tar.xz bionic-amd64
        )
else
       openstack image show bionic-amd64 || \
        ([ -f ~/images/bionic-server-cloudimg-amd64.img ] || {
            export http_proxy=http://squid.internal:3128
            wget ${WGET_MODE} -O ~/images/bionic-server-cloudimg-amd64.img http://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
            export http_proxy=''
        }
        openstack image create --public --container-format bare --disk-format qcow2 --property architecture=x86_64 --file ~/images/bionic-server-cloudimg-amd64.img bionic-amd64
        )
fi

openstack image show xenial || \
([ -f ~/images/xenial-server-cloudimg-amd64-disk1.img ] || {
    export http_proxy=http://squid.internal:3128
    wget ${WGET_MODE} -O ~/images/xenial-server-cloudimg-amd64-disk1.img http://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-disk1.img
    export http_proxy=''
}
openstack image create --public --container-format bare --disk-format qcow2 --property architecture=x86_64 --file ~/images/xenial-server-cloudimg-amd64-disk1.img xenial
)

openstack image show cirros || \
([ -f ~/images/cirros-0.3.4-x86_64-disk.img ] || {
    export http_proxy=http://squid.internal:3128
    wget ${WGET_MODE} -O ~/images/cirros-0.3.4-x86_64-disk.img http://$SWIFT_IP:80/swift/v1/images/cirros-0.3.4-x86_64-disk.img
    export http_proxy=''
}


#[ -f ~/images/cirros-0.3.4-x86_64-uec.tar.gz ] || {
#    export http_proxy=http://squid.internal:3128
#    wget ${WGET_MODE} -O ~/images/cirros-0.3.4-x86_64-uec.tar.gz http://$SWIFT_IP:80/swift/v1/images/cirros-0.3.4-x86_64-uec.tar.gz
#    export http_proxy=''
#    (cd ~/images && tar -xzf cirros-0.3.4-x86_64-uec.tar.gz)
#}
openstack image create --public --container-format bare --disk-format qcow2 --property architecture=x86_64 --file ~/images/cirros-0.3.4-x86_64-disk.img cirros
)
