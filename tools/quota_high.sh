#!/bin/bash -ex
# Set quotas to a high level for admin tenant for testing.

TENANT_ID="$(openstack project show admin | awk '/ id /{ print $4 }')"

openstack quota set\
    --instances 300\
    --cores 1200\
    --ram 2048000\
    --routers 300 \
    --ports 300\
    --networks 300\
    --subnetpools 300\
    --floating-ips 300\
    --fixed-ips 300 \
    --secgroups 300\
    --secgroup-rules 300\
    --key-pairs 300\
    admin

juju set nova-cloud-controller ram-allocation-ratio=100 &> /dev/null ||
  juju config nova-cloud-controller ram-allocation-ratio=100 &> /dev/null

juju set nova-cloud-controller cpu-allocation-ratio=100 &> /dev/null ||
  juju config nova-cloud-controller cpu-allocation-ratio=100 &> /dev/null
