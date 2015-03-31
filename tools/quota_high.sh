#!/bin/bash
# Set quotas to a high level for admin tenant for testing.

TENANT_ID="$(keystone tenant-get admin | grep " id " | awk '{ print $4 }')"

nova quota-update \
--instances 300 \
--ram 2048000 \
--floating-ips 300 \
--fixed-ips 300 \
--cores 1200 \
--key-pairs 300 \
$TENANT_ID

neutron quota-update \
--network 100 \
--subnet 100 \
--port 300 \
--router 100 \
--floatingip 300 \
--security-group 300 \
--security-group-rule 300 \
--tenant-id $TENANT_ID

echo " + Quotas are now:"
nova quota-show
neutron quota-show

echo " + Setting n-c-c ram and cpu overcommits."
juju set nova-cloud-controller ram-allocation-ratio=100
juju set nova-cloud-controller cpu-allocation-ratio=100
