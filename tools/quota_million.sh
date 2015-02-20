#!/bin/bash
# Set quotas to a ridiculous level for admin tenant for testing.

TENANT_ID="$(keystone tenant-get admin | grep " id " | awk '{ print $4 }')"

nova quota-update \
--instances 999999 \
--ram 999999 \
--floating-ips 999999 \
--fixed-ips 999999 \
--cores 999999 \
--key-pairs 999999 \
$TENANT_ID

neutron quota-update \
--network 999999 \
--subnet 999999 \
--port 999999 \
--router 999999 \
--floatingip 999999 \
--security-group 999999 \
--security-group-rule 999999 \
--tenant-id $TENANT_ID

echo " + Quotas are now:"
nova quota-show
neutron quota-show

echo " + Setting n-c-c ram and cpu overcommits."
juju set nova-cloud-controller ram-allocation-ratio=999999
juju set nova-cloud-controller cpu-allocation-ratio=999999
