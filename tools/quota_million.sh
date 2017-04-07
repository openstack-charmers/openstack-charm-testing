#!/bin/bash -ex
# Set quotas to a ridiculous level for admin tenant for testing.

TENANT_ID="$(openstack project show admin | awk '/ id /{ print $4 }')"

openstack quota set\
    --instances 999999\
    --cores 999999\
    --ram 9999999\
    --routers 999999 \
    --ports 999999\
    --networks 999999\
    --subnetpools 999999\
    --floating-ips 999999\
    --fixed-ips 999999 \
    --secgroups 999999\
    --secgroup-rules 999999\
    --key-pairs 999999\
    admin

juju set nova-cloud-controller ram-allocation-ratio=999999 &> /dev/null ||
  juju config nova-cloud-controller ram-allocation-ratio=999999 &> /dev/null

juju set nova-cloud-controller cpu-allocation-ratio=999999 &> /dev/null ||
  juju config nova-cloud-controller cpu-allocation-ratio=999999 &> /dev/null
