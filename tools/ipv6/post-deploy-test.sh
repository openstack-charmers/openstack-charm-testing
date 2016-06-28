#!/bin/bash -eu
source novarc
./configure.sh
set -x
keystone endpoint-list
glance image-list
nova list
cinder create --display-name vol1 1
cinder list
swift stat

neutron net-create private-vlan --provider:network_type vlan --provider:physical_network physnet1 --provider:segmentation_id 1000
neutron subnet-create --ip-version 6 private 2003:1803:ffe3:fa11::/64 private-vlan-subnet
nova boot --image cirros --flavor 1 --nic net-id=`neutron net-list| grep private| awk '{print $2}'` vm0 --poll
nova list
nova volume-attach `nova list| grep vm0| awk '{print $2}'` `cinder list| grep vol1| awk '{print $2}'`
cinder list


